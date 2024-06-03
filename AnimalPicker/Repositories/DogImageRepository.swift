//
//  DogImageRepository.swift
//  AnimalPicker
//
//  Created by Sandy on 5/21/24.
//

import Foundation
import Alamofire
import Combine

struct DogImageResponse: ImageResponse {
    var imageUrl: String
    
    enum CodingKeys: String, CodingKey {
        case imageUrl = "message"
    }
}

class DogImageRepository: ImageRepository {
    var network: BaseNetwork
    var baseUrl: String
    
    init(network: BaseNetwork, baseUrl: String) {
        self.network = network
        self.baseUrl = baseUrl
    }
    
    func getImage() -> AnyPublisher<String, Error> {
        return self.network.get("/breeds/image/random", host: baseUrl)
            .map { (response: DogImageResponse) in response.imageUrl }
            .eraseToAnyPublisher()
    }
}
