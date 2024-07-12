//
//  AnimalImageInteractorTest.swift
//  AnimalPickerTests
//
//  Created by Sandy on 7/5/24.
//

import XCTest
import Combine
@testable import AnimalPicker

final class AnimalImageInteractorTest: XCTestCase {
    var sut: AnimalImageInteractor!
    var foxImageRepository: (any ImageRepository)!
    var dogImageRepository: (any ImageRepository)!
    var duckImageRepository: (any ImageRepository)!
    var lizardIamgeRepository: (any ImageRepository)!
    
    override func setUpWithError() throws {
        try super.setUpWithError()

        print("setUp")
        self.foxImageRepository = RealFoxImageRepository(network: BaseNetwork(), baseUrl: "https://randomfox.ca")
        self.dogImageRepository = RealFoxImageRepository(network: BaseNetwork(), baseUrl: "https://dog.ceo/api")
        self.duckImageRepository = RealFoxImageRepository(network: BaseNetwork(), baseUrl: "https://random-d.uk/api/v2")
        self.lizardIamgeRepository = RealFoxImageRepository(network: BaseNetwork(), baseUrl: "https://nekos.life/api/v2")
        self.sut = RealAnimalImageInteractor(
            foxImageRepository: self.foxImageRepository,
            dogImageRepository: self.dogImageRepository,
            duckImageRepository: self.duckImageRepository,
            lizardIamgeRepository: self.lizardIamgeRepository
        )
    }

    override func tearDownWithError() throws {
        print("tearDown")
        sut = nil
        
        self.foxImageRepository = nil
        self.dogImageRepository = nil
        self.duckImageRepository = nil
        self.lizardIamgeRepository = nil
        
        try super.tearDownWithError()
    }
    
    func test_Given_leftLastAnswer_When_selectCorrectImage_Expect_finish() {
        // Given
        let mockGameList: [GameItem] = [
            GameItem(id: 0, type: .dog, url: "", isSelected: true),
            GameItem(id: 1, type: .dog, url: "", isSelected: false),
            GameItem(id: 2, type: .lizard, url: "", isSelected: false),
            GameItem(id: 3, type: .lizard, url: "", isSelected: false),
            GameItem(id: 4, type: .cat, url: "", isSelected: false),
            GameItem(id: 5, type: .cat, url: "", isSelected: false),
            GameItem(id: 6, type: .duck, url: "", isSelected: false),
            GameItem(id: 7, type: .duck, url: "", isSelected: false)
        ]
        
        let mockData: SingleGameInfo = SingleGameInfo(
            gameList: mockGameList,
            selectItem: GameItem(id: 1, type: .dog, url: "", isSelected: false),
            answer: .dog,
            level: .easy,
            bonusCount: 0,
            bonusScore: 0,
            isFinish: false
        )
        
        // When
        let result = sut.selectSingleGameItem(singleGameInfo: mockData)
        
        // Then
        XCTAssertEqual(result.isFinish, true)
    }
    
    func test_Given_leftServeralAnswer_When_selectCorrectImage_Expect_nonFinish() {
        // Given
        let mockGameList: [GameItem] = [
            GameItem(id: 0, type: .dog, url: "", isSelected: false),
            GameItem(id: 1, type: .dog, url: "", isSelected: false),
            GameItem(id: 2, type: .lizard, url: "", isSelected: false),
            GameItem(id: 3, type: .lizard, url: "", isSelected: false),
            GameItem(id: 4, type: .cat, url: "", isSelected: false),
            GameItem(id: 5, type: .cat, url: "", isSelected: false),
            GameItem(id: 6, type: .duck, url: "", isSelected: false),
            GameItem(id: 7, type: .duck, url: "", isSelected: false)
        ]
        
        let mockData: SingleGameInfo = SingleGameInfo(
            gameList: mockGameList,
            selectItem: GameItem(id: 1, type: .dog, url: "", isSelected: false),
            answer: .dog,
            level: .easy,
            bonusCount: 0,
            bonusScore: 0,
            isFinish: false
        )
        
        // When
        let result = sut.selectSingleGameItem(singleGameInfo: mockData)
        
        // Then
        XCTAssertEqual(result.isFinish, false)
    }
    
