//
//  GameRoomListVM.swift
//  AnimalPicker
//
//  Created by Sandy on 6/3/24.
//

import Foundation
import Combine

class GameRoomListVM: BaseViewModel {
    private let interactors: DIContainer.Interactors
    private let services: DIContainer.Services

    @Published var list: [RoomData] = []
    @Published var myRoom: RoomData? = nil
    let deviceId: String?
    
    init(_ interactors: DIContainer.Interactors, services: DIContainer.Services) {
        self.interactors = interactors
        self.services = services
        self.deviceId = self.services.keychainService.loadDeviceId()
        super.init()
    }
    
    deinit {
        
    }
    
    func onAppear() {
        self.observeList()
    }
    
    func onDisappear() {
        
    }
    
    private func removeRoom() {
        if let joinedRoomId = Constants.joinedRoomId {
            self.services.realtimeRoomDBService.deleteRoom(roomId: joinedRoomId)
            Constants.joinedRoomId = nil
            self.myRoom = nil
        }
    }
    
    func observeList() {
        self.services.realtimeRoomDBService.roomChangedSubject
            .run(in: &self.subscription) {[weak self] response in
                guard let self = self else { return }
                print("list update: \(response)")
                self.list = response
                response.forEach { item in
                    if let deviceId = self.deviceId {
                        Constants.joinedRoomId = item.id
                        self.myRoom = item
                    }
                }
            } err: {[weak self] err in
                guard let self = self else { return }
                print(err)
            } complete: {
                
            }
    }
}


