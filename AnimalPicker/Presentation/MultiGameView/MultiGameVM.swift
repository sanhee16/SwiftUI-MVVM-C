//
//  MultiGameVM.swift
//  AnimalPicker
//
//  Created by Sandy on 6/3/24.
//

import Foundation
import Combine

enum MultiGameStatus: String {
    case ready = "ready"
    case loading = "loading"
    case onGaming = "onGaming"
    case clear = "clear"
    case finish = "finish"
}

class MultiGameVM: BaseViewModel {
    private let interactors: DIContainer.Interactors
    private let services: DIContainer.Services
    let level: Level = .multi
    let types: [ImageType] = [.dog, .fox, .duck, .lizard]
    var countWithType: [ImageType: Int] = [:]
    
    var items: [GameItem] = []
    var answer: ImageType? = nil
    private var timer: Timer? = nil
    
    @Published var roomData: RoomData
    @Published var isCorrect: Bool = false
    @Published var isGaming: Bool = true
    @Published var status: MultiGameStatus = .ready
    
    @Published var bonusCnt: Int = 0
    @Published var bonusScore: Int = 0
    @Published var ranking: [RankingData] = []
    
    
    init(_ interactors: DIContainer.Interactors, services: DIContainer.Services, roomData: RoomData) {
        self.interactors = interactors
        self.services = services
        self.roomData = roomData
        super.init()
    }
    
    func onAppear() {
        
    }
    
    func onDisappear() {
        
    }
}

