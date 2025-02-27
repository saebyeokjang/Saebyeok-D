//
//  SharedDataManager.swift
//  SaebyeokD
//
//  Created by Saebyeok Jang on 2/14/25.
//

import Foundation
import WidgetKit
import SwiftData

struct DDayEventData: Codable, Identifiable {
    let id: String
    let title: String
    let dDayText: String
    let targetDate: Date
    
    enum CodingKeys: String, CodingKey {
        case id, title, dDayText, targetDate
    }
    
    init(id: UUID, title: String, dDayText: String, targetDate: Date) {
        self.id = id.uuidString
        self.title = title
        self.dDayText = dDayText
        self.targetDate = targetDate
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let idString = try container.decode(String.self, forKey: .id)
        if let uuid = UUID(uuidString: idString) {
            self.id = uuid.uuidString
        } else {
            self.id = UUID().uuidString
        }
        self.title = try container.decode(String.self, forKey: .title)
        self.dDayText = try container.decode(String.self, forKey: .dDayText)
        self.targetDate = try container.decodeIfPresent(Date.self, forKey: .targetDate) ?? Date()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(dDayText, forKey: .dDayText)
        try container.encode(targetDate, forKey: .targetDate)
    }
}

class SharedDataManager {
    static let shared = SharedDataManager()
    private let suiteName = "group.com.SaebyeokD"
    
    private init() {}
    
    func saveDDayEvents(_ events: [DDayEventData]) {
        if let defaults = UserDefaults(suiteName: suiteName) {
            do {
                let sortedEvents = events.sorted { $0.targetDate < $1.targetDate }
                let data = try JSONEncoder().encode(sortedEvents)
                defaults.set(data, forKey: "ddayList")
                WidgetCenter.shared.reloadAllTimelines()
            } catch {
                print("저장 실패: \(error)")
            }
        }
    }
    
    func loadDDayEvents() -> [DDayEventData] {
        guard let defaults = UserDefaults(suiteName: suiteName),
              let data = defaults.data(forKey: "ddayList") else {
            return []
        }
        do {
            return try JSONDecoder().decode([DDayEventData].self, from: data)
        } catch {
            print("불러오기 실패: \(error)")
            return []
        }
    }
    
    func updateSingleEvent(_ event: DDayEvent) {
        var currentData = loadDDayEvents()
        
        // 이벤트 ID 로깅 (디버깅용)
        let idString = "\(event.id)"
        print("업데이트 중인 이벤트 ID: \(idString)")
        print("업데이트 중인 이벤트 제목: \(event.title)")
        
        // 모든 위젯 데이터 ID 출력 (디버깅용)
        print("현재 위젯 데이터의 모든 ID:")
        currentData.forEach { data in
            print("  - ID: \(data.id), 제목: \(data.title)")
        }
        
        // ID 문자열이 완전히 일치하지 않더라도 포함되어 있으면 이벤트 찾기
        let existingIndex = currentData.firstIndex { $0.id.contains(idString) || idString.contains($0.id) }
        
        // DDayEventData 객체 생성
        let eventData = DDayEventData(
            id: UUID(uuidString: idString) ?? UUID(),
            title: event.title,
            dDayText: event.dDayText,
            targetDate: event.targetDate
        )
        
        // 기존 항목이 있으면 업데이트, 없으면 추가
        if let index = existingIndex {
            currentData[index] = eventData
            print("위젯 데이터 업데이트: \(event.title)")
        } else {
            // 이미 비슷한 제목의 이벤트가 있는지 확인 (제목으로 중복 확인)
            let similarTitleIndex = currentData.firstIndex { $0.title == event.title }
            if let titleIndex = similarTitleIndex {
                currentData[titleIndex] = eventData
                print("제목으로 찾은 위젯 데이터 업데이트: \(event.title)")
            } else {
                currentData.append(eventData)
                print("위젯 데이터 추가: \(event.title)")
            }
        }
        
        // 목표날짜 기준으로 정렬
        currentData.sort { $0.targetDate < $1.targetDate }
        
        // 업데이트된 데이터 저장
        saveDDayEvents(currentData)
        
        // 특정 위젯만 업데이트
        WidgetCenter.shared.reloadTimelines(ofKind: "DDayWidget")
    }
    
    func removeSingleEvent(_ event: DDayEvent) {
        var currentData = loadDDayEvents()
        
        // 삭제 전 데이터 수
        _ = currentData.count
        
        // ID 문자열 직접 출력하여 디버깅
        let idString = "\(event.id)"
        print("삭제 중인 이벤트 ID: \(idString)")
        
        // 모든 이벤트 ID 출력 (디버깅용)
        print("현재 위젯 데이터의 모든 ID:")
        currentData.forEach { data in
            print("  - ID: \(data.id)")
        }
        
        // UUID 변환 없이 직접 문자열 비교
        currentData.removeAll { $0.id.contains(idString) }
        
        // 6. 삭제 후 정렬
        currentData.sort { $0.targetDate < $1.targetDate }
        
        // 데이터 저장 및 위젯 강제 업데이트
        saveDDayEvents(currentData)
        
        // 위젯 업데이트
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func refreshAllWidgetData(modelContext: ModelContext) {
        do {
            let fetchDescriptor = FetchDescriptor<DDayEvent>()
            let allEvents: [DDayEvent] = try modelContext.fetch(fetchDescriptor)
            
            print("위젯 데이터 새로고침: 현재 앱에 \(allEvents.count)개의 이벤트 있음")
            
            let eventDataArray = allEvents.map { event in
                let idString = "\(event.id)"
                let eventUUID = UUID(uuidString: idString) ?? UUID()
                return DDayEventData(
                    id: eventUUID,
                    title: event.title,
                    dDayText: event.dDayText,
                    targetDate: event.targetDate
                )
            }
            
            // 날짜 기준으로 정렬
            let sortedEvents = eventDataArray.sorted { $0.targetDate < $1.targetDate }
            saveDDayEvents(sortedEvents)
            
            // 위젯 강제 업데이트
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            print("위젯 데이터 전체 새로고침 실패: \(error)")
        }
    }
}


func updateWidgetSharedData(modelContext: ModelContext) {
    do {
        let fetchDescriptor = FetchDescriptor<DDayEvent>()
        let allEvents: [DDayEvent] = try modelContext.fetch(fetchDescriptor)
        
        // 오름차순으로 정렬
        let sortedEvents = allEvents.sorted { $0.targetDate < $1.targetDate }
        
        let eventDataArray = sortedEvents.map { event in
            let idString = "\(event.id)"
            let eventUUID = UUID(uuidString: idString) ?? UUID()
            return DDayEventData(
                id: eventUUID,
                title: event.title,
                dDayText: event.dDayText,
                targetDate: event.targetDate
            )
        }
        SharedDataManager.shared.saveDDayEvents(eventDataArray)
        print("전체 위젯 데이터 업데이트 완료: \(allEvents.count)개의 이벤트")
    } catch {
        print("위젯 업데이트를 위한 이벤트 가져오기 실패: \(error)")
    }
    WidgetCenter.shared.reloadAllTimelines()
}
