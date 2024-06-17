//
//  SDError.swift
//  AnimalPicker
//
//  Created by Sandy on 6/17/24.
//

import Foundation

struct SDError: Codable, Error {
    let code: String?
    let message: String
    
    init(code: String? = nil, message: String) {
        self.code = code
        self.message = message
    }
}

