//
//  SortOption.swift
//  SaebyeokD
//
//  Created by Saebyeok Jang on 3/18/25.
//

import Foundation

// 정렬 옵션을 위한 열거형 (수정됨)
enum SortOption: String, CaseIterable {
    case targetDateAscending = "targetDateAscending"
    case targetDateDescending = "targetDateDescending"
    case userDefined = "userDefined"
    
    // 표시 이름
    var displayName: String {
        switch self {
        case .targetDateAscending:
            return "날짜 오름차순"
        case .targetDateDescending:
            return "날짜 내림차순"
        case .userDefined:
            return "사용자 지정 순서"
        }
    }
    
    // 표시 아이콘
    var iconName: String {
        switch self {
        case .targetDateAscending:
            return "calendar.badge.clock"
        case .targetDateDescending:
            return "calendar.badge.exclamationmark"
        case .userDefined:
            return "arrow.up.arrow.down"
        }
    }
}
