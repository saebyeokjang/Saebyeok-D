//
//  SharedDataManager.swift
//  SaebyeokD
//
//  Created by Saebyeok Jang on 2/14/25.
//

import Foundation
import WidgetKit
import SwiftData

// 앱과 위젯에서 공유할 데이터 모델
struct DDayEventData: Codable, Identifiable {
    let id: String
    let title: String
    let dDayText: String
}

class SharedDataManager {
    static let shared = SharedDataManager()
    private let suiteName = "group.com.SaebyeokD"  // 실제 App Group 식별자로 변경

    private init() {}

    func saveDDayEvents(_ events: [DDayEventData]) {
        if let defaults = UserDefaults(suiteName: suiteName) {
            do {
                let data = try JSONEncoder().encode(events)
                defaults.set(data, forKey: "ddayList")
                // 위젯 타임라인 새로고침 요청
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

// updateDDayWidget 함수: 단일 이벤트를 업데이트할 때 사용 (예: 추가 또는 편집 후)
func updateDDayWidget(with event: DDayEvent) {
    let eventData = DDayEventData(
        id: "\(event.id)",  // 또는 event.id.uuidString
        title: event.title,
        dDayText: event.dDayText
    )
    SharedDataManager.shared.saveDDayEvents([eventData])
    WidgetCenter.shared.reloadAllTimelines()
}

func updateWidgetSharedData(modelContext: ModelContext) {
    do {
        let fetchDescriptor = FetchDescriptor<DDayEvent>()
        let allEvents: [DDayEvent] = try modelContext.fetch(fetchDescriptor)
        let eventDataArray = allEvents.map { event in
            DDayEventData(
                id: "\(event.id)",   // PersistentIdentifier를 문자열로 변환
                title: event.title,
                dDayText: event.dDayText
            )
        }
        SharedDataManager.shared.saveDDayEvents(eventDataArray)
    } catch {
        print("Failed to fetch events for widget update: \(error)")
    }
    WidgetCenter.shared.reloadAllTimelines()
}
