//
//  DDayWidgetBundle.swift
//  DDayWidget
//
//  Created by Saebyeok Jang on 2/14/25.
//

import WidgetKit
import SwiftUI

//@main
struct DDayWidgetBundle: WidgetBundle {
    var body: some Widget {
        DDayWidget()
        DDayWidgetControl()
        DDayWidgetLiveActivity()
    }
}
