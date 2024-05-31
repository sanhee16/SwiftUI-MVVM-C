//
//  RankingData.swift
//  AnimalPicker
//
//  Created by Sandy on 5/27/24.
//

import Foundation

struct RankingData: Identifiable, Hashable, Codable {
    var id: String
    var nickname: String
    var score: Int
    var level: Level
    var createdAt: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case nickname = "nickname"
        case score = "score"
        case level = "level"
        case createdAt = "createdAt"
    }
    
    init(nickname: String, score: Int, level: Level, createdAt: Int) {
        self.id = ""
        self.nickname = nickname
        self.score = score
        self.level = level
        self.createdAt = createdAt
    }
    
    init(id: String, nickname: String, score: Int, level: Level, createdAt: Int) {
        self.id = id
        self.nickname = nickname
        self.score = score
        self.level = level
        self.createdAt = createdAt
    }
}
