//
//  RankingInteractor.swift
//  AnimalPicker
//
//  Created by Sandy on 5/24/24.
//

import Foundation
import Combine

//protocol RankingInteractor {
//    //Firestore(remote)
//    func loadRemoteRankings() -> AnyPublisher<[RankingData], Error>
//    func loadRemoteRankings(level: Level) -> AnyPublisher<[RankingData], Error>
//    func loadRemoteRanking(id: String) -> AnyPublisher<RankingData?, Error>
//    func saveRemoteRanking(rankingData: RankingData) -> AnyPublisher<String, Error>
//    
//    // Local
//    func loadLocalRankings() -> [RankingData]
//    func loadLocalRankings(level: Level) -> [RankingData]
//    func loadLocalRanking(id: String) -> RankingData?
//    func saveLocalRanking(rankingData: RankingData)
//}
//
//class RealRankingInteractor: RankingInteractor {
//    var subscription = Set<AnyCancellable>()
//
//    let rankingDBRepository: RankingDBRepository
//    let rankingWebRepository: RankingWebRepository
//    
//    init(rankingDBRepository: RankingDBRepository, rankingWebRepository: RankingWebRepository) {
//        self.rankingDBRepository = rankingDBRepository
//        self.rankingWebRepository = rankingWebRepository
//    }
//    
//    func loadRemoteRankings() -> AnyPublisher<[RankingData], Error> {
//        let future: (() -> Deferred) = { () -> Deferred<Future<[RankingData], Error>> in
//            return Deferred {
//                Future<[RankingData], Error> { promise in
//                    self.rankingWebRepository.loadRankings()
//                        .run(in: &self.subscription) {[weak self] response in
//                            guard let self = self else { return }
//                            var result: [RankingData] = []
//                            do {
//                                try response.forEach { item in
//                                    let decodedData: RankingData = try item.decode()
//                                    result.append(decodedData)
//                                }
//                                result.sort { lhs, rhs in
//                                    lhs.score > rhs.score
//                                }
//                                promise(.success(result))
//                            } catch {
//                                promise(.success([]))
//                            }
//                        } err: {[weak self] err in
//                            guard let self = self else { return }
//                            print(err)
//                            promise(.failure(err))
//                        } complete: {
//                            
//                        }
//                }
//            }
//        }
//        return future().eraseToAnyPublisher()
//    }
//    
//    func loadRemoteRankings(level: Level) -> AnyPublisher<[RankingData], any Error> {
//        let future: (() -> Deferred) = { () -> Deferred<Future<[RankingData], Error>> in
//            return Deferred {
//                Future<[RankingData], Error> { promise in
//                    self.rankingWebRepository.loadRankings()
//                        .run(in: &self.subscription) {[weak self] response in
//                            guard let self = self else { return }
//                            var result: [RankingData] = []
//                            do {
//                                
//                                try response.forEach { item in
//                                    let decodedData: RankingData = try item.decode()
//                                    
//                                    print("decodedData: \(decodedData)")
//                                    if decodedData.level == level {
//                                        result.append(decodedData)
//                                    }
//                                }
//                                result.sort { lhs, rhs in
//                                    lhs.score > rhs.score
//                                }
//                                promise(.success(result))
//                            } catch {
//                                print("decodedData failed: \(error)")
//                                promise(.success([]))
//                            }
//                        } err: {[weak self] err in
//                            print(err)
//                            promise(.failure(err))
//                        } complete: {
//                            
//                        }
//                }
//            }
//        }
//        return future().eraseToAnyPublisher()
//    }
//    
//    func loadRemoteRanking(id: String) -> AnyPublisher<RankingData?, any Error> {
//        let future: (() -> Deferred) = { () -> Deferred<Future<RankingData?, Error>> in
//            return Deferred {
//                Future<RankingData?, Error> { promise in
//                    self.rankingWebRepository.loadRanking(id: id)
//                        .run(in: &self.subscription) {[weak self] response in
//                            guard let self = self else { return }
//                            do {
//                                let decodedData: RankingData = try response.decode()
//                                promise(.success(decodedData))
//                            } catch {
//                                promise(.success(nil))
//                            }
//                        } err: {[weak self] err in
//                            guard let self = self else { return }
//                            promise(.failure(err))
//                            print(err)
//                        } complete: {
//                            
//                        }
//                }
//            }
//        }
//        return future().eraseToAnyPublisher()
//    }
//    
//    func saveRemoteRanking(rankingData: RankingData) -> AnyPublisher<String, Error> {
//        guard let value = rankingData.toDictionary() else { 
//            return Fail(error: FirestoreError.parsingError).eraseToAnyPublisher()
//        }
//        return self.rankingWebRepository.save(value: value)
//    }
//    
//    
//    func loadLocalRankings(level: Level) -> [RankingData] {
//        let rankings = self.rankingDBRepository.loadRankings()
//        let rankingDatas = rankings.map { (r: Ranking) in
//            RankingData(id: r.id ?? UUID().uuidString, nickname: r.nickname ?? "", score: Int(r.score), level: r.level.getLevel, createdAt: Int(r.createdAt))
//        }.sorted { lhs, rhs in
//            lhs.score > rhs.score
//        }.filter {
//            $0.level == level
//        }
//        return rankingDatas
//    }
//    
//    
//    func loadLocalRankings() -> [RankingData] {
//        let rankings = self.rankingDBRepository.loadRankings()
//        let rankingDatas = rankings.map { (r: Ranking) in
//            return RankingData(id: r.id ?? UUID().uuidString, nickname: r.nickname ?? "", score: Int(r.score), level: r.level.getLevel, createdAt: Int(r.createdAt))
//        }.sorted { lhs, rhs in
//            lhs.score > rhs.score
//        }
//        return rankingDatas
//    }
//    
//    func loadLocalRanking(id: String) -> RankingData? {
//        let ranking = self.rankingDBRepository.loadRanking(id: id)
//        let rankingData = ranking.map { (r: Ranking) in
//            return RankingData(id: r.id ?? UUID().uuidString, nickname: r.nickname ?? "", score: Int(r.score), level: r.level.getLevel, createdAt: Int(r.createdAt))
//        }
//        return rankingData
//    }
//    
//    func saveLocalRanking(rankingData: RankingData) {
//        self.rankingDBRepository.saveRanking(rankingData: rankingData)
//    }
//}

