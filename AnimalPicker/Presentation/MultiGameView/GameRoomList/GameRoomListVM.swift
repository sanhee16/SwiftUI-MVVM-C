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
    @Published var participatingRoom: RoomData? = nil
    let deviceId: String?
    
    init(_ interactors: DIContainer.Interactors, services: DIContainer.Services) {
        self.interactors = interactors
        self.services = services
        self.deviceId = self.services.keychainService.loadDeviceId()
        super.init()
        self.observeList()
    }
    
    deinit {
        
    }
    
    func onAppear() {

    }
    
    func onDisappear() {
        
    }
    
    func isExistedMember(roomId: String) -> RoomData? {
        let deviceId = self.services.keychainService.loadDeviceId()
        print("list: \(self.list)")
        print("roomId: \(roomId)")
        if let room = self.list.first(where: { $0.id == roomId }) {
            print("room exist - \(room.memberIds)")
            if (room.memberIds ?? []).contains(deviceId) {
                return room
            }
        }
        return nil
    }
    
    private func removeRoom(roomId: String) {
        self.services.realtimeRoomDBService.deleteRoom(roomId: roomId)
    }
    
    func observeList() {
        self.services.realtimeRoomDBService.roomChangedSubject
            .run(in: &self.subscription) {[weak self] response in
                guard let self = self else { return }
                self.list = response
                self.participatingRoom = nil
                response.forEach { item in
                    if (item.memberIds ?? []).contains(where: { $0 == self.deviceId }) {
                        self.participatingRoom = item
                        return
                    }
                }
            } err: {[weak self] err in
                guard let self = self else { return }
                print(err)
            } complete: {
                
            }
    }
}


