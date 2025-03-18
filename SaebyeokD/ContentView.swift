//
//  ContentView.swift
//  SaebyeokD
//
//  Created by Saebyeok Jang on 2/7/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab: Tab = .dday
    @Environment(\.modelContext) var modelContext
    @AppStorage("autoDeleteCountdown") private var autoDeleteCountdown: Bool = false
    @Environment(\.scenePhase) private var scenePhase
    @State private var midnightUpdateTimer: Timer?
    
    enum Tab: String, CaseIterable {
        case dday = "디데이"
        case settings = "설정"
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                NightSkyBackground()
                
                VStack(spacing: 16) {
                    tabSelector
                    VStack {
                        if selectedTab == .dday {
                            DDayListView()
                        } else {
                            SettingsView()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                }
                .navigationTitle("새벽:D")
                .navigationBarTitleDisplayMode(.large)
                .onAppear {
                    setupNavigationBarAppearance()
                    setupMidnightTimer()
                    
                    if autoDeleteCountdown {
                        deletePastCountdownEvents()
                    }
                    
                    // 앱 시작 시 위젯 데이터 새로고침
                    SharedDataManager.shared.refreshAllWidgetData(modelContext: modelContext)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if selectedTab == .dday {
                        NavigationLink(destination: AddDDayView()) {
                            Text("디데이 추가")
                                .font(customFont(size: 18))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                // 앱이 활성화될 때마다 위젯 데이터 새로고침
                SharedDataManager.shared.refreshAllWidgetData(modelContext: modelContext)
                
                // 타이머 재설정
                setupMidnightTimer()
                
                if autoDeleteCountdown {
                    deletePastCountdownEvents()
                }
            } else if newPhase == .background {
                // 앱이 백그라운드로 갔을 때 타이머 무효화 (배터리 절약)
                midnightUpdateTimer?.invalidate()
            }
        }
        .onDisappear {
            // 뷰가 사라질 때 타이머 정리
            midnightUpdateTimer?.invalidate()
        }
    }
    
    // 자정 타이머 설정 함수
    private func setupMidnightTimer() {
        // 기존 타이머가 있다면 무효화
        midnightUpdateTimer?.invalidate()
        
        // 다음 자정 시간 계산
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        guard let nextMidnight = calendar.date(byAdding: .day, value: 1, to: startOfToday) else { return }
        
        // 자정까지 남은 시간(초)
        let timeInterval = nextMidnight.timeIntervalSince(now)
        
        // 타이머 설정
        midnightUpdateTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { _ in
            // 위젯 데이터 새로고침
            SharedDataManager.shared.refreshAllWidgetData(modelContext: self.modelContext)
            
            // 자동 삭제 기능이 활성화된 경우 만료된 이벤트 삭제
            if self.autoDeleteCountdown {
                self.deletePastCountdownEvents()
            }
            
            // 다음 자정을 위한 타이머 재설정
            self.setupMidnightTimer()
        }
    }
    
    private func deletePastCountdownEvents() {
        let now = Date()
        let startOfToday = Calendar.current.startOfDay(for: now)
        let fetchDescriptor = FetchDescriptor<DDayEvent>()
        
        do {
            let allEvents: [DDayEvent] = try modelContext.fetch(fetchDescriptor)
            let pastCountdowns = allEvents.filter { event in
                guard event.eventType == DDayEventType.countdown else { return false }
                let eventStart = Calendar.current.startOfDay(for: event.targetDate)
                return eventStart < startOfToday
            }
            
            for event in pastCountdowns {
                modelContext.delete(event)
                NotificationManager.shared.cancelNotification(for: event)
                SharedDataManager.shared.removeSingleEvent(event)
            }
            try modelContext.save()
            print("지난 카운트다운 이벤트 \(pastCountdowns.count)건 삭제됨")
        } catch {
            print("카운트다운 이벤트 삭제 실패: \(error)")
        }
    }
    
    private var tabSelector: some View {
        HStack {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    VStack(spacing: 4) {
                        Text(tab.rawValue)
                            .font(customFont(size: 18))
                            .foregroundColor(selectedTab == tab ? .white : .gray)
                        Rectangle()
                            .fill(Color.white)
                            .opacity(selectedTab == tab ? 1 : 0)
                            .frame(height: 2)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.top, 16)
    }
    
    private func customFont(size: CGFloat) -> Font {
        Font.custom("NIXGONM-Vb", size: size, relativeTo: .body)
    }
    
    private func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "NIXGONM-Vb", size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .bold)
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "NIXGONM-Vb", size: 36) ?? UIFont.systemFont(ofSize: 36, weight: .bold)
        ]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    ContentView()
}
