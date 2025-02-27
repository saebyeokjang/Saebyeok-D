//
//  EditDDayView.swift
//  SaebyeokD
//
//  Created by Saebyeok Jang on 2/12/25.
//

import SwiftUI
import SwiftData

struct EditDDayView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = false
    
    var event: DDayEvent
    
    @State private var title: String
    @State private var targetDate: Date
    @State private var selectedEventType: DDayEventType
    
    init(event: DDayEvent) {
        self.event = event
        _title = State(initialValue: event.title)
        _targetDate = State(initialValue: event.targetDate)
        _selectedEventType = State(initialValue: event.eventType)
    }
    
    var body: some View {
        ZStack {
            NightSkyBackground()
                .ignoresSafeArea()
            
            Form {
                Section(header: Text("디데이 정보").foregroundStyle(Color.white)) {
                    TextField("제목", text: $title)
                    ConfirmableDatePicker(selectedDate: $targetDate)
                    HStack {
                        ForEach(DDayEventType.allCases, id: \.self) { type in
                            Button {
                                withAnimation {
                                    selectedEventType = type
                                }
                            } label: {
                                VStack(spacing: 4) {
                                    Text(displayName(for: type))
                                        .font(.custom("NIXGONM-Vb", size: 16))
                                        .foregroundColor(selectedEventType == type ? .white : .gray)
                                    Rectangle()
                                        .fill(selectedEventType == type ? Color.white : Color.clear)
                                        .frame(height: 1)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.top, 8)
                }
                .foregroundStyle(Color.white)
                .listRowBackground(Color.black.opacity(0.3))
                .font(.custom("NIXGONM-Vb", size: 18))
                
                Button(action: {
                    event.title = title
                    event.targetDate = targetDate
                    event.eventType = selectedEventType
                    
                    do {
                        try modelContext.save()
                        SharedDataManager.shared.updateSingleEvent(event)
                        if notificationsEnabled {
                            // 알림이 켜진 상태이면 기존 알림을 취소한 후 새로 예약
                            NotificationManager.shared.cancelNotification(for: event)
                            NotificationManager.shared.scheduleNotification(for: event)
                        } else {
                            // 알림이 꺼진 상태이면 알림 취소
                            NotificationManager.shared.cancelNotification(for: event)
                        }
                    } catch {
                        print("저장 실패: \(error)")
                    }
                    dismiss()
                }) {
                    HStack {
                        Spacer()
                        Text("저장")
                            .font(.custom("NIXGONM-Vb", size: 18))
                            .foregroundColor(.white)
                        Spacer()
                    }
                }
                .foregroundStyle(Color.white)
                .listRowBackground(Color.black.opacity(0.3))
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
        .navigationTitle("디데이 편집")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .light))
                        .foregroundColor(.white)
                        .padding(8)
                }
            }
        }
    }
    
    private func displayName(for type: DDayEventType) -> String {
        switch type {
        case .countdown:
            return "카운트다운"
        case .dateCounter:
            return "날짜세기"
        }
    }
}
