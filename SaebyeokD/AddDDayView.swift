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
    @Environment(\.modelContext) var modelContext

    @State private var title: String = ""
    @State private var targetDate: Date = Date()

    var body: some View {
        ZStack {
            // 전체 배경으로 NightSkyBackground 적용
            NightSkyBackground()
                .ignoresSafeArea()

            // Form의 기본 배경을 숨김
            Form {
                Section(header: Text("디데이 정보")) {
                    TextField("제목", text: $title)
                    DatePicker("날짜", selection: $targetDate, displayedComponents: .date)
                }
                
                Button("저장") {
                    let newEvent = DDayEvent(title: title, targetDate: targetDate)
                    modelContext.insert(newEvent)
                    do {
                        try modelContext.save()
                    } catch {
                        print("저장 실패: \(error)")
                    }
                    dismiss()
                }
                .disabled(title.isEmpty)
            }
            .scrollContentBackground(.hidden)  // 기본 배경 숨김
            .background(Color.clear)           // 명시적으로 투명 배경 설정
        }
        .navigationTitle("디데이 추가")
    }
}

#Preview {
    AddDDayView()
}
