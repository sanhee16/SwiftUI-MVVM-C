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
    let deviceId: String
    var items: [GameItem] = []
    var answer: ImageType? = nil
    private var timer: Timer? = nil
    @Published var members: [MultiGameMemberData] = []
    
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
        self.deviceId = services.keychainService.loadDeviceId()
        super.init()
        
        self.services.realtimeMemberDBService.updateRoomId(roomId: self.roomData.id)
        self.observeMembers()
    }
    
    func onAppear() {
        
    }
    
    func onDisappear() {
        
    }
    
    func observeMembers() {
        self.services.realtimeMemberDBService.memberChangedSubject
            .run(in: &self.subscription) {[weak self] response in
                guard let self = self else { return }
                self.members = response
                print("members: \(response)")
            } err: {[weak self] err in
                guard let self = self else { return }
                print(err)
            } complete: {
                
            }
    }
}

