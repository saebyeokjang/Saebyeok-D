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
    @Environment(\.modelContext) var modelContext  // 삭제를 위해 모델 컨텍스트 사용

    var body: some View {
        ZStack {
            NavigationLink(destination: EditDDayView(event: event)) {
                EmptyView()
            }
            .opacity(0)

            HStack {
                // 왼쪽: 제목과 날짜 (왼쪽 정렬)
                VStack(alignment: .leading, spacing: 4) {
                    Spacer()
                    Text(event.title)
                        .font(.custom("NIXGONM-Vb", size: 24))
                        .foregroundColor(.white)
                    Spacer()
                    Text(formattedDate(from: event.targetDate))
                        .font(.custom("NIXGONL-Vb", size: 14))
                        .foregroundColor(.white)
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // 오른쪽: D-day 텍스트
                Text(calculateDDayText(from: event.targetDate))
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
                    modelContext.delete(event)
                    do {
                        try modelContext.save()
                    } catch {
                        print("삭제 실패: \(error)")
                    }
                } label: {
                    Label("삭제", systemImage: "trash")
                }
            }
        }
    }
    
    func formattedDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.MM.dd(EEE)"
        return formatter.string(from: date)
    }
    
    func calculateDDayText(from targetDate: Date) -> String {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let startOfTarget = calendar.startOfDay(for: targetDate)
        let components = calendar.dateComponents([.day], from: startOfToday, to: startOfTarget)
        let diff = components.day ?? 0
        
        if diff == 0 {
            return "오늘"
        } else if diff > 0 {
            return "D-\(diff)"
        } else {
            return "\(-diff + 1)일"
        }
    }
}
