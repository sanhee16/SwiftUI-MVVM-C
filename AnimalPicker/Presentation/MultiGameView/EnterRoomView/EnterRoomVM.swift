//
//  EnterRoomVM.swift
//  AnimalPicker
//
//  Created by Sandy on 6/7/24.
//

import Foundation

class EnterRoomVM: BaseViewModel {
    private let interactors: DIContainer.Interactors
    private let services: DIContainer.Services
    
    let roomData: RoomData
    @Published var enterRoom: Bool = false
    init(_ interactors: DIContainer.Interactors, services: DIContainer.Services, roomData: RoomData) {
        self.interactors = interactors
        self.services = services
        self.roomData = roomData
        super.init()
    }
    
    deinit {
        
    }
    
    func onAppear() {
        self.enterRoom = false
    }
    
    func onDisappear() {
        
    }
    
    func enterRoom(nickname: String) {
        let deviceId = services.keychainService.loadDeviceId()
        if deviceId.isEmpty || nickname.isEmpty { return }
        
        self.services.realtimeRoomListDBService.enterTheRoom(roomId: roomData.id, deviceID: deviceId, memberIds: roomData.memberIds ?? [], memberName: nickname)
        self.enterRoom = true
    }
}


