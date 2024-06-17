//
//  RoomData.swift
//  AnimalPicker
//
//  Created by Sandy on 6/3/24.
//

import Foundation

struct RoomData: Codable, Identifiable, Hashable {
    typealias MemberId = String
    var id: String
    var name: String
    var password: Int?
    var status: String
    var managerId: String
    var members: [MemberId: MultiGameMemberData]?
    var items: [GameItem]?
    var answer: String?
}
