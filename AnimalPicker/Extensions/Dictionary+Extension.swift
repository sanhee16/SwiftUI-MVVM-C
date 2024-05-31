//
//  Dictionary+Extension.swift
//  AnimalPicker
//
//  Created by Sandy on 5/30/24.
//

import Foundation

extension Dictionary where Key == String, Value == Any {
    func decode<T: Codable>() throws -> T {
        let data = try JSONSerialization.data(withJSONObject: self, options: [])
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}
