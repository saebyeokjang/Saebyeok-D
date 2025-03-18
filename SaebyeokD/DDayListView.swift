//
//  DDayListView.swift
//  SaebyeokD
//
//  Created by Saebyeok Jang on 2/7/25.
//

import SwiftUI
import SwiftData

struct DDayListView: View {
    @Environment(\.modelContext) var modelContext
    @AppStorage("sortOption") private var sortOption: String = SortOption.targetDateAscending.rawValue
    
    @State private var events: [DDayEvent] = []
    @State private var currentDate = Date()
    @State private var refreshID = UUID()
    @State private var isCustomOrderSheetPresented = false
    
    // 매 시간마다 새로고침하는 타이머
    let hourlyTimer = Timer.publish(every: 3600, on: .main, in: .common).autoconnect()
    
    // 자정에 새로고침하는 타이머
    @State private var midnightTimer: Timer?
    
    var body: some View {
        VStack(spacing: 0) {
            // 정렬 드롭다운 메뉴
            HStack {
                Menu {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Button(action: {
                            sortOption = option.rawValue
                            loadAndSortEvents()
                            
                            // 사용자 지정 순서 선택 시 편집 시트 표시
                            if option == .userDefined {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    isCustomOrderSheetPresented = true
                                }
                            }
                        }) {
                            Label(option.displayName, systemImage: option.iconName)
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.up.arrow.down")
                        Text("정렬")
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(20)
                }
                
                if SortOption(rawValue: sortOption) == .userDefined {
                    Button {
                        isCustomOrderSheetPresented = true
                    } label: {
                        HStack {
                            Image(systemName: "pencil")
                            Text("순서")
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(20)
                    }
                }
                Spacer()
            }
            //.padding(.horizontal)
            .padding(.bottom, 12)
            
            if events.isEmpty {
                Spacer()
                Text("등록된 디데이가 없습니다")
                    .foregroundColor(.white)
                    .font(.custom("NIXGONM-Vb", size: 18))
                Spacer()
            } else {
                // 일반 모드에서는 기본 리스트만 표시
                List {
                    ForEach(events) { event in
                        DDayRowView(event: event)
                            .listRowInsets(EdgeInsets(top: 3, leading: 1, bottom: 3, trailing: 1))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .id("\(event.id)-\(refreshID)")
                    }
                }
                .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
        }
        .sheet(isPresented: $isCustomOrderSheetPresented) {
            CustomOrderEditView(events: events) { updatedEvents in
                events = updatedEvents
                saveUserDefinedOrder()
                loadAndSortEvents()
            }
            .presentationDetents([.medium, .large])
        }
        .onReceive(hourlyTimer) { _ in
            // 매 시간마다 현재 날짜 업데이트 및 뷰 새로고침
            self.currentDate = Date()
            self.refreshID = UUID()
            loadAndSortEvents()
        }
        .onAppear {
            setupMidnightTimer()
            loadAndSortEvents()
        }
        .onDisappear {
            midnightTimer?.invalidate()
        }
        .onChange(of: sortOption) { _, _ in
            loadAndSortEvents()
        }
    }
    
    // 사용자 지정 순서 저장
    private func saveUserDefinedOrder() {
        // 사용자 지정 순서 저장 로직
        let eventIds = events.map { "\($0.id)" }
        UserDefaults.standard.set(eventIds, forKey: "userDefinedOrder")
        
        // 위젯 업데이트 (현재 순서 기준)
        updateWidgetWithSortedEvents()
    }
    
    // 이벤트 로드 및 정렬
    private func loadAndSortEvents() {
        do {
            let descriptor = FetchDescriptor<DDayEvent>(sortBy: [])
            let allEvents = try modelContext.fetch(descriptor)
            
            // 선택된 정렬 옵션에 따라 이벤트 정렬
            let selectedOption = SortOption(rawValue: sortOption) ?? .targetDateAscending
            
            switch selectedOption {
            case .targetDateAscending:
                events = allEvents.sorted { $0.targetDate < $1.targetDate }
            case .targetDateDescending:
                events = allEvents.sorted { $0.targetDate > $1.targetDate }
            case .userDefined:
                // 사용자 지정 순서 불러오기
                if let savedOrder = UserDefaults.standard.array(forKey: "userDefinedOrder") as? [String] {
                    // 저장된 순서가 있으면 해당 순서대로 정렬
                    var sortedEvents: [DDayEvent] = []
                    
                    // 저장된 순서에 있는 이벤트 먼저 추가
                    for id in savedOrder {
                        if let event = allEvents.first(where: { "\($0.id)".contains(id) || id.contains("\($0.id)") }) {
                            sortedEvents.append(event)
                        }
                    }
                    
                    // 나머지 새로 추가된 이벤트는 날짜순으로 뒤에 추가
                    let remainingEvents = allEvents.filter { event in
                        !sortedEvents.contains { $0.id == event.id }
                    }.sorted { $0.targetDate < $1.targetDate }
                    
                    sortedEvents.append(contentsOf: remainingEvents)
                    events = sortedEvents
                } else {
                    // 저장된 순서가 없으면 기본적으로 날짜 오름차순
                    events = allEvents.sorted { $0.targetDate < $1.targetDate }
                }
            }
            
            // 정렬된 이벤트를 위젯과 동기화
            updateWidgetWithSortedEvents()
            
        } catch {
            print("이벤트 로드 실패: \(error)")
        }
    }
    
    // 정렬된 이벤트로 위젯 업데이트
    private func updateWidgetWithSortedEvents() {
        let currentDate = Date()
        let eventDataArray = events.map { event in
            let idString = "\(event.id)"
            let eventUUID = UUID(uuidString: idString) ?? UUID()
            return DDayEventData(
                id: eventUUID,
                title: event.title,
                dDayText: event.calculateDDayText(from: currentDate),
                targetDate: event.targetDate
            )
        }
        
        SharedDataManager.shared.saveDDayEvents(eventDataArray)
    }
    
    // 자정에 새로고침하는 타이머 설정
    private func setupMidnightTimer() {
        // 기존 타이머가 있다면 무효화
        midnightTimer?.invalidate()
        
        // 다음 자정 시간 계산
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        guard let nextMidnight = calendar.date(byAdding: .day, value: 1, to: startOfToday) else { return }
        
        // 자정까지 남은 시간(초)
        let timeInterval = nextMidnight.timeIntervalSince(now)
        
        // 타이머 설정 (weak self 사용하지 않음 - 구조체에서는 사용 불가)
        midnightTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { _ in
            // 자정에 현재 날짜 업데이트 및 뷰 새로고침
            self.currentDate = Date()
            self.refreshID = UUID()
            self.loadAndSortEvents()
            
            // 다음 자정을 위한 타이머 재설정
            self.setupMidnightTimer()
        }
    }
}

// 사용자 지정 순서 편집을 위한 시트 뷰
struct CustomOrderEditView: View {
    @Environment(\.dismiss) var dismiss
    @State private var editableEvents: [DDayEvent]
    var onSave: ([DDayEvent]) -> Void
    
    init(events: [DDayEvent], onSave: @escaping ([DDayEvent]) -> Void) {
        self._editableEvents = State(initialValue: events)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 배경
                Color.black.opacity(0.9).ignoresSafeArea()
                
                VStack {
                    List {
                        ForEach(editableEvents) { event in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(event.title)
                                        .font(.custom("NIXGONM-Vb", size: 18))
                                        .foregroundColor(.white)
                                    
                                    Text(formattedDate(from: event.targetDate))
                                        .font(.custom("NIXGONL-Vb", size: 14))
                                        .foregroundColor(.white)
                                }
                                Spacer()
                                Text(event.dDayText)
                                    .font(.custom("NIXGONM-Vb", size: 20))
                                    .foregroundColor(.white)
                            }
                            .padding(.vertical, 8)
                            .listRowBackground(Color.black.opacity(0.4))
                        }
                        .onMove(perform: moveItem)
                    }
                    .listStyle(PlainListStyle())
                    .scrollContentBackground(.hidden)
                    .environment(\.editMode, .constant(.active))
                    .tint(.yellow) // 정렬 핸들 아이콘의 색상을 노란색으로 변경
                }
            }
            .navigationTitle("순서 편집")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") {
                        onSave(editableEvents)
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
    
    private func moveItem(from source: IndexSet, to destination: Int) {
        editableEvents.move(fromOffsets: source, toOffset: destination)
    }
    
    func formattedDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.MM.dd(EEE)"
        return formatter.string(from: date)
    }
}
