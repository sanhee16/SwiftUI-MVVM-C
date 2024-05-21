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
    case c9 // 3x3
    case c15 // 3x5
    case c24 // 3x8
    case c30 // 3x10
    
    var row: Int {
        return 3
    }
    
    var column: Int {
        switch self {
        case .c9:
            return 3
        case .c15:
            return 5
        case .c24:
            return 8
        case .c30:
            return 10
        }
    }
}

enum Level: String {
    case easy = "Easy"
    case normal = "Normal"
    case hard = "Hard"
    case hell = "Hell"
    
    var cell: CellType {
        switch self {
        case .easy:
            return .c9
        case .normal:
            return .c15
        case .hard:
            return .c24
        case .hell:
            return .c30
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


struct GameItem: Equatable, Hashable {
    static func == (lhs: GameItem, rhs: GameItem) -> Bool {
        return lhs.id == rhs.id && lhs.url == rhs.url && lhs.isSelected == rhs.isSelected
    }
    
    let id: Int
    let type: ImageType
    let url: String
    var isSelected: Bool
}



