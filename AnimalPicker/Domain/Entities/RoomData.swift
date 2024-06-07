//
//  RoomData.swift
//  AnimalPicker
//
//  Created by Sandy on 6/3/24.
//

import Foundation

struct RoomData: Codable, Identifiable, Hashable {
    var id: String
    var name: String
    var password: Int?
    var status: String
    var managerDeviceId: String
    var memberIds: [String]?
    var items: [String]?
}
