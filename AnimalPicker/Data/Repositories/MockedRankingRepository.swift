//
//  MockedRankingRepository.swift
//  AnimalPicker
//
//  Created by Sandy on 7/22/24.
//

import Foundation
import Combine
import CoreData


class MockedRankingRepository: RankingRepository {
    private var subscription = Set<AnyCancellable>()
    private var firestoreService: FirestoreService
    private var coredataService: CoreDataService
    
    init(firestoreService: FirestoreService, coredataService: CoreDataService) {
        self.firestoreService = firestoreService
        self.coredataService = coredataService
    }
    
    func loadRankings() -> AnyPublisher<[RankingData], any Error> {
        let future: (() -> Deferred) = { () -> Deferred<Future<[RankingData], Error>> in
            return Deferred {
                Future<[RankingData], Error> { promise in
                    self.firestoreService.load(table: .ranking)
                        .run(in: &self.subscription) {[weak self] response in
                            guard let self = self else { return }
                            var result: [RankingData] = []
                            do {
                                try response.forEach { item in
                                    let decodedData: RankingData = try item.decode()
                                    result.append(decodedData)
                                }
                                
                                let context = self.coredataService.container.viewContext
                                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Ranking")
                                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

                                do {
                                    try context.execute(deleteRequest)
                                    
                                    result.forEach { rankingData in
                                        if let entity = NSEntityDescription.entity(forEntityName: "Ranking", in: context) {
                                            let ranking = NSManagedObject(entity: entity, insertInto: context)
                                            
                                            ranking.setValue(rankingData.id, forKey: "id")
                                            ranking.setValue(rankingData.nickname, forKey: "nickname")
                                            ranking.setValue(rankingData.score, forKey: "score")
                                            ranking.setValue(rankingData.level.levelInt, forKey: "level")
                                            ranking.setValue(rankingData.createdAt, forKey: "createdAt")
                                            ranking.setValue(true, forKey: "isUploaded")
                                            
                                            do {
                                                try context.save()
                                            } catch {
                                                print(error.localizedDescription)
                                            }
                                        }
                                    }
                                    
                                    promise(.success(result))
                                } catch let err as NSError {
                                    // TODO: handle the error
                                    promise(.failure(err))
                                }
                            } catch {
                                print("decodedData failed: \(error)")
                                promise(.success([]))
                            }
                        } err: { err in
                            print(err)
                            promise(.failure(err))
                        } complete: {
                            
                        }
                }
            }
        }
        return future().eraseToAnyPublisher()
    }
    
    func save(rankingData: RankingData) -> AnyPublisher<String, Error> {
        func updateLocalDB(isUploaded: Bool) {
            let context = self.coredataService.container.viewContext
            if let entity = NSEntityDescription.entity(forEntityName: "Ranking", in: context) {
                let ranking = NSManagedObject(entity: entity, insertInto: context)
                
                ranking.setValue(rankingData.id, forKey: "id")
                ranking.setValue(rankingData.nickname, forKey: "nickname")
                ranking.setValue(rankingData.score, forKey: "score")
                ranking.setValue(rankingData.level.levelInt, forKey: "level")
                ranking.setValue(rankingData.createdAt, forKey: "createdAt")
                ranking.setValue(isUploaded, forKey: "isUploaded")
                
                do {
                    try context.save()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        
        guard let value = rankingData.toDictionary() else {
            return Fail(error: FirestoreError.parsingError).eraseToAnyPublisher()
        }
        
        let future: (() -> Deferred) = { () -> Deferred<Future<String, Error>> in
            return Deferred {
                Future<String, Error> { promise in
                    self.firestoreService.save(table: .ranking, value: value)
                        .run(in: &self.subscription) { value in
                            updateLocalDB(isUploaded: false)
                            print("updateLocalDB")
                            promise(.success(value))
                        } err: { err in
                            print(err)
                            updateLocalDB(isUploaded: false)
                            promise(.failure(err))
                        } complete: {
                            
                        }
                }
            }
        }
        
        return future().eraseToAnyPublisher()
    }
    
    func uploadUnsyncedData() -> AnyPublisher<Bool, Error> {
        let future: (() -> Deferred) = { () -> Deferred<Future<Bool, Error>> in
            return Deferred {
                Future<Bool, Error> { promise in
                    do {
                        let rankings = try self.coredataService.container.viewContext.fetch(Ranking.fetchRequest())
                        let saveUnUploadedDatas = rankings.filter({ !$0.isUploaded }).compactMap { (r: Ranking) in
                            return RankingData(id: r.id ?? UUID().uuidString, nickname: r.nickname ?? "", score: Int(r.score), level: r.level.getLevel, createdAt: Int(r.createdAt)).toDictionary()
                        }
                        print("saveUnUploadedDatas: \(rankings.filter({ !$0.isUploaded }).count)")
                        if saveUnUploadedDatas.isEmpty {
                            promise(.success(false))
                            return
                        } else {
                            saveUnUploadedDatas.forEach { value in
                                self.firestoreService.save(table: .ranking, value: value)
                                    .run(in: &self.subscription, next: { _ in
                                        if let lastId = saveUnUploadedDatas.last?["id"] as? String, let id = value["id"] as? String, lastId == id {
                                            promise(.success(true))
                                            return
                                        }
                                    }, err: { error in
                                        promise(.failure(error))
                                        return
                                    }, complete: {
                                        
                                    })
                            }
                        }
                        
                    } catch {
                        print(error.localizedDescription)
                        promise(.failure(error))
                    }
                }
            }
        }

        return future().eraseToAnyPublisher()
    }
}
