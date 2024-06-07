//
//  CreateRoomVM.swift
//  AnimalPicker
//
//  Created by Sandy on 6/4/24.
//

import Foundation

class CreateRoomVM: BaseViewModel {
    private let interactors: DIContainer.Interactors
    private let services: DIContainer.Services
    let deviceId: String?
    
    init(interactors: DIContainer.Interactors, services: DIContainer.Services) {
        self.interactors = interactors
        self.services = services
        self.deviceId = self.services.keychainService.loadDeviceId()
        super.init()
    }
    
    func onAppear() {
        
    }
    
    func onClickCreateRoom(roomName: String, password: String, nickname: String) {
        if roomName.isEmpty || nickname.isEmpty { return }
        guard let deviceId = self.deviceId else { return }
        self.services.realtimeRoomDBService.addRoom(name: roomName, password: Int(password), managerDeviceId: deviceId, memberName: nickname)
        self.isPop = true
    }
}
