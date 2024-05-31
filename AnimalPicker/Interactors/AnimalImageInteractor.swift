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
    func getFoxImages(_ num: Int?) -> AnyPublisher<[FoxImageResponse], Error>
    func getDogImages(_ num: Int?) -> AnyPublisher<[DogImageResponse], Error>
    func getDuckImages(_ num: Int?) -> AnyPublisher<[DuckImageResponse], Error>
    func getLizardImages(_ num: Int?) -> AnyPublisher<[LizardImageResponse], Error>
}

struct RealAnimalImageInteractor<
    FoxRepo: ImageRepository,
    DogRepo: ImageRepository,
    DuckRepo: ImageRepository,
    LizardRepo: ImageRepository
>: AnimalImageInteractor {
    var foxImageRepository: FoxRepo
    var dogImageRepository: DogRepo
    var duckImageRepository: DuckRepo
    var lizardIamgeRepository: LizardRepo
    
    func getFoxImages(_ num: Int?) -> AnyPublisher<[FoxImageResponse], any Error> {
        guard let num = num else {
            return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        
        return Publishers.Sequence(sequence: Array(repeating: self.foxImageRepository.getImage().map { $0 as! FoxImageResponse }, count: num))
            .flatMap { $0 }
            .collect()
            .eraseToAnyPublisher()
    }
    
    func getDogImages(_ num: Int?) -> AnyPublisher<[DogImageResponse], any Error> {
        guard let num = num else {
            // Just 연산자는 에러를 발생시키지 않으므로, 반환 타입을 맞추기 위해 setFailureType 연산자를 사용하여 에러 타입을 설정해야 한다.
            return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        return Publishers.Sequence(sequence: Array(repeating: self.dogImageRepository.getImage().map { $0 as! DogImageResponse }, count: num))
            .flatMap { $0 }
            .collect()
            .eraseToAnyPublisher()
    }
    
    func getDuckImages(_ num: Int?) -> AnyPublisher<[DuckImageResponse], any Error> {
        guard let num = num else {
            // Just 연산자는 에러를 발생시키지 않으므로, 반환 타입을 맞추기 위해 setFailureType 연산자를 사용하여 에러 타입을 설정해야 한다.
            return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        return Publishers.Sequence(sequence: Array(repeating: self.duckImageRepository.getImage().map { $0 as! DuckImageResponse }, count: num))
            .flatMap { $0 }
            .collect()
            .eraseToAnyPublisher()
    }
    
    func getLizardImages(_ num: Int?) -> AnyPublisher<[LizardImageResponse], any Error> {
        guard let num = num else {
            // Just 연산자는 에러를 발생시키지 않으므로, 반환 타입을 맞추기 위해 setFailureType 연산자를 사용하여 에러 타입을 설정해야 한다.
            return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        return Publishers.Sequence(sequence: Array(repeating: self.lizardIamgeRepository.getImage().map { $0 as! LizardImageResponse }, count: num))
            .flatMap { $0 }
            .collect()
            .eraseToAnyPublisher()
    }
    
}
