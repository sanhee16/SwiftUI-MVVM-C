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
        self.interactors.rankingInteractor.loadRemoteRankings(level: level)
            .run(in: &self.subscription) {[weak self] response in
                guard let self = self else { return }
                self.rankings = response
                print("loadRankings: \(self.rankings)")
            } err: {[weak self] err in
                guard let self = self else { return }
                print(err)
            } complete: {
                
            }
    }
}
