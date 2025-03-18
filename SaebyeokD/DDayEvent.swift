//
//  DDayEvent.swift
//  SaebyeokD
//
//  Created by Saebyeok Jang on 2/7/25.
//

import Foundation
import SwiftData

@Model
class DDayEvent {
    var title: String
    var targetDate: Date
    var eventType: DDayEventType = DDayEventType.countdown
    
    init(title: String, targetDate: Date, eventType: DDayEventType = .countdown) {
        self.title = title
        self.targetDate = targetDate
        self.eventType = eventType
    }
    
    var dDayText: String {
        calculateDDayText(from: Date())
    }
    
    func calculateDDayText(from date: Date) -> String {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: date)
        let startOfTarget = calendar.startOfDay(for: targetDate)
        let diff = calendar.dateComponents([.day], from: startOfToday, to: startOfTarget).day ?? 0
        
        switch diff {
        case 0:
            return "오늘"
        case 1...:
            return "D-\(diff)"
        default:
            return "\(-diff + 1)일"
        }
    }
}

enum DDayEventType: String, Codable, CaseIterable {
    case countdown
    case dateCounter
}
