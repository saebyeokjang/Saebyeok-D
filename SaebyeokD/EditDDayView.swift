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
    
    init(event: DDayEvent) {
        self.event = event
        _title = State(initialValue: event.title)
        _targetDate = State(initialValue: event.targetDate)
    }
    
    var body: some View {
        ZStack {
            NightSkyBackground()
                .ignoresSafeArea()
            
            Form {
                Section(header: Text("디데이 정보").foregroundStyle(Color.white)) {
                    TextField("제목", text: $title)
                    DatePicker("날짜", selection: $targetDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .tint(.white)
                        .colorScheme(.dark)
                }
                .foregroundStyle(Color.white)
                .listRowBackground(Color.black.opacity(0.3))
                .font(.custom("NIXGONM-Vb", size: 18))
                
                Button(action: {
                    event.title = title
                    event.targetDate = targetDate
                    do {
                        try modelContext.save()
                        updateDDayWidget(with: event)
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
}
