//
//  GameVM.swift
//  AnimalPicker
//
//  Created by Sandy on 5/21/24.
//

import Foundation
import Combine
import UIKit

enum GameStatus {
    case ready
    case timeOut
    case clear
    case onGaming
}


class GameVM: BaseViewModel {
    private let interactors: DIContainer.Interactors
    let level: Level
    let types: [ImageType] = [.dog, .fox]
    var countWithType: [ImageType: Int] = [:]
    var results: [GameItem] = []
    var answer: ImageType? = nil
    
    @Published var leftTime: Int? = nil
    @Published var isCorrect: Bool = false
    @Published var isGaming: Bool = true
    @Published var status: GameStatus = .ready
    private var timer: Timer? = nil
    
    init(_ coordinator: AppCoordinator, interactors: DIContainer.Interactors, level: Level) {
        self.interactors = interactors
        self.level = level
        super.init(coordinator)
    }
    
    func onAppear() {
        UIScrollView.appearance().bounces = false
        self.loadImages(level: self.level)
    }
    
    func onDisappear() {
        
    }
    
    func reset() {
        self.stopTimer()
        self.answer = nil
        self.results.removeAll()
        self.countWithType.removeAll()
        self.status = .ready
        self.loadImages(level: self.level)
    }
    
    func onSelectItem(item: GameItem) {
        if isCorrect { return }
        guard let answer = self.answer, let idx = self.results.firstIndex(where: { $0.id == item.id }) else { return }
        self.results[idx].isSelected.toggle()
        self.objectWillChange.send()
        
//        print("left: \(self.results.filter({ $0.type == answer }).filter({ !$0.isSelected }))")
        if self.results.filter({ $0.type == answer }).filter({ !$0.isSelected }).isEmpty {
            self.stopTimer()
            self.status = .clear
        }
    }
    
    private func loadImages(level: Level) {
        let totalCount = level.cell.row * level.cell.column
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
            var idx: Int = 0
            dogs.forEach {
                self.results.append(GameItem(id: idx, type: .dog, url: $0.imageUrl, isSelected: false))
                idx += 1
            }
            foxes.forEach {
                self.results.append(GameItem(id: idx, type: .fox, url: $0.imageUrl, isSelected: false))
                idx += 1
            }
            self.results.shuffle()
            self.objectWillChange.send()
            self.leftTime = level.timer
            self.status = .onGaming
            self.startTimeCount()
            self.answer = self.types.randomElement()
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
    
    private func startTimeCount() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {[weak self] timer in
            guard let self = self else { return }
            if let leftTime = self.leftTime {
                self.leftTime = leftTime - 1
            }
            if let leftTime = self.leftTime, leftTime <= 0 {
                self.status = .timeOut
                self.stopTimer()
            }
        }
        
        // Ensure the timer fires when on the main run loop
        if let timer = self.timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    private func stopTimer() {
        self.timer?.invalidate()
    }

}

