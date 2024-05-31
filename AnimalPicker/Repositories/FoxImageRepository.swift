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

class RealFoxImageRepository: ImageRepository {
    typealias T = FoxImageResponse
    
    var network: BaseNetwork
    var baseUrl: String
    
    init(network: BaseNetwork, baseUrl: String) {
        self.network = network
        self.baseUrl = baseUrl
    }
    
    func getImage() -> AnyPublisher<T, Error> {
        return self.network.get("/floof", host: baseUrl)
    }
}