    func test_Given_leftServeralAnswer_When_selectCorrectImage_Expect_bonusIncreased() {
        // Given
        let bonusCount = 2
        let mockGameList: [GameItem] = [
            GameItem(id: 0, type: .dog, url: "", isSelected: false),
            GameItem(id: 1, type: .dog, url: "", isSelected: false),
            GameItem(id: 2, type: .lizard, url: "", isSelected: false),
            GameItem(id: 3, type: .lizard, url: "", isSelected: false),
            GameItem(id: 4, type: .cat, url: "", isSelected: false),
            GameItem(id: 5, type: .cat, url: "", isSelected: false),
            GameItem(id: 6, type: .duck, url: "", isSelected: false),
            GameItem(id: 7, type: .duck, url: "", isSelected: false)
        ]
        
        let mockData: SingleGameInfo = SingleGameInfo(
            gameList: mockGameList,
            selectItem: GameItem(id: 1, type: .dog, url: "", isSelected: false),
            answer: .dog,
            level: .easy,
            bonusCount: bonusCount,
            bonusScore: 0,
            isFinish: false
        )
        
        // When
        let result = sut.selectSingleGameItem(singleGameInfo: mockData)
        
        // Then
        XCTAssertEqual(result.bonusCount, bonusCount + 1)
    }
    
    func test_Given_bonusCountExist_When_selectIncorrectImage_Expect_initBonusCount() {
        // Given
        let bonusCount = 2
        let mockGameList: [GameItem] = [
            GameItem(id: 0, type: .dog, url: "", isSelected: false),
            GameItem(id: 1, type: .dog, url: "", isSelected: false),
            GameItem(id: 2, type: .lizard, url: "", isSelected: false),
            GameItem(id: 3, type: .lizard, url: "", isSelected: false),
            GameItem(id: 4, type: .cat, url: "", isSelected: false),
            GameItem(id: 5, type: .cat, url: "", isSelected: false),
            GameItem(id: 6, type: .duck, url: "", isSelected: false),
            GameItem(id: 7, type: .duck, url: "", isSelected: false)
        ]
        
        let mockData: SingleGameInfo = SingleGameInfo(
            gameList: mockGameList,
            selectItem: GameItem(id: 1, type: .dog, url: "", isSelected: false),
            answer: .lizard,
            level: .easy,
            bonusCount: bonusCount,
            bonusScore: 0,
            isFinish: false
        )
        
        // When
        let result = sut.selectSingleGameItem(singleGameInfo: mockData)
        
        // Then
        XCTAssertEqual(result.bonusCount, 0)
    }
    
    func test_Given_gameItems_When_unSelectImage_Expect_isSelectedSetFalse() {
        // Given
        let bonusCount = 2
        let mockGameList: [GameItem] = [
            GameItem(id: 0, type: .dog, url: "", isSelected: false),
            GameItem(id: 1, type: .dog, url: "", isSelected: true),
            GameItem(id: 2, type: .lizard, url: "", isSelected: false),
            GameItem(id: 3, type: .lizard, url: "", isSelected: false),
            GameItem(id: 4, type: .cat, url: "", isSelected: false),
            GameItem(id: 5, type: .cat, url: "", isSelected: false),
            GameItem(id: 6, type: .duck, url: "", isSelected: false),
            GameItem(id: 7, type: .duck, url: "", isSelected: false)
        ]
        
        let mockData: SingleGameInfo = SingleGameInfo(
            gameList: mockGameList,
            selectItem: GameItem(id: 1, type: .dog, url: "", isSelected: false),
            answer: .lizard,
            level: .easy,
            bonusCount: bonusCount,
            bonusScore: 0,
            isFinish: false
        )
        
        // When
        let result = sut.selectSingleGameItem(singleGameInfo: mockData)
        
        // Then
        XCTAssertEqual(result.gameList.filter({ $0.isSelected }).count, 0)
    }

}
