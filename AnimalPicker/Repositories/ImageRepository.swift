//
//  ImageRepository.swift
//  AnimalPicker
//
//  Created by robert on 6/3/24.
//

import Foundation
import Alamofire
import Combine

struct ImageResponse: Codable {
    var imageUrl: String
    
    init(imageUrl: String) {
        self.imageUrl = imageUrl
    }
    
    private enum CustomCodingKeys: String, CodingKey {
        case image = "image"
        case url = "url"
        case message = "message"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CustomCodingKeys.self)
        
        if let imageUrl = try container.decodeIfPresent(String.self, forKey: .image) {
            self.imageUrl = imageUrl
        } else if let imageUrl = try container.decodeIfPresent(String.self, forKey: .url) {
            self.imageUrl = imageUrl
        } else if let imageUrl = try container.decodeIfPresent(String.self, forKey: .message) {
            self.imageUrl = imageUrl
        } else {
            self.imageUrl = ""
        }
    }
}

protocol ImageRepository {
    var network: BaseNetwork { get set }
    var networkUrl: NetworkUrl { get set }
    
    init(network: BaseNetwork, networkUrl: NetworkUrl)
    
    func getImage() -> AnyPublisher<ImageResponse, Error>
}

class ImageRepositoryImpl: ImageRepository {
    var network: BaseNetwork
    var networkUrl: NetworkUrl
    
    required init(network: BaseNetwork, networkUrl: NetworkUrl) {
        self.network = network
        self.networkUrl = networkUrl
    }
    
    func getImage() -> AnyPublisher<ImageResponse, Error> {
        return self.network.get(networkUrl.imagePath, host: networkUrl.baseUrl)
    }
}

struct NetworkUrl {
    let baseUrl: String
    let imagePath: String
}
