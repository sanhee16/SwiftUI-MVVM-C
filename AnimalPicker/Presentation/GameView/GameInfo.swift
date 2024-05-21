//
//  GameInfo.swift
//  AnimalPicker
//
//  Created by Sandy on 5/21/24.
//

import Foundation


enum ImageType {
    case dog
    case duck
    case fox
    case cat
    case bird
}

enum CellType {
    case m3x3
    case m5x5
    case m8x8
    case m12x12
    
    var count: Int {
        switch self {
        case .m3x3:
            return 3
        case .m5x5:
            return 5
        case .m8x8:
            return 8
        case .m12x12:
            return 12
        }
    }
}

enum Level {
    case easy
    case normal
    case hard
    case hell
    
    var cell: CellType {
        switch self {
        case .easy:
            return .m3x3
        case .normal:
            return .m5x5
        case .hard:
            return .m8x8
        case .hell:
            return .m12x12
        }
    }
    
    var timer: Int {
        switch self {
        case .easy:
            return 8
        case .normal:
            return 6
        case .hard:
            return 5
        case .hell:
            return 5
        }
    }
}


struct GameItem {
    let type: ImageType
    let url: String
    var isSelected: Bool
}



