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
    
    var event: DDayEvent
    
    @State private var title: String
    @State private var targetDate: Date
    
    // 초기화 시 전달받은 event의 값을 state에 할당
    init(event: DDayEvent) {
        self.event = event
        _title = State(initialValue: event.title)
        _targetDate = State(initialValue: event.targetDate)
    }
    
    var body: some View {
        ZStack {
            // 배경 적용
            NightSkyBackground()
                .ignoresSafeArea()
            
            Form {
                Section(header: Text("디데이 정보").foregroundStyle(Color.white)) {
                    TextField("제목", text: $title)
                    DatePicker("날짜", selection: $targetDate, displayedComponents: .date)
                }
                
                Button("저장") {
                    // 이벤트 업데이트
                    event.title = title
                    event.targetDate = targetDate
                    
                    do {
                        try modelContext.save()
                    } catch {
                        print("저장 실패: \(error)")
                    }
                    dismiss()
                }
                .disabled(title.isEmpty)
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
        .navigationTitle("디데이 편집")
    }
}

#Preview {
    // 미리보기를 위한 더미 이벤트 생성
    let dummyEvent = DDayEvent(title: "생일", targetDate: Date())
    return NavigationStack {
        EditDDayView(event: dummyEvent)
    }
}
