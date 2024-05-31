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

class RealDogImageRepository: ImageRepository {
    typealias ImageResponsePublisher = AnyPublisher<DogImageResponse, Error>
    
    var network: BaseNetwork
    var baseUrl: String
    
    init(network: BaseNetwork, baseUrl: String) {
        self.network = network
        self.baseUrl = baseUrl
    }
    
    func getImage() -> AnyPublisher<DogImageResponse, Error> {
        return self.network.get("/breeds/image/random", host: baseUrl)
    }
}
