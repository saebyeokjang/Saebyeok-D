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

    var body: some View {
        ZStack {
            // 편집 화면으로 네비게이션 (화면에 보이지 않도록 EmptyView 사용)
            NavigationLink(destination: EditDDayView(event: event)) {
                EmptyView()
            }
            .opacity(0)

            HStack {
                // 왼쪽: 제목과 날짜 표시 (왼쪽 정렬)
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
                
                // 오른쪽: D-day 텍스트 표시
                Text(event.dDayText)
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
            // 스와이프 삭제 액션: 삭제 후 updateDDayWidget(with:) 함수 호출
            .swipeActions(edge: .trailing) {
                Button(role: .destructive) {
                    withAnimation {
                        modelContext.delete(event)
                        do {
                            try modelContext.save()
                            updateWidgetSharedData(modelContext: modelContext)
                            NotificationManager.shared.cancelNotification(for: event)
                        } catch {
                            print("삭제 실패: \(error)")
                        }
                    }
                } label: {
                    Label("삭제", systemImage: "trash")
                }
                .tint(Color(UIColor.darkGray))
            }
        }
    }
    
    // 날짜를 "yyyy.MM.dd(EEE)" 형식의 문자열로 변환하는 함수
    func formattedDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.MM.dd(EEE)"
        return formatter.string(from: date)
    }
}
