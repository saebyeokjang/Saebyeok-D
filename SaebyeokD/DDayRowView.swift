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
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(calculateDDayText(from: event.targetDate))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
            Spacer()
        }
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.black.opacity(0.3))
        )
        .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 3)
        // 스와이프 액션 추가
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                // 삭제 기능 구현
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
            return "D+\(-diff)"
        }
    }
}
