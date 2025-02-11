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
        HStack {
            // 왼쪽: 제목과 날짜
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(formattedDate(from: event.targetDate))
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            Spacer()
            // 오른쪽: D-day 텍스트
            Text(calculateDDayText(from: event.targetDate))
                .font(.title3)
                .foregroundColor(.white)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.black.opacity(0.3))
        )
        .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 3)
        // 스와이프 액션 (삭제)
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
    
    /// 날짜를 "Feb 8, 2025" 와 같이 medium 스타일로 변환
    func formattedDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    /// 오늘부터 targetDate까지 남은 일수에 따라 "오늘", "D-숫자", "D+숫자" 반환
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
            return "D+\(-diff + 1)"
        }
    }
}
