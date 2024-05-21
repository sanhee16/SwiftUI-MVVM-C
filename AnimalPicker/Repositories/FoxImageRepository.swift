//
//  FoxImageRepository.swift
//  AnimalPicker
//
//  Created by Sandy on 5/21/24.
//

import Foundation
import Alamofire
import Combine

struct FoxImageResponse: Codable {
    var imageUrl: String
    
    enum CodingKeys: String, CodingKey {
        case imageUrl = "image"
    }
}

protocol FoxImageRepository {
    func getImage() -> AnyPublisher<FoxImageResponse, Error>
}

class RealFoxImageRepository: FoxImageRepository {
    var network: BaseNetwork
    var baseUrl: String
    
    init(network: BaseNetwork, baseUrl: String) {
        self.network = network
        self.baseUrl = baseUrl
    }
    
    func getImage() -> AnyPublisher<FoxImageResponse, Error> {
        return self.network.get("/floof", host: baseUrl)
    }
}
