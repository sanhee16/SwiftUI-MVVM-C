//
//  GameVM.swift
//  AnimalPicker
//
//  Created by Sandy on 5/21/24.
//

import Foundation
import Combine

enum SingleGameStatus {
    case loading
    case timeOut
    case enterRanking
    case clear
    case onGaming
}

class SingleGameVM: BaseViewModel {
    private let interactors: DIContainer.Interactors
    let level: Level
    let types: [ImageType] = [.dog, .fox, .duck, .lizard]
    var items: [GameItem] = []
    var answer: ImageType? = nil
    
    @Published var leftTime: Int? = nil
    @Published var isCorrect: Bool = false
    @Published var isGaming: Bool = true
    @Published var status: SingleGameStatus = .loading
    @Published var step: Int = 0 { didSet { self.score = self.step * self.level.point }}
    @Published var score: Int = 0

    @Published var isUploadSuccess: Bool = false
    @Published var rankings: [RankingData] = []
    @Published var myRankingId: String? = nil
    
    @Published var bonusCnt: Int = 0
    @Published var bonusScore: Int = 0
    
    private var timer: Timer? = nil
    
    init(_ interactors: DIContainer.Interactors, level: Level) {
        self.interactors = interactors
        self.level = level
        super.init()
    }
    
    func onAppear() {
        self.loadImages(level: self.level)
    }
    
    func onDisappear() {
        
    }
    
    func nextLevel() {
        self.myRankingId = nil
        self.stopTimer()
        self.step += 1
        self.loadImages(level: self.level)
    }
    
    func reset() {
        self.myRankingId = nil
        self.stopTimer()
        self.step = 0
        self.bonusScore = 0
        self.bonusCnt = 0
        self.loadImages(level: self.level)
    }
    
    func onUploadRanking(_ nickname: String) {
        if score <= 0 {
             return
        }
        self.interactors.rankingInteractor.saveRemoteRanking(
            rankingData: RankingData(
                nickname: nickname,
                score: self.score + self.bonusScore,
                level: self.level,
                createdAt: Int(Date().timeIntervalSince1970)
            )
        )
        .run(in: &self.subscription) {[weak self] response in
            guard let self = self else { return }
            self.myRankingId = response
        } err: {[weak self] err in
            guard let self = self else { return }
            print(err)
        } complete: {
            
        }

        self.loadRankings()
        self.status = .timeOut
    }
    
    func onSelectItem(item: GameItem) {
        guard let answer = self.answer, let idx = self.items.firstIndex(where: { $0.id == item.id }) else { return }
        
        let result = self.interactors.animalImageInteractor.selectSingleGameItem(
            singleGameInfo: SingleGameInfo(
                gameList: self.items,
                selectItem: item,
                answer: answer,
                level: self.level,
                bonusCount: self.bonusCnt,
                bonusScore: self.bonusScore
            )
        )
        self.bonusCnt = result.bonusCount
        self.bonusScore = result.bonusScore
        
        self.items[idx].isSelected.toggle()
        
        if self.items.filter({ $0.type == answer.rawValue && !$0.isSelected}).isEmpty && self.items.filter({ $0.type != answer.rawValue && $0.isSelected}).isEmpty {
            self.stopTimer()
            self.status = .clear
        }
    }
    
    func onLoadSuccess(item: GameItem) {
        if let idx = self.items.firstIndex(of: item) {
            self.items[idx].isLoaded = true
        }
        
        if self.items.filter({ !$0.isLoaded }).isEmpty {
            self.status = .onGaming
            self.startTimeCount()
        }
    }
    
    func loadRankings() {
        self.interactors.rankingInteractor.loadRemoteRankings(level: self.level)
            .run(in: &self.subscription) {[weak self] response in
                guard let self = self else { return }
                self.rankings = response
                print("loadRankings: \(self.rankings)")
            } err: {[weak self] err in
                guard let self = self else { return }
                self.rankings.removeAll()
                print(err)
            } complete: {
                
            }
    }
    
    private func loadImages(level: Level) {
        self.items.removeAll()
        self.status = .loading
        self.answer = nil
        
        self.interactors.animalImageInteractor.generateGameItems(level: self.level)
            .run(in: &self.subscription) {[weak self] response in
                guard let self = self else { return }
                self.answer = response.answer
                self.items = response.items
                
                self.objectWillChange.send()
                self.leftTime = level.timer
            } err: {[weak self] err in
                guard let self = self else { return }
                print(err)
            } complete: {
                
            }
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
            self.status = (self.score + self.bonusScore) > 0 ? .enterRanking : .timeOut
            self.loadRankings()
            self.stopTimer()
        }
    }

    private func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }

}

