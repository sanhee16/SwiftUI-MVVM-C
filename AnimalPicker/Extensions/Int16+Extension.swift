//
//  Int16+Extension.swift
//  AnimalPicker
//
//  Created by Sandy on 5/30/24.
//

import Foundation

extension Int16 {
    var getLevel: Level {
        switch self {
        case 0: return .easy
        case 1: return .normal
        case 2: return .hard
        case 3: return .hell
        default: return .easy
        }
    }
}
