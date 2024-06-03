//
//  ImageRepository.swift
//  AnimalPicker
//
//  Created by Sandy on 6/3/24.
//

import Foundation
import Combine

protocol ImageResponse: Codable {
    var imageUrl: String { get set }
}

protocol ImageRepository {
    func getImage() -> AnyPublisher<String, Error>
}
