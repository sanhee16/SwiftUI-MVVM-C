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
    var isUploaded: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case nickname = "nickname"
        case score = "score"
        case level = "level"
        case createdAt = "createdAt"
        case isUploaded = "isUploaded"
    }
    
    init(nickname: String, score: Int, level: Level, createdAt: Int, isUploaded: Bool = false) {
        self.id = ""
        self.nickname = nickname
        self.score = score
        self.level = level
        self.createdAt = createdAt
        self.isUploaded = isUploaded
    }
    
    init(id: String, nickname: String, score: Int, level: Level, createdAt: Int, isUploaded: Bool = false) {
        self.id = id
        self.nickname = nickname
        self.score = score
        self.level = level
        self.createdAt = createdAt
        self.isUploaded = isUploaded
    }
}
