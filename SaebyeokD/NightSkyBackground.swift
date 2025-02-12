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
            Image("NightSky2")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: geometry.size.width, height: geometry.size.height)
                //.brightness(-0.1) // 어둡게
                .clipped()
        }
        .ignoresSafeArea()
    }
}
