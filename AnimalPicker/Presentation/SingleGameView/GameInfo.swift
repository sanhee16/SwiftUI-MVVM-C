//
//  GameInfo.swift
//  AnimalPicker
//
//  Created by Sandy on 5/21/24.
//

import Foundation
import SwiftUI

struct GameInfo {
    var answer: ImageType
    var items: [GameItem]
}

enum ImageType: String, Codable {
    case dog
    case duck
    case fox
    case cat
    case bird
    case lizard
    
    var plural: String {
        switch self {
        case .dog:
            return "dogs"
        case .duck:
            return "ducks"
        case .fox:
            return "foxes"
        case .cat:
            return "cats"
        case .bird:
            return "birds"
        case .lizard:
            return "lizards"
        }
    }
}

enum CellType {
    case c9 
    case c15
    case c24
    case c30
    case c100
    
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
        case .c100:
            return 25
        }
    }
}

enum Level: String, Codable {
    case easy = "Easy"
    case normal = "Normal"
    case hard = "Hard"
    case hell = "Hell"
    case multi = "Multi"
    
    var point: Int {
        return 10
    }
    
    var levelInt: Int {
        switch self {
        case .easy:
            return 0
        case .normal:
            return 1
        case .hard:
            return 2
        case .hell:
            return 3
        case .multi:
            return 4
        }
    }
    
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
        case .multi:
            return .c100
        }
    }
    
    var timer: Int {
        switch self {
        case .easy:
            return 9
        case .normal:
            return 8
        case .hard:
            return 8
        case .hell:
            return 7
        case .multi:
            return -1
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .easy:
            return .yellow
        case .normal:
            return .green
        case .hard:
            return .blue
        case .hell:
            return .red
        case .multi:
            return .purple
        }
    }
    
    var buttonImage: String {
        switch self {
        case .easy:
            return "ButtonText_Large_Square_Yellow"
        case .normal:
            return "ButtonText_Large_Square_Green"
        case .hard:
            return "ButtonText_Large_Square_Blue"
        case .hell:
            return "ButtonText_Large_Square_Red"
        case .multi:
            return "ButtonText_Large_Square_Orange"
        }
    }
}


struct GameItem: Codable, Equatable, Hashable {
    static func == (lhs: GameItem, rhs: GameItem) -> Bool {
        return lhs.id == rhs.id && lhs.url == rhs.url && lhs.isSelected == rhs.isSelected
    }
    
    let id: Int
    let type: String
    let url: String
    var isSelected: Bool
    var isLoaded: Bool
    
    init(id: Int, type: ImageType, url: String, isSelected: Bool = false) {
        self.id = id
        self.type = type.rawValue
        self.url = url
        self.isSelected = isSelected
        self.isLoaded = false
    }
    
    init(id: Int, type: String, url: String) {
        self.id = id
        self.type = type
        self.url = url
        self.isSelected = false
        self.isLoaded = false
    }
}



