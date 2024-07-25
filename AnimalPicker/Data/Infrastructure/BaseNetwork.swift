//
//  BaseNetwork.swift
//  AnimalPicker
//
//  Created by Sandy on 5/21/24.
//

import Foundation
import Combine
import Alamofire
import UIKit

class BaseNetwork {
    let session: Session = {
        //#if DEBUG
        let configuration = URLSessionConfiguration.af.default
        return Session(configuration: configuration)
    }()
    
    func request<T>(
        _ url: String,
        host: String,
        method: HTTPMethod,
        headers requestHeaders: [String: String]? = nil,
        parameters: Parameters? = nil,
        httpBody: Any? = nil
    ) -> AnyPublisher<T, Error> where T: Codable {
        let future: (() -> Deferred) = { () -> Deferred<Future<T, Error>> in
            var headers: HTTPHeaders = HTTPHeaders()
            headers.add(name: "Content-Type", value: "application/json")
            headers.add(name: "Content-Type", value: "application/octet-stream")
            headers.add(name: "Accept", value: "*/*")
            
            if let headerItems = requestHeaders {
                headerItems.forEach { (key: String, value: String) in
                    headers.add(name: key, value: value)
                }
            }
            
            return Deferred {
                Future<T, Error> { promise in
                    var request = self.session.request(
                        host + url,
                        method: method,
                        parameters: parameters,
                        encoding: URLEncoding.queryString,
                        headers: headers
                    )
                    
                    if let data = httpBody,
                       var req = try? request.convertible.asURLRequest() {
                        if let body = try? JSONSerialization.data(withJSONObject: data, options: []) {
                            req.httpBody = body
                        }
                        req.timeoutInterval = 1 * 60
                        request = AF.request(req)
                    }
                    
                    request.validate(statusCode: 200..<300)
                        .responseDecodable(queue: DispatchQueue.global(qos: .background), completionHandler: { (response: DataResponse<T, AFError>) in
                            switch response.result {
                            case .success(let value):
                                promise(.success(value))
                                break
                            case .failure(let e):
                                promise(.failure(e))
                                break
                            }
                        })
                }
            }
        }
        return future().eraseToAnyPublisher()
    }
}


extension BaseNetwork {
    func get<T>(_ url: String, host: String, parameters: Parameters? = nil) -> AnyPublisher<T, Error> where T: Codable {
        return request(url, host: host, method: .get, parameters: parameters, httpBody: nil)
            .eraseToAnyPublisher()
    }
}
