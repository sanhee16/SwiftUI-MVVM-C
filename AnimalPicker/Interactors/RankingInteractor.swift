//
//  RankingInteractor.swift
//  AnimalPicker
//
//  Created by Sandy on 5/24/24.
//

import Foundation

protocol RankingInteractor {
    func loadRankings() -> [RankingData]
    func loadRankings(level: Level) -> [RankingData]
    func loadRanking(id: UUID) -> RankingData?
    func saveRanking(rankingData: RankingData)
}

struct RealRankingInteractor: RankingInteractor {
    let rankingDBRespository: RankingDBRespository
    
    init(rankingDBRespository: RankingDBRespository) {
        self.rankingDBRespository = rankingDBRespository
    }
    
    func loadRankings(level: Level) -> [RankingData] {
        return self.loadRankings().filter({ $0.level == level })
    }
    
    func loadRankings() -> [RankingData] {
        let rankings = self.rankingDBRespository.loadRankings()
        let rankingDatas = rankings.map { (r: Ranking) in
            return RankingData(id: r.id ?? UUID(), nickname: r.nickname ?? "", score: Int(r.score), level: r.level.getLevel, createdAt: Int(r.createdAt))
        }.sorted { lhs, rhs in
            lhs.score > rhs.score
        }
        return rankingDatas
    }
    
    func loadRanking(id: UUID) -> RankingData? {
        let ranking = self.rankingDBRespository.loadRanking(id: id)
        let rankingData = ranking.map { (r: Ranking) in
            return RankingData(id: r.id ?? UUID(), nickname: r.nickname ?? "", score: Int(r.score), level: r.level.getLevel, createdAt: Int(r.createdAt))
        }
        return rankingData
    }
    func saveRanking(rankingData: RankingData) {
        self.rankingDBRespository.saveRanking(rankingData: rankingData)
    }
}
