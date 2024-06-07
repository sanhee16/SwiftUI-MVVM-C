//
//  MultiGameVM.swift
//  AnimalPicker
//
//  Created by Sandy on 6/3/24.
//

import Foundation
import Combine

enum MultiGameStatus: String {
    case none = "none"
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
    @Published var status: MultiGameStatus = .none
    
    @Published var ranking: [RankingData] = []
    
    
    init(_ interactors: DIContainer.Interactors, services: DIContainer.Services, roomData: RoomData) {
        self.interactors = interactors
        self.services = services
        self.roomData = roomData
        self.deviceId = services.keychainService.loadDeviceId()
        super.init()
        
        self.services.realtimeMemberDBService.updateRoomId(roomId: self.roomData.id)
        self.services.realtimeRoomDBService.updateRoomId(roomId: self.roomData.id)
        self.observe()
    }
    
    func onAppear() {
        
    }
    
    func onDisappear() {
        
    }
    
    func onClickStart() {
        if MultiGameStatus(rawValue: self.roomData.status) != .ready { return }
        self.services.realtimeRoomDBService.changeStatus(status: MultiGameStatus.loading)
    }
    
    func onClickReady() {
        self.status = status == .none ? .ready : .none
        self.services.realtimeMemberDBService.changeStatus(memberId: self.deviceId, status: self.status)
    }
    
    func observe() {
        self.services.realtimeMemberDBService.memberChangedSubject
            .run(in: &self.subscription) {[weak self] response in
                guard let self = self else { return }
                self.members = response
                if self.members.filter({ MultiGameStatus(rawValue: $0.status) == MultiGameStatus.none }).isEmpty {
                    self.services.realtimeRoomDBService.changeStatus(status: MultiGameStatus.ready)
                } else {
                    self.services.realtimeRoomDBService.changeStatus(status: MultiGameStatus.none)
                }
            } err: {[weak self] err in
                guard let self = self else { return }
                print(err)
            } complete: {
                
            }
        
        self.services.realtimeRoomDBService.roomChangedSubject
            .run(in: &self.subscription) {[weak self] response in
                guard let self = self, let response = response else { return }
                self.roomData = response
            } err: {[weak self] err in
                guard let self = self else { return }
                print(err)
            } complete: {
                
            }
    }
}

