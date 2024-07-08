//
//  MultiGameMemberData.swift
//  AnimalPicker
//
//  Created by Sandy on 6/3/24.
//

import Foundation

struct MultiGameMemberData: Codable, Identifiable, Hashable {
    static func == (lhs: MultiGameMemberData, rhs: MultiGameMemberData) -> Bool {
        return lhs.id == rhs.id && lhs.status == rhs.status && lhs.name == rhs.name
    }

    var id: String
    var name: String
    var time: Float
    var status: String // MultiGameStatus.rawValue
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case time = "time"
        case status = "status"
    }
}


enum MultiGameStatus: String {
    case ready = "ready"
    case loading = "loading"
    case onGaming = "onGaming"
    case loadFinish = "loadFinish"
    case clear = "clear"
    case finish = "finish"
}
