//
//  AnimalImageInteractor.swift
//  AnimalPicker
//
//  Created by Sandy on 5/21/24.
//

import Foundation
import Combine
import Alamofire
import SwiftUI

enum GameGenerateError: Error {
    case unknown
}

protocol AnimalImageInteractor {
    func changeScore(score: Binding<Int>)
    
    func getFoxImages(_ num: Int?) -> AnyPublisher<[ImageResponse], Error>
    func getDogImages(_ num: Int?) -> AnyPublisher<[ImageResponse], Error>
    func getDuckImages(_ num: Int?) -> AnyPublisher<[ImageResponse], Error>
    func getLizardImages(_ num: Int?) -> AnyPublisher<[ImageResponse], Error>
    func selectSingleGameItem(singleGameInfo: SingleGameInfo) -> SingleGameInfo
    func generateGameItems(level: Level) -> AnyPublisher<GameInfo, Error>
}

class RealAnimalImageInteractor: AnimalImageInteractor {
    var subscription: Set<AnyCancellable> = Set<AnyCancellable>()
    
    var foxImageRepository: any ImageRepository
    var dogImageRepository: any ImageRepository
    var duckImageRepository: any ImageRepository
    var lizardIamgeRepository: any ImageRepository
    
    init(foxImageRepository: any ImageRepository, dogImageRepository: any ImageRepository, duckImageRepository: any ImageRepository, lizardIamgeRepository: any ImageRepository) {
        self.foxImageRepository = foxImageRepository
        self.dogImageRepository = dogImageRepository
        self.duckImageRepository = duckImageRepository
        self.lizardIamgeRepository = lizardIamgeRepository
    }
    
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
    
    func changeScore(score: Binding<Int>) {
        score.wrappedValue += 1
    }
    
    func selectSingleGameItem(singleGameInfo: SingleGameInfo) -> SingleGameInfo {
        var info = singleGameInfo
        
        guard let idx = info.gameList.firstIndex(where: { $0.id == info.selectItem.id }) else { return singleGameInfo }
        info.gameList[idx].isSelected.toggle()
        
        // 답 맞춤
        if info.gameList[idx].isSelected, ImageType(rawValue: info.gameList[idx].type) == info.answer {
            info.bonusCount += 1
            if info.bonusCount == 5 {
                info.bonusScore += info.level.point
                info.bonusCount = 0
            }
        } else {
            info.bonusCount = 0
        }
        
        if info.gameList.filter({ $0.type == info.answer.rawValue && !$0.isSelected }).isEmpty
            && info.gameList.filter({ $0.type != info.answer.rawValue && $0.isSelected }).isEmpty {
            info.isFinish = true
        }
        return info
    }
    
    
    func generateGameItems(level: Level) -> AnyPublisher<GameInfo, Error> {
        let types: [ImageType] = [.dog, .fox, .duck, .lizard]
        func distributeTotalCount(totalCount: Int, into n: Int) -> [Int] {
            guard n > 0, totalCount >= n else { return [] }
            
            
            var result: [Int] = []

            // 동물당 나올 수 있는 갯수
            let maxValue = totalCount / types.count
            var remainingCount = totalCount
            
            for _ in 1..<n {
//                let maxPossibleValue = remainingCount - (n - result.count)
//                let randomValue = Int.random(in: 1...maxPossibleValue)
                result.append(maxValue)
                remainingCount -= maxValue
            }
            
            // 마지막 남은 수를 결과 배열에 추가하여 totalCount와 동일하게 만듦
            result.append(remainingCount)
            
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
                        
                        // 이미지 url insert 끝!
                        items.shuffle()
                        if let answer = types.randomElement() ?? types.first {
                            promise(.success(GameInfo(answer: answer, items: items)))
                        } else {
                            promise(.failure(SDError(message: "no answer")))
                        }
                    }
                    
                }
            }
        }
        return future().eraseToAnyPublisher()
    }
}
