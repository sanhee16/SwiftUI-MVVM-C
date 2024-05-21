//
//  ApiRepository.swift
//  AnimalPicker
//
//  Created by Sandy on 5/21/24.
//

import Foundation
import Alamofire
import Combine

protocol ApiRepository {
    var baseUrl: String { get set }
    var network: BaseNetwork { get set }
}

class RealApiRepository: ApiRepository {
    var baseUrl: String
    var network: BaseNetwork
    
    init(url: String) {
        self.baseUrl = url
        self.network = BaseNetwork()
    }
}
