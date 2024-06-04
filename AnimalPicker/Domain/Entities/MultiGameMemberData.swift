//
//  MultiGameMemberData.swift
//  AnimalPicker
//
//  Created by Sandy on 6/3/24.
//

import Foundation

struct MultiGameMemberData: Codable, Identifiable, Hashable {
    var id: String
    var name: String
    var time: Float?
}
