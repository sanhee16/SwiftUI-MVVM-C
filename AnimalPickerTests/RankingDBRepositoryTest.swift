//
//  RankingDBRepositoryTest.swift
//  AnimalPickerTests
//
//  Created by Sandy on 7/8/24.
//

import XCTest
import Combine
import CoreData
import Foundation
@testable import AnimalPicker

final class RankingDBRepositoryTest: XCTestCase {
    var sut: RankingDBRepository!
    var coredataService: CoreDataService!
    var userDefaultsService: UserDefaultsService!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        print("setUp")
        self.coredataService = MockedCoreDataService()
        self.userDefaultsService = UserDefaultsService()
        
        self.sut = RealRankingDBRepository(
            userDefaultsService: self.userDefaultsService,
            coredataService: self.coredataService
        )
    }
    
    override func tearDownWithError() throws {
        print("tearDown")
        sut = nil
        
        try super.tearDownWithError()
    }
    
    func test_saveNewItem() {
        self.sut.saveRanking(rankingData: RankingData(nickname: "sandy", score: 100, level: .hard, createdAt: Int(Date().timeIntervalSince1970)))
        
        XCTAssertEqual(self.sut.getCount(), 1)
    }
    
    func test_When_sameScoreEx() {
        let level: Level = .hard
        let list: [RankingData] = [
            RankingData(id: UUID().uuidString, nickname: "sandy1", score: 10, level: .easy, createdAt: Int(Date().timeIntervalSince1970)),
            RankingData(id: UUID().uuidString, nickname: "sandy2", score: 20, level: .easy, createdAt: Int(Date().timeIntervalSince1970)),
            RankingData(id: UUID().uuidString, nickname: "sandy1", score: 10, level: .normal, createdAt: Int(Date().timeIntervalSince1970)),
            RankingData(id: UUID().uuidString, nickname: "sandy2", score: 20, level: .normal, createdAt: Int(Date().timeIntervalSince1970)),
            RankingData(id: UUID().uuidString, nickname: "sandy1", score: 10, level: .hard, createdAt: Int(Date().timeIntervalSince1970)),
            RankingData(id: UUID().uuidString, nickname: "sandy2", score: 20, level: .hard, createdAt: Int(Date().timeIntervalSince1970)),
            RankingData(id: UUID().uuidString, nickname: "sandy1", score: 10, level: .hell, createdAt: Int(Date().timeIntervalSince1970)),
            RankingData(id: UUID().uuidString, nickname: "sandy2", score: 20, level: .hell, createdAt: Int(Date().timeIntervalSince1970))
        ]
        list.forEach { data in
            self.sut.saveRanking(rankingData: data)
        }
        
        self.sut.saveRanking(rankingData: RankingData(nickname: "sandy", score: 100, level: level, createdAt: Int(Date().timeIntervalSince1970)))
        let rankings: [Ranking] = self.sut.loadRankings()
        // https://stackoverflow.com/questions/25940008/nsarray-element-failed-to-match-the-swift-array-element-type
        let result = rankings.compactMap { (r: Ranking) in
            RankingData(
                id: r.id ?? UUID().uuidString,
                nickname: r.nickname ?? "",
                score: Int(r.score),
                level: r.level.getLevel, 
                createdAt: Int(r.createdAt)
            )
        }.sorted { lhs, rhs in lhs.score > rhs.score }.filter{ $0.level == level }
        
        XCTAssertEqual(
            result.count,
            list.filter({ $0.level == level }).count + 1
        )
    }
    
    
}

class MockedCoreDataService: CoreDataService {
    lazy var container: NSPersistentContainer = {
        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null")
        
        let container = NSPersistentContainer(name: "animal_picker_db")
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
