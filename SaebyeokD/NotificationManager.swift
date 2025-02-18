//
//  NotificationManager.swift
//  SaebyeokD
//
//  Created by Saebyeok Jang on 2/18/25.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    // 알림 권한 요청
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("알림 권한 요청 에러: \(error.localizedDescription)")
            } else {
                print("알림 권한 승인 여부: \(granted)")
            }
        }
    }
    
    // 알림 예약
    func scheduleNotification(for event: DDayEvent) {
        let content = UNMutableNotificationContent()
        content.title = event.title
        content.body = "오늘이 바로 그 날입니다. 지금 확인하세요!"
        content.sound = .default

        // targetDate의 자정
        let triggerDate = Calendar.current.startOfDay(for: event.targetDate)
        let triggerComponents = Calendar.current.dateComponents([.year, .month, .day], from: triggerDate)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        
        let identifier = "\(event.id)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("알림 예약 실패: \(error.localizedDescription)")
            } else {
                print("알림 예약 성공!")
            }
        }
    }
    
    // 알림 취소
    func cancelNotification(for event: DDayEvent) {
        let identifier = "\(event.id)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
