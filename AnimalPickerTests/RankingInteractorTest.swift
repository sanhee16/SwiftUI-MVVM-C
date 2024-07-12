//
//  RankingInteractorTest.swift
//  AnimalPickerTests
//
//  Created by Sandy on 7/8/24.
//

import XCTest
import Combine
@testable import AnimalPicker

final class RankingInteractorTest: XCTestCase {
    var sut: RankingInteractor!
    
    var rankingDBRepository: RankingDBRepository!
    var rankingWebRepository: RankingWebRepository!
    var coredataService: CoreDataService!
    var userDefaultsService: UserDefaultsService!
    var firestoreService: FirestoreService!
    
    override func setUpWithError() throws {
        try super.setUpWithError()

        print("setUp")
        self.coredataService = MockedCoreDataService()
        self.userDefaultsService = UserDefaultsService()
        self.firestoreService = FirestoreService()
        
        self.rankingDBRepository = RealRankingDBRepository(
            userDefaultsService: self.userDefaultsService,
            coredataService: self.coredataService
        )
        self.rankingWebRepository = RealRankingWebRepository(firestoreServcice: self.firestoreService)
        
        self.sut = RealRankingInteractor(
            rankingDBRepository: self.rankingDBRepository,
            rankingWebRepository: self.rankingWebRepository
        )
    }

    override func tearDownWithError() throws {
        print("tearDown")
        self.sut = nil
        
        self.rankingDBRepository = nil
        self.rankingWebRepository = nil
        self.coredataService = nil
        self.userDefaultsService = nil
        self.firestoreService = nil
        
        try super.tearDownWithError()
    }
    
    
    func test_When_addRankingData_Expect_AddedData() {

    }
    
    
    
}
