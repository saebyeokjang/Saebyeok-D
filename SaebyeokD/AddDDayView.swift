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
    @State private var showErrorAlert = false
    
    var body: some View {
        ZStack {
            NightSkyBackground()
                .ignoresSafeArea()
            
            Form {
                Section(header: Text("디데이 정보")) {
                    ZStack(alignment: .leading) {
                        if title.isEmpty {
                            Text("제목").foregroundColor(.gray)
                        }
                        TextField("", text: $title).foregroundColor(.white)
                    }
                    DatePicker("날짜", selection: $targetDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .tint(.white)
                        .colorScheme(.dark)
                }
                .foregroundStyle(Color.white)
                .listRowBackground(Color.black.opacity(0.3))
                .font(.custom("NIXGONM-Vb", size: 18))
                
                Button(action: {
                    let newEvent = DDayEvent(title: title, targetDate: targetDate)
                    modelContext.insert(newEvent)
                    do {
                        try modelContext.save()
                        updateDDayWidget(with: newEvent)
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    } catch {
                        print("저장 실패: \(error)")
                        showErrorAlert = true
                    }
                    dismiss()
                }) {
                    HStack {
                        Spacer()
                        Text("추가")
                            .font(.custom("NIXGONM-Vb", size: 18))
                            .foregroundColor(.white)
                        Spacer()
                    }
                }
                .alert("저장 실패", isPresented: $showErrorAlert) {
                    Button("확인", role: .cancel) { }
                }
                .foregroundStyle(Color.white)
                .font(.custom("NIXGONB-Vb", size: 20))
                .disabled(title.isEmpty)
                .listRowBackground(Color.black.opacity(0.3))
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
        .navigationTitle("디데이 추가")
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

#Preview {
    AddDDayView()
}
