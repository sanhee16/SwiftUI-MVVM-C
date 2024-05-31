//
//  Encodable+Extension.swift
//  AnimalPicker
//
//  Created by Sandy on 5/30/24.
//

import Foundation

extension Encodable {
    func toDictionary() -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else {
            return nil
        }
        
        guard let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            return nil
        }
        
        return dictionary
    }
}
