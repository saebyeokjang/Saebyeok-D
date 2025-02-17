//
//  SharedDataManager.swift
//  SaebyeokD
//
//  Created by Saebyeok Jang on 2/14/25.
//

import Foundation
import WidgetKit
import SwiftData

// 앱과 위젯에서 공유할 데이터 모델: 목표날짜(targetDate) 추가
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
    private let suiteName = "group.com.SaebyeokD" // 실제 App Group 식별자

    private init() {}

    func saveDDayEvents(_ events: [DDayEventData]) {
        if let defaults = UserDefaults(suiteName: suiteName) {
            do {
                let data = try JSONEncoder().encode(events)
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
}

// updateWidgetSharedData: 앱의 전체 이벤트 목록을 다시 불러와 저장하는 함수
func updateWidgetSharedData(modelContext: ModelContext) {
    do {
        // 모든 DDayEvent 객체를 가져옵니다.
        let fetchDescriptor = FetchDescriptor<DDayEvent>()
        let allEvents: [DDayEvent] = try modelContext.fetch(fetchDescriptor)
        
        // 목표날짜(targetDate) 기준 오름차순으로 정렬합니다.
        let sortedEvents = allEvents.sorted { $0.targetDate < $1.targetDate }
        
        let eventDataArray = sortedEvents.map { event in
            // PersistentIdentifier를 문자열로 변환한 후 UUID로 변환
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
    } catch {
        print("Failed to fetch events for widget update: \(error)")
    }
    WidgetCenter.shared.reloadAllTimelines()
}
