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

    enum Tab: String, CaseIterable {
        case dday = "디데이"
        case settings = "설정"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                NightSkyBackground()

                VStack(spacing: 16) {
                    // 커스텀 탭 컨트롤
                    HStack {
                        ForEach(Tab.allCases, id: \.self) { tab in
                            Button {
                                withAnimation {
                                    selectedTab = tab
                                }
                            } label: {
                                VStack(spacing: 4) {
                                    Text(tab.rawValue)
                                        .foregroundColor(selectedTab == tab ? .white : .gray)
                                    // 선택된 탭일 때만 흰색 밑줄 표시
                                    Rectangle()
                                        .fill(selectedTab == tab ? Color.white : Color.clear)
                                        .frame(height: 2)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                    .background(Color.clear) // 전체 탭 배경을 투명하게 설정
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .padding(.top, 16)

                    // 탭에 따른 내용 표시
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
            .navigationTitle("새벽:D v0.02")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
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
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