protocol RankingInteractor {
    func loadRankings() -> AnyPublisher<[RankingData], Error>
    func loadRankings(level: Level) -> AnyPublisher<[RankingData], Error>
    func saveRanking(rankingData: RankingData) -> AnyPublisher<String, Error>
    func uploadUnsyncedData() -> AnyPublisher<Bool, any Error>
}

class RealRankingInteractor: RankingInteractor {
    private var subscription = Set<AnyCancellable>()
    
    private let rankingRepository: RankingRepository
    
    init(rankingRepository: RankingRepository) {
        self.rankingRepository = rankingRepository
    }
    
    func loadRankings() -> AnyPublisher<[RankingData], any Error> {
        return self.rankingRepository.loadRankings()
    }
    
    func loadRankings(level: Level) -> AnyPublisher<[RankingData], any Error> {
        let future: (() -> Deferred) = { () -> Deferred<Future<[RankingData], Error>> in
            return Deferred {
                Future<[RankingData], Error> { promise in
                    self.rankingRepository.loadRankings()
                        .run(in: &self.subscription) { response in
                            promise(.success(response.filter({ $0.level == level })))
                        } err: { error in
                            promise(.failure(error))
                        } complete: {
                            
                        }
                }
            }
        }
        return future().eraseToAnyPublisher()
    }
    
    func saveRanking(rankingData: RankingData) -> AnyPublisher<String, any Error> {
        self.rankingRepository.save(rankingData: rankingData)
    }
    
    func uploadUnsyncedData() -> AnyPublisher<Bool, any Error> {
        self.rankingRepository.uploadUnsyncedData()
    }
}
