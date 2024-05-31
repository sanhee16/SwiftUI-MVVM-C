//
//  RankingWebRepository.swift
//  AnimalPicker
//
//  Created by Sandy on 5/30/24.
//

import Foundation
import Combine
import CoreData

protocol RankingWebRepository {
    func loadRankings() -> AnyPublisher<[[String : Any]], Error>
    func loadRanking(id: String) -> AnyPublisher<[String : Any], Error>
    func save(value: [String : Any]) -> AnyPublisher<String, Error> 
}

class RealRankingWebRepository: RankingWebRepository {
    var firestoreServcice: FirestoreService
    
    init(firestoreServcice: FirestoreService) {
        self.firestoreServcice = firestoreServcice
    }
    
    func loadRankings() -> AnyPublisher<[[String : Any]], Error> {
        return self.firestoreServcice.load(table: .ranking)
    }
    
    func loadRanking(id: String) -> AnyPublisher<[String : Any], Error> {
        return self.firestoreServcice.load(table: .ranking, id: id)
    }
    
    func save(value: [String : Any]) -> AnyPublisher<String, Error> {
        self.firestoreServcice.save(table: .ranking, value: value)
    }
}
