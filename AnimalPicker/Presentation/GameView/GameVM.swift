//
//  GameVM.swift
//  AnimalPicker
//
//  Created by Sandy on 5/21/24.
//

import Foundation
import Combine
import UIKit

class GameVM: BaseViewModel {
    private let interactors: DIContainer.Interactors
    let level: Level
    let types: [ImageType] = [.dog, .fox]
    var countWithType: [ImageType: Int] = [:]
    var results: [GameItem] = []
    
    
    init(_ coordinator: AppCoordinator, interactors: DIContainer.Interactors, level: Level) {
        self.interactors = interactors
        self.level = level
        super.init(coordinator)
    }
    
    func onAppear() {
        self.loadImages(level: self.level)
    }
    
    func onDisappear() {
        
    }
    
    private func loadImages(level: Level) {
        let totalCount = level.cell.count
        let distributeTotalCount = distributeTotalCount(totalCount: totalCount, into: self.types.count)
        
        self.types.indices.forEach({
            countWithType.updateValue(distributeTotalCount[$0], forKey: self.types[$0])
        })
        if countWithType.isEmpty { return }
        
        Publishers.Zip(
            self.interactors.animalImageInteractor.getDogImages(countWithType[.dog]),
            self.interactors.animalImageInteractor.getFoxImages(countWithType[.fox])
        )
        .run(in: &self.subscription) {[weak self] (dogs, foxes) in
            guard let self = self else { return }
            dogs.forEach {
                self.results.append(GameItem(type: .dog, url: $0.imageUrl, isSelected: false))
            }
            foxes.forEach {
                self.results.append(GameItem(type: .fox, url: $0.imageUrl, isSelected: false))
            }
            self.results.shuffle()
            print("self.results: \(self.results)")
        }
    }
    
    private func distributeTotalCount(totalCount: Int, into n: Int) -> [Int] {
        guard n > 0, totalCount >= n else { return [] }
        
        var result: [Int] = []
        var remainingCount = totalCount
        
        for _ in 1..<n {
            let maxPossibleValue = remainingCount - (n - result.count)
            let randomValue = Int.random(in: 1...maxPossibleValue)
            result.append(randomValue)
            remainingCount -= randomValue
        }
        
        // 마지막 남은 수를 결과 배열에 추가하여 totalCount와 동일하게 만듦
        result.append(remainingCount)
        
        return result
    }
}

