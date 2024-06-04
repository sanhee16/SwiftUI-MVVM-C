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
    private var name: String = ""
    @Published var list: [RoomData] = []
    
    
    init(_ interactors: DIContainer.Interactors, services: DIContainer.Services) {
        self.interactors = interactors
        self.services = services
        super.init()
    }
    
    deinit {
        if let joinedRoomId = Constants.joinedRoomId {
            Constants.joinedRoomId = nil
            self.services.realtimeRoomDBService.deleteRoom(roomId: joinedRoomId)
        }
    }
    
    func onAppear() {
        self.observeList()
    }
    
    func onDisappear() {
        
    }
    
    func onClickAddRoom() {
        self.name = "Sample \(UUID().uuidString)"
        self.services.realtimeRoomDBService.addRoom(name: self.name, password: 1234, memberName: "sandy")
    }
    
    func observeList() {
        self.services.realtimeRoomDBService.roomChangedSubject
            .run(in: &self.subscription) {[weak self] response in
                guard let self = self else { return }
                print("list update: \(response)")
                self.list = response
                response.forEach { item in
                    if item.name == self.name, !self.name.isEmpty {
                        Constants.joinedRoomId = item.id
                    }
                }
            } err: {[weak self] err in
                guard let self = self else { return }
                print(err)
            } complete: {
                
            }
    }
}


