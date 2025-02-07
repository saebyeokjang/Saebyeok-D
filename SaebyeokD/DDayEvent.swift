//
//  DDayEvent.swift
//  SaebyeokD
//
//  Created by Saebyeok Jang on 2/7/25.
//

import Foundation
import SwiftData

@Model
class DDayEvent: Identifiable {
    var id = UUID()
    var title: String
    var targetDate: Date

    init(title: String, targetDate: Date) {
        self.title = title
        self.targetDate = targetDate
    }
}
