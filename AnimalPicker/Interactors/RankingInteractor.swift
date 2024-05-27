//
//  RankingInteractor.swift
//  AnimalPicker
//
//  Created by Sandy on 5/24/24.
//

import Foundation

protocol RankingInteractor {
    func loadRankings() -> [Ranking]
    func loadRanking(id: UUID) -> Ranking?
    func saveRanking(rankingData: Ranking)
}

struct RealRankingInteractor: RankingInteractor {
    let rankingDBRespository: RankingDBRespository
    
    init(rankingDBRespository: RankingDBRespository) {
        self.rankingDBRespository = rankingDBRespository
    }
    
    func loadRankings() -> [Ranking] {
        self.rankingDBRespository.loadRankings()
    }
    
    func loadRanking(id: UUID) -> Ranking? {
        self.rankingDBRespository.loadRanking(id: id)
    }   
    func saveRanking(rankingData: Ranking) {
        self.rankingDBRespository.saveRanking(rankingData: rankingData)
    }
}
