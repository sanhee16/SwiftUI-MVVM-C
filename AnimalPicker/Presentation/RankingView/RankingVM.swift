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
    init(_ interactors: DIContainer.Interactors) {
        self.interactors = interactors
        super.init()
    }
    
    func onAppear() {
        
    }
    
    func onDisappear() {
        
    }
    
    func loadRankings() {
//        self.interactors.rankingInteractor
    }
}
