//
//  SingleGameInfo.swift
//  AnimalPicker
//
//  Created by Sandy on 6/24/24.
//

import Foundation

struct SingleGameInfo {
    var gameList: [GameItem]
    var selectItem: GameItem
    var answer: ImageType
    var level: Level
    var bonusCount: Int
    var bonusScore: Int
}
