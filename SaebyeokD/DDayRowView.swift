//
//  DDayRowView.swift
//  SaebyeokD
//
//  Created by Saebyeok Jang on 2/7/25.
//

import SwiftUI
import SwiftData

struct DDayRowView: View {
    let event: DDayEvent
    @Environment(\.modelContext) var modelContext
    @State private var currentDate = Date()
    
    // 1시간마다 날짜 업데이트를 위한 타이머
    let timer = Timer.publish(every: 3600, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            NavigationLink(destination: EditDDayView(event: event)) {
                EmptyView()
            }
            .opacity(0)
            
            HStack {
                // 왼쪽: 제목과 날짜 표시 (왼쪽 정렬)
                VStack(alignment: .leading, spacing: 4) {
                    Spacer()
                    Text(event.title)
                        .font(.custom("NIXGONM-Vb", size: 20))
                        .foregroundColor(.white)
                    Spacer()
                    Text(formattedDate(from: event.targetDate))
                        .font(.custom("NIXGONL-Vb", size: 14))
                        .foregroundColor(.white)
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(event.calculateDDayText(from: currentDate))
                    .font(.custom("NIXGONM-Vb", size: 28))
                    .foregroundColor(.white)
                    .kerning(-2)
            }
            .frame(height: 80)
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.black.opacity(0.3))
            )
            // 스와이프 삭제
            .swipeActions(edge: .trailing) {
                Button(role: .destructive) {
                    withAnimation {
                        let eventToDelete = event
                        modelContext.delete(event)
                        do {
                            try modelContext.save()
                            NotificationManager.shared.cancelNotification(for: eventToDelete)
                            SharedDataManager.shared.removeSingleEvent(eventToDelete)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                SharedDataManager.shared.refreshAllWidgetData(modelContext: modelContext)
                            }
                        } catch {
                            print("삭제 실패: \(error)")
                        }
                    }
                } label: {
                    Label("삭제", systemImage: "trash")
                }
                .tint(Color(UIColor.darkGray))
            }
            .onReceive(timer) { _ in
                self.currentDate = Date()
            }
        }
    }
    
    func formattedDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.MM.dd(EEE)"
        return formatter.string(from: date)
    }
}
