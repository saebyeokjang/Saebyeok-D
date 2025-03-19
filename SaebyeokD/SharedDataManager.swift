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
    
    private init() {
        // 초기화 시 주기적 위젯 업데이트 타이머 설정
        setupPeriodicWidgetUpdate()
    }
    
    // 주기적인 위젯 업데이트 타이머 설정 (1시간마다)
    private func setupPeriodicWidgetUpdate() {
        Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // 현재 저장된 데이터를 불러와서 D-day 텍스트 갱신 후 저장
            var currentData = self.loadDDayEvents()
            
            let now = Date()
            let calendar = Calendar.current
            let startOfToday = calendar.startOfDay(for: now)
            
            // 각 이벤트의 D-day 텍스트 갱신
            for index in 0..<currentData.count {
                let event = currentData[index]
                let startOfTarget = calendar.startOfDay(for: event.targetDate)
                let diff = calendar.dateComponents([.day], from: startOfToday, to: startOfTarget).day ?? 0
                
                var newDDayText: String
                switch diff {
                case 0:
                    newDDayText = "오늘"
                case 1...:
                    newDDayText = "D-\(diff)"
                default:
                    newDDayText = "\(-diff + 1)일"
                }
                
                // 새로운 이벤트 데이터로 교체
                let updatedEvent = DDayEventData(
                    id: UUID(uuidString: event.id) ?? UUID(),
                    title: event.title,
                    dDayText: newDDayText,
                    targetDate: event.targetDate
                )
                
                currentData[index] = updatedEvent
            }
            
            // 업데이트된 데이터 저장 (앱의 정렬 방식 적용)
            self.saveDDayEvents(currentData, preserveOrder: true)
            
            // 위젯 타임라인 강제 갱신
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    // 정렬 옵션을 적용하거나 무시하는 파라미터 추가
    func saveDDayEvents(_ events: [DDayEventData], preserveOrder: Bool = false) {
        if let defaults = UserDefaults(suiteName: suiteName) {
            do {
                var eventsToSave = events
                
                // preserveOrder가 false이고 사용자 지정 순서가 아닌 경우에만 정렬
                if !preserveOrder {
                    let sortOptionKey = UserDefaults.standard.string(forKey: "sortOption") ?? SortOption.targetDateAscending.rawValue
                    let sortOption = SortOption(rawValue: sortOptionKey) ?? .targetDateAscending
                    
                    switch sortOption {
                    case .targetDateAscending:
                        eventsToSave.sort { $0.targetDate < $1.targetDate }
                    case .targetDateDescending:
                        eventsToSave.sort { $0.targetDate > $1.targetDate }
                    case .userDefined:
                        // 사용자 지정 순서 유지
                        if let savedOrder = UserDefaults.standard.array(forKey: "userDefinedOrder") as? [String] {
                            var sortedEvents: [DDayEventData] = []
                            
                            // 저장된 순서에 있는 이벤트 먼저 추가
                            for id in savedOrder {
                                if let event = eventsToSave.first(where: { $0.id.contains(id) || id.contains($0.id) }) {
                                    sortedEvents.append(event)
                                }
                            }
                            
                            // 나머지 새로 추가된 이벤트는 뒤에 추가
                            let remainingEvents = eventsToSave.filter { event in
                                !sortedEvents.contains { $0.id == event.id }
                            }
                            
                            sortedEvents.append(contentsOf: remainingEvents)
                            eventsToSave = sortedEvents
                        }
                    }
                }
                
                // 현재 사용 중인 정렬 방식도 저장
                let currentSortOption = UserDefaults.standard.string(forKey: "sortOption") ?? SortOption.targetDateAscending.rawValue
                defaults.set(currentSortOption, forKey: "widgetSortOption")
                
                let data = try JSONEncoder().encode(eventsToSave)
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
    
    // 위젯이 사용할 정렬 옵션 가져오기
    func getWidgetSortOption() -> String {
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            return SortOption.targetDateAscending.rawValue
        }
        return defaults.string(forKey: "widgetSortOption") ?? SortOption.targetDateAscending.rawValue
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
        
        // 현재 시간 기준으로 계산된 D-day 텍스트
        let dDayText = event.calculateDDayText(from: Date())
        
        // ID 문자열이 완전히 일치하지 않더라도 포함되어 있으면 이벤트 찾기
        let existingIndex = currentData.firstIndex { $0.id.contains(idString) || idString.contains($0.id) }
        
        // DDayEventData 객체 생성
        let eventData = DDayEventData(
            id: UUID(uuidString: idString) ?? UUID(),
            title: event.title,
            dDayText: dDayText,
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
        
        // 현재 앱의 정렬 방식에 따라 정렬 적용
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
        
        // 삭제 후 저장 (앱의 정렬 방식 적용)
        saveDDayEvents(currentData)
        
        // 위젯 업데이트
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func refreshAllWidgetData(modelContext: ModelContext) {
        do {
            // AppStorage에서 정렬 옵션 가져오기
            let sortOptionKey = UserDefaults.standard.string(forKey: "sortOption") ?? SortOption.targetDateAscending.rawValue
            let sortOption = SortOption(rawValue: sortOptionKey) ?? .targetDateAscending
            
            let fetchDescriptor = FetchDescriptor<DDayEvent>()
            let allEvents: [DDayEvent] = try modelContext.fetch(fetchDescriptor)
            
            print("위젯 데이터 새로고침: 현재 앱에 \(allEvents.count)개의 이벤트 있음")
            
            let currentDate = Date()
            
            // 정렬된 이벤트 생성
            var sortedEvents = allEvents
            
            // 앱의 정렬 옵션에 따라 이벤트 정렬
            switch sortOption {
            case .targetDateAscending:
                sortedEvents.sort { $0.targetDate < $1.targetDate }
            case .targetDateDescending:
                sortedEvents.sort { $0.targetDate > $1.targetDate }
            case .userDefined:
                // 사용자 지정 순서 불러오기
                if let savedOrder = UserDefaults.standard.array(forKey: "userDefinedOrder") as? [String] {
                    var sortedByUserOrder: [DDayEvent] = []
                    
                    // 저장된 순서에 있는 이벤트 먼저 추가
                    for id in savedOrder {
                        if let event = allEvents.first(where: { "\($0.id)".contains(id) || id.contains("\($0.id)") }) {
                            sortedByUserOrder.append(event)
                        }
                    }
                    
                    // 나머지 새로 추가된 이벤트는 날짜순으로 뒤에 추가
                    let remainingEvents = allEvents.filter { event in
                        !sortedByUserOrder.contains { $0.id == event.id }
                    }.sorted { $0.targetDate < $1.targetDate }
                    
                    sortedByUserOrder.append(contentsOf: remainingEvents)
                    sortedEvents = sortedByUserOrder
                }
            }
            
            let eventDataArray = sortedEvents.map { event in
                let idString = "\(event.id)"
                let eventUUID = UUID(uuidString: idString) ?? UUID()
                return DDayEventData(
                    id: eventUUID,
                    title: event.title,
                    dDayText: event.calculateDDayText(from: currentDate),
                    targetDate: event.targetDate
                )
            }
            
            // 앱의 현재 정렬 방식으로 이벤트 저장 (위젯용)
            saveDDayEvents(eventDataArray, preserveOrder: true)
            
            // 위젯 강제 업데이트
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            print("위젯 데이터 전체 새로고침 실패: \(error)")
        }
    }
}


func updateWidgetSharedData(modelContext: ModelContext) {
    do {
        // 앱의 정렬 옵션 적용
        let sortOptionKey = UserDefaults.standard.string(forKey: "sortOption") ?? SortOption.targetDateAscending.rawValue
        let sortOption = SortOption(rawValue: sortOptionKey) ?? .targetDateAscending
        
        let fetchDescriptor = FetchDescriptor<DDayEvent>()
        let allEvents: [DDayEvent] = try modelContext.fetch(fetchDescriptor)
        
        // 앱의 정렬 방식에 따라 정렬
        var sortedEvents: [DDayEvent]
        
        switch sortOption {
        case .targetDateAscending:
            sortedEvents = allEvents.sorted { $0.targetDate < $1.targetDate }
        case .targetDateDescending:
            sortedEvents = allEvents.sorted { $0.targetDate > $1.targetDate }
        case .userDefined:
            // 사용자 지정 순서 불러오기
            if let savedOrder = UserDefaults.standard.array(forKey: "userDefinedOrder") as? [String] {
                var sortedByUserOrder: [DDayEvent] = []
                
                // 저장된 순서에 있는 이벤트 먼저 추가
                for id in savedOrder {
                    if let event = allEvents.first(where: { "\($0.id)".contains(id) || id.contains("\($0.id)") }) {
                        sortedByUserOrder.append(event)
                    }
                }
                
                // 나머지 새로 추가된 이벤트는 날짜순으로 뒤에 추가
                let remainingEvents = allEvents.filter { event in
                    !sortedByUserOrder.contains { $0.id == event.id }
                }.sorted { $0.targetDate < $1.targetDate }
                
                sortedByUserOrder.append(contentsOf: remainingEvents)
                sortedEvents = sortedByUserOrder
            } else {
                sortedEvents = allEvents.sorted { $0.targetDate < $1.targetDate }
            }
        }
        
        let currentDate = Date()
        let eventDataArray = sortedEvents.map { event in
            let idString = "\(event.id)"
            let eventUUID = UUID(uuidString: idString) ?? UUID()
            return DDayEventData(
                id: eventUUID,
                title: event.title,
                dDayText: event.calculateDDayText(from: currentDate),
                targetDate: event.targetDate
            )
        }
        SharedDataManager.shared.saveDDayEvents(eventDataArray, preserveOrder: true)
        print("전체 위젯 데이터 업데이트 완료: \(allEvents.count)개의 이벤트")
    } catch {
        print("위젯 업데이트를 위한 이벤트 가져오기 실패: \(error)")
    }
    WidgetCenter.shared.reloadAllTimelines()
}
