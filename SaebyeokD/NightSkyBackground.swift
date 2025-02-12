//
//  NightSkyBackground.swift
//  SaebyeokD
//
//  Created by Saebyeok Jang on 2/11/25.
//

import SwiftUI

struct NightSkyBackground: View {
    var body: some View {
        GeometryReader { geometry in
            Image("NightSky")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .brightness(-0.2) // 값을 조정하여 어둡게 만듭니다.
                .clipped()
        }
        .ignoresSafeArea()
    }
}
