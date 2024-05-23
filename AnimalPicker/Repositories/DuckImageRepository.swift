//
//  DuckImageRepository.swift
//  AnimalPicker
//
//  Created by Sandy on 5/23/24.
//

import Foundation
import Alamofire
import Combine

struct DuckImageResponse: Codable {
    var imageUrl: String
    
    enum CodingKeys: String, CodingKey {
        case imageUrl = "url"
    }
}

protocol DuckImageRepository {
    func getImage() -> AnyPublisher<DuckImageResponse, Error>
}

class RealDuckImageRepository: DuckImageRepository {
    var network: BaseNetwork
    var baseUrl: String
    
    init(network: BaseNetwork, baseUrl: String) {
        self.network = network
        self.baseUrl = baseUrl
    }
    
    func getImage() -> AnyPublisher<DuckImageResponse, Error> {
        return self.network.get("/random?type=png", host: baseUrl)
    }
}
