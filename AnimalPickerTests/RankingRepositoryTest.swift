//
//  RankingRepositoryTest.swift
//  AnimalPickerTests
//
//  Created by Sandy on 7/18/24.
//

import XCTest
import Combine
import CoreData
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
@testable import AnimalPicker

// https://dokit.tistory.com/36
final class RankingRepositoryTest: XCTestCase {
    var subscription: Set<AnyCancellable>!
    var sut: RankingRepository!
    var firestoreService: FirestoreService!
    var coredataService: CoreDataService!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        print("setUp")
        self.subscription = Set<AnyCancellable>()
        self.firestoreService = RealFirestoreService()
        self.coredataService = MockedCoreDataService()
        
        self.sut = MockedRankingRepository(
            firestoreService: firestoreService,
            coredataService: coredataService
        )
        
    }
    
    override func tearDownWithError() throws {
        print("tearDown")
        sut = nil
        subscription.removeAll()
        subscription = nil
        self.firestoreService = nil
        self.coredataService = nil
        try super.tearDownWithError()
    }
    
    //TODO: Wrong!
    func test_When_ExistUnupdatedData_Expect_True() {
        let mockData: [RankingData] = [
            RankingData(id: UUID().uuidString, nickname: "name1", score: 10, level: .easy, createdAt: Int(Date().timeIntervalSince1970), isUploaded: true),
            RankingData(id: UUID().uuidString, nickname: "name2", score: 20, level: .easy, createdAt: Int(Date().timeIntervalSince1970), isUploaded: false),
            RankingData(id: UUID().uuidString, nickname: "name3", score: 30, level: .easy, createdAt: Int(Date().timeIntervalSince1970), isUploaded: true),
            RankingData(id: UUID().uuidString, nickname: "name4", score: 40, level: .easy, createdAt: Int(Date().timeIntervalSince1970), isUploaded: true),
            RankingData(id: UUID().uuidString, nickname: "name5", score: 50, level: .easy, createdAt: Int(Date().timeIntervalSince1970), isUploaded: false)
        ]
        
        let saveExpectation = XCTestExpectation(description: "DB Save")
        mockData.forEach { data in
            _ = self.sut.save(rankingData: data)
        }
        saveExpectation.fulfill()
        wait(for: [saveExpectation], timeout: 5.0)
        
        var isUpdated: Bool?
        let expectation = XCTestExpectation(description: "ExistUnupdatedData Test")
        
        self.sut.uploadUnsyncedData()
            .run(in: &self.subscription) { result in
                isUpdated = result
                expectation.fulfill()
            } err: { err in
                
            } complete: {
                
            }
        // expectation을 기다려서 timeout 내에 fulfill이 되는지 확인
        wait(for: [expectation], timeout: 2.0)
        
        // 예상한 결과와 일치하는지 확인
        XCTAssertEqual(isUpdated, true)
    }
    
    //TODO: Wrong!
    func test_When_NonExistUnupdatedData_Expect_False() {
        let mockData: [RankingData] = [
            RankingData(id: UUID().uuidString, nickname: "name1", score: 10, level: .easy, createdAt: Int(Date().timeIntervalSince1970), isUploaded: true),
            RankingData(id: UUID().uuidString, nickname: "name2", score: 20, level: .easy, createdAt: Int(Date().timeIntervalSince1970), isUploaded: true),
            RankingData(id: UUID().uuidString, nickname: "name3", score: 30, level: .easy, createdAt: Int(Date().timeIntervalSince1970), isUploaded: true),
            RankingData(id: UUID().uuidString, nickname: "name4", score: 40, level: .easy, createdAt: Int(Date().timeIntervalSince1970), isUploaded: true),
            RankingData(id: UUID().uuidString, nickname: "name5", score: 50, level: .easy, createdAt: Int(Date().timeIntervalSince1970), isUploaded: true)
        ]
        
        let saveExpectation = XCTestExpectation(description: "DB Save")
        mockData.forEach { data in
            _ = self.sut.save(rankingData: data)
        }
        saveExpectation.fulfill()
        wait(for: [saveExpectation], timeout: 5.0)
        
        
        var isUpdated: Bool?
        let expectation = XCTestExpectation(description: "NonExistUnupdatedData Test")
        
        self.sut.uploadUnsyncedData()
            .run(in: &self.subscription) { result in
                isUpdated = result
                expectation.fulfill()
            } err: { err in
                
            } complete: {
                
            }
        // expectation을 기다려서 timeout 내에 fulfill이 되는지 확인
        wait(for: [expectation], timeout: 2.0)
        
        // 예상한 결과와 일치하는지 확인
        XCTAssertEqual(isUpdated, false)
    }
}
