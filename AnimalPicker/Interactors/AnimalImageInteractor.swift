//
//  AnimalImageInteractor.swift
//  AnimalPicker
//
//  Created by Sandy on 5/21/24.
//

import Foundation
import Combine
import Alamofire

enum GameGenerateError: Error {
    case unknown
}

protocol AnimalImageInteractor {
    func getDogImages(_ num: Int?) -> AnyPublisher<[DogImageResponse], Error>
    func getFoxImages(_ num: Int?) -> AnyPublisher<[FoxImageResponse], Error>
    func getDuckImages(_ num: Int?) -> AnyPublisher<[DuckImageResponse], Error>
    func getLizardImages(_ num: Int?) -> AnyPublisher<[LizardImageResponse], Error>
    func generateGameItems(level: Level) -> AnyPublisher<GameInfo, Error>
}

class RealAnimalImageInteractor: AnimalImageInteractor {
    private var subscription = Set<AnyCancellable>()
    
    let foxImageRepository: FoxImageRepository
    let dogImageRepository: DogImageRepository
    let duckImageRepository: DuckImageRepository
    let lizardIamgeRepository: LizardImageRepository
    
    init(foxImageRepository: FoxImageRepository, dogImageRepository: DogImageRepository, duckImageRepository: DuckImageRepository, lizardIamgeRepository: LizardImageRepository) {
        self.foxImageRepository = foxImageRepository
        self.dogImageRepository = dogImageRepository
        self.duckImageRepository = duckImageRepository
        self.lizardIamgeRepository = lizardIamgeRepository
    }
    
    func getFoxImages(_ num: Int?) -> AnyPublisher<[FoxImageResponse], any Error> {
        guard let num = num else {
            return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        return Publishers.Sequence(sequence: Array(repeating: self.foxImageRepository.getImage(), count: num))
            .flatMap { $0 }
            .collect()
            .eraseToAnyPublisher()
    }
    
    func getDogImages(_ num: Int?) -> AnyPublisher<[DogImageResponse], any Error> {
        guard let num = num else {
            // Just 연산자는 에러를 발생시키지 않으므로, 반환 타입을 맞추기 위해 setFailureType 연산자를 사용하여 에러 타입을 설정해야 한다.
            return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        return Publishers.Sequence(sequence: Array(repeating: self.dogImageRepository.getImage(), count: num))
            .flatMap { $0 }
            .collect()
            .eraseToAnyPublisher()
    }
    
    func getDuckImages(_ num: Int?) -> AnyPublisher<[DuckImageResponse], any Error> {
        guard let num = num else {
            // Just 연산자는 에러를 발생시키지 않으므로, 반환 타입을 맞추기 위해 setFailureType 연산자를 사용하여 에러 타입을 설정해야 한다.
            return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        return Publishers.Sequence(sequence: Array(repeating: self.duckImageRepository.getImage(), count: num))
            .flatMap { $0 }
            .collect()
            .eraseToAnyPublisher()
    }
    
    func getLizardImages(_ num: Int?) -> AnyPublisher<[LizardImageResponse], any Error> {
        guard let num = num else {
            // Just 연산자는 에러를 발생시키지 않으므로, 반환 타입을 맞추기 위해 setFailureType 연산자를 사용하여 에러 타입을 설정해야 한다.
            return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        return Publishers.Sequence(sequence: Array(repeating: self.lizardIamgeRepository.getImage(), count: num))
            .flatMap { $0 }
            .collect()
            .eraseToAnyPublisher()
    }
    
    func generateGameItems(level: Level) -> AnyPublisher<GameInfo, Error> {
        let types: [ImageType] = [.dog, .fox, .duck, .lizard]
        func distributeTotalCount(totalCount: Int, into n: Int) -> [Int] {
            guard n > 0, totalCount >= n else { return [] }
            
            var result: [Int] = []
            var remainingCount = totalCount - types.count
            
            for _ in 1..<n {
                let maxPossibleValue = remainingCount - (n - result.count)
                let randomValue = Int.random(in: 1...maxPossibleValue)
                result.append(randomValue + 1)
                remainingCount -= randomValue
            }
            
            // 마지막 남은 수를 결과 배열에 추가하여 totalCount와 동일하게 만듦
            result.append(remainingCount + 1)
            
            return result
        }
        
        let future: (() -> Deferred) = { () -> Deferred<Future<GameInfo, Error>> in
            return Deferred {
                Future<GameInfo, Error> {[weak self] promise in
                    guard let self = self else { return promise(.failure(GameGenerateError.unknown)) }
                    var countWithType: [ImageType: Int] = [:]
                    var items: [GameItem] = []
                    let totalCount = level.cell.row * level.cell.column
                    let distributeTotalCount = distributeTotalCount(totalCount: totalCount, into: types.count)
                    
                    types.indices.forEach({
                        countWithType.updateValue(distributeTotalCount[$0], forKey: types[$0])
                    })
                    if countWithType.isEmpty { return promise(.failure(GameGenerateError.unknown))}
                    
                    Publishers.Zip4(
                        self.getDogImages(countWithType[.dog]),
                        self.getFoxImages(countWithType[.fox]),
                        self.getDuckImages(countWithType[.duck]),
                        self.getLizardImages(countWithType[.lizard])
                    )
                    .run(in: &self.subscription) { (dogs, foxes, ducks, lizards) in
                        var idx: Int = 0
                        items.removeAll()
                        
                        dogs.forEach {
                            items.append(GameItem(id: idx, type: .dog, url: $0.imageUrl))
                            idx += 1
                        }
                        foxes.forEach {
                            items.append(GameItem(id: idx, type: .fox, url: $0.imageUrl))
                            idx += 1
                        }
                        ducks.forEach {
                            items.append(GameItem(id: idx, type: .duck, url: $0.imageUrl))
                            idx += 1
                        }
                        lizards.forEach {
                            items.append(GameItem(id: idx, type: .lizard, url: $0.imageUrl))
                            idx += 1
                        }
                        
                        // 이미지 로드 끝!
                        items.shuffle()
                        let answer = types.randomElement() ?? types.first
                        promise(.success(GameInfo(answer: answer!, items: items)))
                    }
                    
                }
            }
        }
        return future().eraseToAnyPublisher()
    }
}
