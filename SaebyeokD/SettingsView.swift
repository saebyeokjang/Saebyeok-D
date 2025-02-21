//
//  SettingsView.swift
//  SaebyeokD
//
//  Created by Saebyeok Jang on 2/7/25.
//

import SwiftUI
import SwiftData
import UserNotifications

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = false
    @AppStorage("autoDeleteCountdown") private var autoDeleteCountdown: Bool = false
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.openURL) var openURL
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        VStack(spacing: 0) {
            // 디데이 설정 섹션
            VStack(alignment: .leading, spacing: 8) {
                Text("디데이 설정")
                    .font(.custom("NIXGONB-Vb", size: 14))
                    .foregroundColor(.white)
                Toggle(isOn: $autoDeleteCountdown) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("지나간 카운트다운 자동 삭제")
                            .font(.custom("NIXGONM-Vb", size: 18))
                            .foregroundColor(.white)
                        Text("카운트다운 디데이의 날짜가 지나면 자동으로 삭제됩니다 (자정 업데이트)")
                            .font(.custom("NIXGONL-Vb", size: 14))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 8)
                }
                .toggleStyle(SwitchToggleStyle(tint: .yellow))
                .onChange(of: autoDeleteCountdown) { newValue, _ in
                    if newValue {
                        deletePastCountdownEvents()
                    }
                }
            }
            .padding(.vertical, 20)
            .padding(.horizontal)
            
            Divider()
                .frame(height: 1)
                .background(Color.white)
                .padding(.horizontal, 16)
            
            // 알림 설정 섹션
            VStack(alignment: .leading, spacing: 8) {
                Text("알림 설정")
                    .font(.custom("NIXGONB-Vb", size: 14))
                    .foregroundColor(.white)
                Toggle(isOn: $notificationsEnabled) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("디데이 알림")
                            .font(.custom("NIXGONM-Vb", size: 18))
                            .foregroundColor(.white)
                        Text("디데이의 알림 기능을 사용합니다")
                            .font(.custom("NIXGONL-Vb", size: 14))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 8)
                }
                .toggleStyle(SwitchToggleStyle(tint: .yellow))
                .onChange(of: notificationsEnabled) { newValue, _ in
                    Task { @MainActor in
                        let settings = await UNUserNotificationCenter.current().notificationSettings()
                        if settings.authorizationStatus == .denied {
                            notificationsEnabled = false
                            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                                openURL(settingsUrl)
                            }
                        } else if settings.authorizationStatus == .notDetermined {
                            requestNotificationPermission()
                        }
                    }
                }
            }
            .padding(.vertical, 20)
            .padding(.horizontal)
            
            Divider()
                .frame(height: 1)
                .background(Color.white)
                .padding(.horizontal, 16)
            
            // 기타 설정 섹션
            VStack(alignment: .leading, spacing: 8) {
                Text("기타 설정")
                    .font(.custom("NIXGONB-Vb", size: 14))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                VStack(alignment: .leading, spacing: 4) {
                    Text("준비중")
                        .font(.custom("NIXGONM-Vb", size: 18))
                        .foregroundColor(.white)
                    Text("추가 설정 준비중입니다")
                        .font(.custom("NIXGONL-Vb", size: 14))
                        .foregroundColor(.white)
                }
                .padding(.top, 8)
            }
            .padding(.vertical, 20)
            .padding(.horizontal)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .scrollContentBackground(.hidden)
        .background(Color.black.opacity(0.3))
        .onAppear {
            checkNotificationAuthorizationStatus()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                checkNotificationAuthorizationStatus()
            }
        }
    }
    
    private func deletePastCountdownEvents() {
        if !autoDeleteCountdown { return }
        
        let now = Date()
        let fetchDescriptor = FetchDescriptor<DDayEvent>()
        
        do {
            let allEvents: [DDayEvent] = try modelContext.fetch(fetchDescriptor)
            let pastCountdowns = allEvents.filter { event in
                event.eventType == DDayEventType.countdown && event.targetDate < now
            }
            for event in pastCountdowns {
                modelContext.delete(event)
                NotificationManager.shared.cancelNotification(for: event)
            }
            try modelContext.save()
            updateWidgetSharedData(modelContext: modelContext)
        } catch {
            print("지난 카운트다운 이벤트 삭제 실패: \(error)")
        }
    }
    
    private func handleNotificationPermission(isEnabled: Bool) {
        guard isEnabled else { return }
        
        Task { @MainActor in
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            if settings.authorizationStatus == .denied {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    openURL(settingsUrl)
                }
            } else if settings.authorizationStatus == .notDetermined {
                requestNotificationPermission()
            }
        }
    }
    
    private func requestNotificationPermission() {
        Task { @MainActor in
            do {
                let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
                notificationsEnabled = granted
            } catch {
                print("알림 권한 요청 실패: \(error)")
                notificationsEnabled = false
            }
        }
    }
    
    private func checkNotificationAuthorizationStatus() {
        Task { @MainActor in
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            let isAuthorized = settings.authorizationStatus == .authorized ||
            settings.authorizationStatus == .provisional
            notificationsEnabled = isAuthorized
        }
    }
}

#Preview {
    SettingsView()
}
