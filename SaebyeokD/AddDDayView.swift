//
//  AddDDayView.swift
//  SaebyeokD
//
//  Created by Saebyeok Jang on 2/7/25.
//

import SwiftUI
import SwiftData

struct AddDDayView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext  // SwiftData 모델 컨텍스트

    @State private var title: String = ""
    @State private var targetDate: Date = Date()

    var body: some View {
        Form {
            Section(header: Text("디데이 정보")) {
                TextField("제목", text: $title)
                DatePicker("날짜", selection: $targetDate, displayedComponents: .date)
            }
            
            Button("저장") {
                // 새로운 디데이 이벤트 생성 및 저장
                let newEvent = DDayEvent(title: title, targetDate: targetDate)
                modelContext.insert(newEvent)
                do {
                    try modelContext.save()
                } catch {
                    print("저장 실패: \(error)")
                }
                dismiss()
            }
            .disabled(title.isEmpty)  // 제목이 없으면 저장 버튼 비활성화
        }
        .navigationTitle("디데이 추가")
    }
}

#Preview {
    AddDDayView()
}
