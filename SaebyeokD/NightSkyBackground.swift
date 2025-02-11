//
//  NightSkyBackground.swift
//  SaebyeokD
//
//  Created by Saebyeok Jang on 2/11/25.
//

import SwiftUI

struct NightSkyBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.black, Color.blue.opacity(0.6)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}
