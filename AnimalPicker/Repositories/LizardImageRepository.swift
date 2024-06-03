//
//  LizardImageRepository.swift
//  AnimalPicker
//
//  Created by Sandy on 5/23/24.
//

import Foundation
import Alamofire
import Combine

struct LizardImageResponse: ImageResponse {
    var imageUrl: String
    
    enum CodingKeys: String, CodingKey {
        case imageUrl = "url"
    }
}

class LizardImageRepository: ImageRepository {
    var network: BaseNetwork
    var baseUrl: String
    
    init(network: BaseNetwork, baseUrl: String) {
        self.network = network
        self.baseUrl = baseUrl
    }
    
    func getImage() -> AnyPublisher<String, Error> {
        return self.network.get("/img/lizard", host: baseUrl)
            .map { (response: LizardImageResponse) in response.imageUrl }
            .eraseToAnyPublisher()
    }
}
