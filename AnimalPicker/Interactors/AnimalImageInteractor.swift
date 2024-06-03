//
//  AnimalImageInteractor.swift
//  AnimalPicker
//
//  Created by Sandy on 5/21/24.
//

import Foundation
import Combine
import Alamofire


protocol AnimalImageInteractor {
    func getFoxImages(_ num: Int?) -> AnyPublisher<[ImageResponse], Error>
    func getDogImages(_ num: Int?) -> AnyPublisher<[ImageResponse], Error>
    func getDuckImages(_ num: Int?) -> AnyPublisher<[ImageResponse], Error>
    func getLizardImages(_ num: Int?) -> AnyPublisher<[ImageResponse], Error>
}

struct RealAnimalImageInteractor: AnimalImageInteractor {
    var foxImageRepository: any ImageRepository
    var dogImageRepository: any ImageRepository
    var duckImageRepository: any ImageRepository
    var lizardIamgeRepository: any ImageRepository
    
    func getFoxImages(_ num: Int?) -> AnyPublisher<[ImageResponse], any Error> {
        return getImages(num, repo: foxImageRepository)
    }
    
    func getDogImages(_ num: Int?) -> AnyPublisher<[ImageResponse], any Error> {
        return getImages(num, repo: dogImageRepository)
    }
    
    func getDuckImages(_ num: Int?) -> AnyPublisher<[ImageResponse], any Error> {
        return getImages(num, repo: duckImageRepository)
    }
    
    func getLizardImages(_ num: Int?) -> AnyPublisher<[ImageResponse], any Error> {
        return getImages(num, repo: lizardIamgeRepository)
    }
    
    private func getImages(_ num: Int?, repo: some ImageRepository) -> AnyPublisher<[ImageResponse], any Error> {
        guard let num = num else {
            return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        
        return Publishers.Sequence(sequence: Array(repeating: repo.getImage().map { $0 as ImageResponse }, count: num))
            .flatMap { $0 }
            .collect()
            .eraseToAnyPublisher()
    }
    
}
