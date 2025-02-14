//
//  ContentView.swift
//  SaebyeokD
//
//  Created by Saebyeok Jang on 2/7/25.
//

import SwiftUI

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
                    tabSelector
                    
                    // 애니메이션을 없애기 위해 ZStack을 VStack으로 변경
                    VStack {
                        if selectedTab == .dday {
                            DDayListView()
                        } else {
                            SettingsView()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                }
                .navigationTitle("새벽:D")
                .navigationBarTitleDisplayMode(.large)
                .onAppear {
                    setupNavigationBarAppearance()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if selectedTab == .dday {
                        NavigationLink(destination: AddDDayView()) {
                            Text("디데이 추가")
                                .font(customFont(size: 18))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
    }
    
    private var tabSelector: some View {
        HStack {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    VStack(spacing: 4) {
                        Text(tab.rawValue)
                            .font(customFont(size: 18))
                            .foregroundColor(selectedTab == tab ? .white : .gray)
                        Rectangle()
                            .fill(Color.white)
                            .opacity(selectedTab == tab ? 1 : 0)
                            .frame(height: 2)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.top, 16)
    }
    
    private func customFont(size: CGFloat) -> Font {
        Font.custom("NIXGONM-Vb", size: size, relativeTo: .body)
    }
    
    private func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "NIXGONM-Vb", size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .bold)
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "NIXGONM-Vb", size: 36) ?? UIFont.systemFont(ofSize: 36, weight: .bold)
        ]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    ContentView()
}
