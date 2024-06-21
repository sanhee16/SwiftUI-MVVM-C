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
        if let room = self.list.first(where: { $0.id == roomId }), let members = room.members, members.keys.contains(where: { $0 == self.deviceId }) {
            return room
        }
        return nil
    }

    
    private func removeRoom(roomId: String) {
        
    }
    
    func quitRoom() {
        guard let deviceId = self.deviceId, let room = self.participatingRoom else { return }
        if room.managerId == deviceId {
            print("[SD] quitRoom - manager")
            self.services.multiGameService.removeRoom(roomId: room.id)
        } else {
            print("[SD] quitRoom - normal")
            self.services.multiGameService.removeMember(roomId: room.id, memberId: deviceId)
        }
    }
    
    func observeList() {
        self.services.multiGameService.roomListSubject
            .run(in: &self.subscription) {[weak self] response in
                guard let self = self else { return }
                self.list = response
                self.participatingRoom = nil
                
                response.forEach { item in
                    if let members = item.members, members.keys.contains(where: { $0 == self.deviceId }) {
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


