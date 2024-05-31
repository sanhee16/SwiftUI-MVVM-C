//
//  ImageRepository.swift
//  AnimalPicker
//
//  Created by Sandy on 5/31/24.
//

import Foundation
import Combine

protocol ImageResponse: Codable {
    var imageUrl: String { get set }
}

protocol ImageRepository {
    associatedtype T
    
    func getImage() -> AnyPublisher<T, Error>
}
