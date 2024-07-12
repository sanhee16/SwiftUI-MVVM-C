//
//  RankingDBRepository.swift
//  AnimalPicker
//
//  Created by Sandy on 5/24/24.
//

import Foundation
import Combine
import CoreData

protocol RankingDBRepository {
    func loadRankings() -> [Ranking]
    func loadRanking(id: String) -> Ranking?
    func saveRanking(rankingData: RankingData)
    func getCount() -> Int
}

class RealRankingDBRepository: RankingDBRepository {
    var userDefaultsService: UserDefaultsService
    var coredataService: CoreDataService
    
    init(userDefaultsService: UserDefaultsService, coredataService: CoreDataService) {
        self.userDefaultsService = userDefaultsService
        self.coredataService = coredataService
    }
    
    func loadRankings() -> [Ranking] {
        let context = self.coredataService.container.viewContext
        do {
            let rankings = try context.fetch(Ranking.fetchRequest())
            return rankings
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    func loadRanking(id: String) -> Ranking? {
        let context = self.coredataService.container.viewContext
        do {
            let ranking = try context.fetch(Ranking.fetchRequest()).first(where: { $0.id == id })
            return ranking
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func saveRanking(rankingData: RankingData) {
        let context = self.coredataService.container.viewContext
        
        if let entity = NSEntityDescription.entity(forEntityName: "Ranking", in: context) {
            let ranking = NSManagedObject(entity: entity, insertInto: context)
            
            ranking.setValue(rankingData.id, forKey: "id")
            ranking.setValue(rankingData.nickname, forKey: "nickname")
            ranking.setValue(rankingData.score, forKey: "score")
            ranking.setValue(rankingData.level.levelInt, forKey: "level")
            ranking.setValue(rankingData.createdAt, forKey: "createdAt")
            
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func getCount() -> Int {
        let context = self.coredataService.container.viewContext
        do {
            return try context.count(for: Ranking.fetchRequest())
        } catch {
            return -1
        }
    }
}
