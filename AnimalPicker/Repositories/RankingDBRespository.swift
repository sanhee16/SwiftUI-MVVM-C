//
//  RankingDBRespository.swift
//  AnimalPicker
//
//  Created by Sandy on 5/24/24.
//

import Foundation
import CoreData

protocol RankingDBRespository {
    func loadRankings() -> [Ranking]
    func loadRanking(id: UUID) -> Ranking?
    func saveRanking(rankingData: RankingData)
}

class RealRankingDBRespository: RankingDBRespository {
    var userDefaultsService: UserDefaultsService
    var coredataService: CoreDataService
    
    init(userDefaultsService: UserDefaultsService, coredataService: CoreDataService) {
        self.userDefaultsService = userDefaultsService
        self.coredataService = coredataService
    }
    
    func loadRankings() -> [Ranking] {
        do {
            let rankings = try self.coredataService.container.viewContext.fetch(Ranking.fetchRequest()) as! [Ranking]
            return rankings
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    func loadRanking(id: UUID) -> Ranking? {
        do {
            let ranking = try self.coredataService.container.viewContext.fetch(Ranking.fetchRequest()).first(where: { $0.id == id })
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
}

extension Int16 {
    var getLevel: Level {
        switch self {
        case 0: return .easy
        case 1: return .normal
        case 2: return .hard
        case 3: return .hell
        default: return .easy
        }
    }
}
