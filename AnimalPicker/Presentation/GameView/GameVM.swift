//
//  GameVM.swift
//  AnimalPicker
//
//  Created by Sandy on 5/21/24.
//

import Foundation
import Combine

enum GameStatus {
    case loading
    case timeOut
    case enterRanking
    case clear
    case onGaming
}

class GameVM: BaseViewModel {
    private let interactors: DIContainer.Interactors
    let level: Level
    let types: [ImageType] = [.dog, .fox, .duck, .lizard]
    var countWithType: [ImageType: Int] = [:]
    var results: [GameItem] = []
    var answer: ImageType? = nil
    
    @Published var leftTime: Int? = nil
    @Published var isCorrect: Bool = false
    @Published var isGaming: Bool = true
    @Published var status: GameStatus = .loading
    @Published var step: Int = 0 { didSet { self.score = self.step * self.level.point }}
    @Published var score: Int = 0

    @Published var isUploadSuccess: Bool = false
    
    private var timer: Timer? = nil
    
    init(_ interactors: DIContainer.Interactors, level: Level) {
        self.interactors = interactors
        self.level = level
        super.init()
    }
    
    func onAppear() {
        self.loadRankings()
        self.loadImages(level: self.level)
    }
    
    func onDisappear() {
        
    }
    
    func nextLevel() {
        self.stopTimer()
        self.step += 1
        self.loadImages(level: self.level)
    }
    
    func reset() {
        self.stopTimer()
        self.step = 0
        self.loadImages(level: self.level)
    }
    
    func onUploadRanking(_ nickname: String) {
        if score <= 0 {
             return
        }
        self.interactors.rankingInteractor.saveRanking(
            rankingData: RankingData(
                id: UUID(),
                nickname: nickname,
                score: self.score,
                level: self.level,
                createdAt: Int(Date().timeIntervalSince1970)
            )
        )
        self.status = .timeOut
    }
    
    private func loadRankings() {
        let rankings = self.interactors.rankingInteractor.loadRankings()
        print("ranking: \(rankings)")
    }
    
    func onSelectItem(item: GameItem) {
        if isCorrect { return }
        guard let _ = self.answer, let idx = self.results.firstIndex(where: { $0.id == item.id }) else { return }
        self.results[idx].isSelected.toggle()
        self.objectWillChange.send()
        
        if self.results.filter({ $0.type == self.answer && !$0.isSelected}).isEmpty && self.results.filter({ $0.type != self.answer && $0.isSelected}).isEmpty {
            self.stopTimer()
            self.status = .clear
        }
    }
    
    func onLoadSuccess(item: GameItem) {
        if let idx = self.results.firstIndex(of: item) {
            self.results[idx].isLoaded = true
        }
        
        if self.results.filter({ !$0.isLoaded }).isEmpty {
            self.status = .onGaming
            self.startTimeCount()
        }
    }
    
    private func loadImages(level: Level) {
        self.results.removeAll()
        self.countWithType.removeAll()
        self.status = .loading
        self.answer = nil
        
        let totalCount = level.cell.row * level.cell.column
        let distributeTotalCount = distributeTotalCount(totalCount: totalCount, into: self.types.count)
        
        self.types.indices.forEach({
            countWithType.updateValue(distributeTotalCount[$0], forKey: self.types[$0])
        })
        if countWithType.isEmpty { return }
        
        Publishers.Zip4(
            self.interactors.animalImageInteractor.getDogImages(countWithType[.dog]),
            self.interactors.animalImageInteractor.getFoxImages(countWithType[.fox]),
            self.interactors.animalImageInteractor.getDuckImages(countWithType[.duck]),
            self.interactors.animalImageInteractor.getLizardImages(countWithType[.lizard])
        )
        .run(in: &self.subscription) {[weak self] (dogs, foxes, ducks, lizards) in
            guard let self = self else { return }
            var idx: Int = 0
            self.results.removeAll()
            
            dogs.forEach {
                self.results.append(GameItem(id: idx, type: .dog, url: $0.imageUrl))
                idx += 1
            }
            foxes.forEach {
                self.results.append(GameItem(id: idx, type: .fox, url: $0.imageUrl))
                idx += 1
            }
            ducks.forEach {
                self.results.append(GameItem(id: idx, type: .duck, url: $0.imageUrl))
                idx += 1
            }
            lizards.forEach {
                self.results.append(GameItem(id: idx, type: .lizard, url: $0.imageUrl))
                idx += 1
            }
            
            self.results.shuffle()
            self.objectWillChange.send()
            self.leftTime = level.timer
            self.answer = self.types.randomElement()
            print("self.results: \(self.results)")
        }
    }
    
    private func distributeTotalCount(totalCount: Int, into n: Int) -> [Int] {
        guard n > 0, totalCount >= n else { return [] }
        
        var result: [Int] = []
        var remainingCount = totalCount - self.types.count
        
        for _ in 1..<n {
            let maxPossibleValue = remainingCount - (n - result.count)
            let randomValue = Int.random(in: 1...maxPossibleValue)
            result.append(randomValue + 1)
            remainingCount -= randomValue
        }
        
        // 마지막 남은 수를 결과 배열에 추가하여 totalCount와 동일하게 만듦
        result.append(remainingCount)
        
        return result
    }
    
    private func startTimeCount() {
        self.stopTimer()
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
    }

    @objc
    func timerFired() {
        if let leftTime = self.leftTime {
            self.leftTime = leftTime - 1
        }
        
        if let leftTime = self.leftTime, leftTime <= 0 {
            self.status = self.score > 0 ? .enterRanking : .timeOut
            self.stopTimer()
        }
    }

    private func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }

}

