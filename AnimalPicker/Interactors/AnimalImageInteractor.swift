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
    func getDogImages(_ num: Int) -> AnyPublisher<[DogImageResponse], Error>
    func getFoxImages(_ num: Int) -> AnyPublisher<[FoxImageResponse], Error>
    
}

struct RealAnimalImageInteractor: AnimalImageInteractor {
    let foxImageRepository: FoxImageRepository
    let dogImageRepository: DogImageRepository
    
    
    func getDogImages(_ num: Int) -> AnyPublisher<[DogImageResponse], any Error> {
        return Publishers.Sequence(sequence: Array(repeating: self.dogImageRepository.getImage(), count: num))
            .flatMap { $0 }
            .collect()
            .eraseToAnyPublisher()
    }
    
    func getFoxImages(_ num: Int) -> AnyPublisher<[FoxImageResponse], any Error> {
        return Publishers.Sequence(sequence: Array(repeating: self.foxImageRepository.getImage(), count: num))
            .flatMap { $0 }
            .collect()
            .eraseToAnyPublisher()
    }
    
    
}
