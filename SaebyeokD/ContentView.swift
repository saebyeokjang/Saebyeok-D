//
//  ContentView.swift
//  SaebyeokD
//
//  Created by Saebyeok Jang on 2/7/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab: Tab = .dday

    enum Tab: Hashable {
        case dday, settings
    }

    var body: some View {
        NavigationStack {
            ZStack {
                NightSkyBackground()  // 재사용 가능한 배경 적용

                VStack(spacing: 16) {
                    Picker("", selection: $selectedTab) {
                        Text("디데이").tag(Tab.dday)
                        Text("설정").tag(Tab.settings)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .padding(.top, 16)

                    ZStack {
                        if selectedTab == .dday {
                            DDayListView()
                                .transition(.move(edge: .trailing))
                        } else if selectedTab == .settings {
                            SettingsView()
                                .transition(.move(edge: .leading))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                    .animation(nil, value: selectedTab)
                }
            }
            .navigationTitle("새벽:D")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                // 내비게이션 바 외관 설정 (타이틀 텍스트를 흰색으로)
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = .clear
                appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
                appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddDDayView()) {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white) // 글씨(심볼) 색상을 흰색으로 설정
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
