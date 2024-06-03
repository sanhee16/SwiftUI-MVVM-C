//
//  FoxImageRepository.swift
//  AnimalPicker
//
//  Created by Sandy on 5/21/24.
//

import Foundation
import Alamofire
import Combine

struct FoxImageResponse: ImageResponse {
    var imageUrl: String
    
    enum CodingKeys: String, CodingKey {
        case imageUrl = "image"
    }
}

class FoxImageRepository: ImageRepository {
    var network: BaseNetwork
    var baseUrl: String
    
    init(network: BaseNetwork, baseUrl: String) {
        self.network = network
        self.baseUrl = baseUrl
    }
    
    func getImage() -> AnyPublisher<String, Error> {
        return self.network.get("/floof", host: baseUrl)
            .map { (response: FoxImageResponse) in response.imageUrl }
            .eraseToAnyPublisher()
    }
}
