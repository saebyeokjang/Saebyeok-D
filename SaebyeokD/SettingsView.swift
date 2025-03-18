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
    @AppStorage("sortOption") private var sortOption: String = SortOption.targetDateAscending.rawValue
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.openURL) var openURL
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var showingSortOptionSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 디데이 설정 섹션
            VStack(alignment: .leading, spacing: 8) {
                Text("디데이 설정")
                    .font(.custom("NIXGONB-Vb", size: 14))
                    .foregroundColor(.yellow)
                
                // 정렬 설정 버튼 추가
                Button {
                    showingSortOptionSheet = true
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("정렬 방식")
                                .font(.custom("NIXGONM-Vb", size: 18))
                                .foregroundColor(.white)
                            Text(SortOption(rawValue: sortOption)?.displayName ?? "날짜 오름차순")
                                .font(.custom("NIXGONL-Vb", size: 14))
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                    }
                    .padding(.vertical, 8)
                }
                .sheet(isPresented: $showingSortOptionSheet) {
                    SortOptionView(selectedOption: $sortOption)
                        .presentationDetents([.medium])
                }
                
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
                    .foregroundColor(.yellow)
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
                // 즉시 탭 제스처로 권한 상태 확인: 권한 거부 또는 미결정이면 설정 앱으로 이동 후 토글은 off로 복원
                .simultaneousGesture(
                    TapGesture().onEnded {
                        Task { @MainActor in
                            let settings = await UNUserNotificationCenter.current().notificationSettings()
                            if settings.authorizationStatus == .denied || settings.authorizationStatus == .notDetermined {
                                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                                    openURL(settingsUrl)
                                }
                                notificationsEnabled = false
                                print("권한 없음 - 토글 off로 복원")
                            }
                        }
                    }
                )
                .onChange(of: notificationsEnabled) { newValue, _ in
                    Task { @MainActor in
                        if newValue {
                            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                            print("알림 취소됨")
                        } else {
                            // 토글이 on일 때, 저장된 알림을 예약
                            scheduleAllNotifications()
                            print("알림 예약됨")
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
                Text("기타")
                    .font(.custom("NIXGONB-Vb", size: 14))
                    .foregroundColor(.yellow)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // 개발자에게 피드백 보내기
                Button {
                    if let url = URL(string: "mailto:dev.saebyeok@gmail.com?subject=새벽:D 피드백") {
                        openURL(url)
                    }
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("개발자에게 피드백 보내기")
                            .font(.custom("NIXGONM-Vb", size: 18))
                            .foregroundColor(.white)
                        Text("건의사항이나 개선점을 알려주세요")
                            .font(.custom("NIXGONL-Vb", size: 14))
                            .foregroundColor(.white)
                    }
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.vertical, 20)
            .padding(.horizontal)
            
            Spacer()
            
            // 개인정보 처리방침 (하단에 작게 배치)
            Button {
                if let url = URL(string: "https://saebyeokjang.github.io/Saebyeok-D/privacy-policy") {
                    openURL(url)
                }
            } label: {
                Text("개인정보 처리방침")
                    .font(.custom("NIXGONL-Vb", size: 12))
                    .foregroundColor(.white)
                    .padding(.bottom, 12)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .scrollContentBackground(.hidden)
        .background(Color.black.opacity(0.3))
        .onAppear {
            if autoDeleteCountdown {
                deletePastCountdownEvents()
            }
            Task { @MainActor in
                let settings = await UNUserNotificationCenter.current().notificationSettings()
                print("앱 시작 시 알림 권한 상태: \(settings.authorizationStatus.rawValue)")
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active, autoDeleteCountdown {
                // 앱이 active 상태로 전환될 때 만료된 이벤트 삭제
                deletePastCountdownEvents()
                Task { @MainActor in
                    let settings = await UNUserNotificationCenter.current().notificationSettings()
                    print("앱 활성화 시 알림 권한 상태: \(settings.authorizationStatus.rawValue)")
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func deletePastCountdownEvents() {
        // autoDeleteCountdown이 true일 때만 진행
        if !autoDeleteCountdown { return }
        
        let now = Date()
        // 현재 날짜의 자정
        let startOfToday = Calendar.current.startOfDay(for: now)
        let fetchDescriptor = FetchDescriptor<DDayEvent>()
        
        do {
            let allEvents: [DDayEvent] = try modelContext.fetch(fetchDescriptor)
            let pastCountdowns = allEvents.filter { event in

                if event.eventType != DDayEventType.countdown { return false }
                let eventStart = Calendar.current.startOfDay(for: event.targetDate)
                return eventStart < startOfToday
            }
            
            print("총 이벤트: \(allEvents.count), 삭제 대상 이벤트 수: \(pastCountdowns.count)")
            
            for event in pastCountdowns {
                modelContext.delete(event)
                NotificationManager.shared.cancelNotification(for: event)
                SharedDataManager.shared.removeSingleEvent(event)
            }
            
            try modelContext.save()
            print("지난 카운트다운 이벤트 \(pastCountdowns.count)건 삭제됨")
        } catch {
            print("지난 카운트다운 이벤트 삭제 실패: \(error)")
        }
    }
    
    private func scheduleAllNotifications() {
        let fetchDescriptor = FetchDescriptor<DDayEvent>()
        do {
            let allEvents: [DDayEvent] = try modelContext.fetch(fetchDescriptor)
            for event in allEvents {
                NotificationManager.shared.scheduleNotification(for: event)
            }
            print("저장된 알림 예약 완료")
        } catch {
            print("알림 예약 실패: \(error)")
        }
    }
}

// 정렬 옵션 선택 시트 뷰
struct SortOptionView: View {
    @Binding var selectedOption: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 배경 색상을 검정색으로 변경
                Color.black.opacity(0.9).ignoresSafeArea()
                
                List {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Button {
                            selectedOption = option.rawValue
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: option.iconName)
                                    .foregroundColor(.white)
                                Text(option.displayName)
                                    .foregroundColor(.white)
                                Spacer()
                                if selectedOption == option.rawValue {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.yellow)
                                }
                            }
                        }
                        .listRowBackground(Color.black.opacity(0.4))
                    }
                }
                .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("정렬 방식 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
