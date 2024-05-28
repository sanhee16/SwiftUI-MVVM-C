//
//  RankingVM.swift
//  AnimalPicker
//
//  Created by Sandy on 5/24/24.
//

import Foundation
import Combine

class RankingVM: BaseViewModel {
    private let interactors: DIContainer.Interactors
    let levels: [Level] = [.easy, .normal, .hard, .hell]
    @Published var rankings: [RankingData] = []
    
    init(_ interactors: DIContainer.Interactors) {
        self.interactors = interactors
        super.init()
    }
    
    func onAppear() {
        
    }
    
    func onDisappear() {
        
    }
    
    func loadRankings(level: Level) {
        self.rankings.removeAll()
        self.rankings = self.interactors.rankingInteractor.loadRankings(level: level)
        print("loadRankings: \(self.rankings)")
    }
}
