//
//  SettingsView.swift
//  SaebyeokD
//
//  Created by Saebyeok Jang on 2/7/25.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    @AppStorage("autoDeleteCountdown") private var autoDeleteCountdown: Bool = false
    @Environment(\.modelContext) var modelContext
    
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
                        Text("카운트다운 디데이의 날짜가 지나면 자동으로 삭제합니다")
                            .font(.custom("NIXGONL-Vb", size: 14))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 8)
                }
                .toggleStyle(SwitchToggleStyle(tint: .yellow))
                .onChange(of: autoDeleteCountdown) { newValue in
                    print("autoDeleteCountdown changed: \(newValue)")
                    if newValue {
                        deletePastCountdownEvents(modelContext: modelContext)
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
    }
}

func deletePastCountdownEvents(modelContext: ModelContext) {
    let autoDelete = UserDefaults.standard.bool(forKey: "autoDeleteCountdown")
    if !autoDelete {
        return
    }
    
    let now = Date()
    let fetchDescriptor = FetchDescriptor<DDayEvent>()
    
    do {
        let allEvents: [DDayEvent] = try modelContext.fetch(fetchDescriptor)
        
        let pastCountdowns = allEvents.filter { event in
            return event.eventType == DDayEventType.countdown && event.targetDate < now
        }
        
        for event in pastCountdowns {
            modelContext.delete(event)
            NotificationManager.shared.cancelNotification(for: event)
        }
        try modelContext.save()
        updateWidgetSharedData(modelContext: modelContext)
        print("지난 카운트다운 이벤트 \(pastCountdowns.count)건 삭제됨")
    } catch {
        print("지난 카운트다운 이벤트 삭제 실패: \(error)")
    }
}

#Preview {
    SettingsView()
}
