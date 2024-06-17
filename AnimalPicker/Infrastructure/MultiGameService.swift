//
//  MultiGameService.swift
//  AnimalPicker
//
//  Created by Sandy on 6/11/24.
//

import Foundation
import FirebaseDatabase
import Firebase
import Combine

class MultiGameService {
    private let ref: DatabaseReference
    private let databasePath: DatabaseReference
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    var roomListSubject: CurrentValueSubject<[RoomData], Error>
    var roomSubject: CurrentValueSubject<RoomData?, Error>

    private var roomList: [RoomData] = []
    private var room: RoomData? = nil
    
    var roomObserver: UInt? = nil
    
    init() {
        self.ref = Database.database().reference()
        self.databasePath = self.ref.child("rooms")
        self.roomListSubject = .init(self.roomList)
        self.roomSubject = .init(self.room)
        
        self.startToRoomListObserve()
    }
    
    //MARK: Member
    func clear(roomId: String, memberId: String, time: Float) {
        self.databasePath.child("\(roomId)/members/\(memberId)").updateChildValues([
            "status": MultiGameStatus.clear.rawValue,
            "time": time
        ])
    }
    
    func ready(roomId: String, memberId: String) {
        self.databasePath.child("\(roomId)/members/\(memberId)").updateChildValues([
            "status": MultiGameStatus.ready.rawValue,
            "time": 0.0
        ])
    }
    
    func finishToLoadImages(roomId: String, memberId: String) {
        self.changeMemberStatus(roomId: roomId, memberId: memberId, status: .loadFinish)
    }
    
    private func changeMemberStatus(roomId: String, memberId: String, status: MultiGameStatus) {
        self.databasePath.child("\(roomId)/members/\(memberId)").updateChildValues(["status": status.rawValue])
    }
    
    func removeMember(roomId: String, memberId: String) {
        self.databasePath.child("\(roomId)/members/\(memberId)").removeValue()
    }
    
    
    
    //MARK: Room
    func allFinishToLoadImages(roomId: String) {
        self.changeRoomStatus(roomId: roomId, status: .onGaming)
    }
    
    func allReady(roomId: String) {
        self.changeRoomStatus(roomId: roomId, status: .ready)
    }
    
    func allClear(roomId: String) {
        self.changeRoomStatus(roomId: roomId, status: .clear)
    }
    
    func loadGameItems(roomId: String, answer: String, items: [GameItem]) {
        let gameItems = items.map {
            GameItem(id: $0.id, type: $0.type, url: $0.url).toDictionary()
        }
        
        self.databasePath.child("\(roomId)").updateChildValues([
            "answer": answer,
            "items": gameItems,
            "status": MultiGameStatus.loading.rawValue
        ])
    }
    
    private func changeRoomStatus(roomId: String, status: MultiGameStatus) {
        self.databasePath.child("\(roomId)").updateChildValues(["status": status.rawValue])
    }
    
    func removeRoom(roomId: String) {
        self.databasePath.child("\(roomId)").removeValue()
    }
    
    
    
    //MARK: RoomList
    func createRoom(roomName: String, password: Int? = nil, managerId: String, memberName: String) {
        let roomId = UUID().uuidString
        
        var room = RoomData(
            id: roomId,
            name: roomName,
            status: MultiGameStatus.ready.rawValue,
            managerId: managerId,
            members: [:],
            items: []
        ).toDictionary()!
        
        if let password = password {
            room["password"] = password
        }
        
        self.databasePath.child("\(roomId)").setValue(room)
        self.enterRoom(roomId: roomId, memberId: managerId, memberName: memberName)
    }
    
    func enterRoom(roomId: String, memberId: String, memberName: String) {
        let member = MultiGameMemberData(
            id: memberId,
            name: memberName,
            time: 0.0,
            status: MultiGameStatus.ready.rawValue
        ).toDictionary()

        self.databasePath.child("\(roomId)/members/\(memberId)").setValue(member)
    }
    
    func startToRoomObserve(roomId: String) {
        if let roomObserver = self.roomObserver {
            self.databasePath.child("\(roomId)").removeObserver(withHandle: roomObserver)
        }
        
        self.roomObserver = self.databasePath.child("\(roomId)").observe(.value) {[weak self] snapshot in
            guard let self = self, let json = snapshot.value as? [String: Any] else { return }
            do {
                let data = try JSONSerialization.data(withJSONObject: json)
                let result = try self.decoder.decode(RoomData.self, from: data)
                self.room = result
                self.roomSubject.send(self.room)
            } catch {
                print("[observe room] an error occurred", error)
            }
        }
    }
    
    private func startToRoomListObserve() {
        self.roomList.removeAll()
        
        //MARK: Room List
        databasePath.observe(.childAdded) {[weak self] snapshot in
            guard let self = self, let json = snapshot.value as? [String: Any] else { return }
            do {
                let data = try JSONSerialization.data(withJSONObject: json)
                let result = try self.decoder.decode(RoomData.self, from: data)
                
                self.roomList.append(result)
                self.roomListSubject.send(self.roomList)
            } catch {
                print("[observe roomlist] an error occurred", error)
            }
        }
        
        databasePath.observe(.childChanged) {[weak self] snapshot in
            guard let self = self, let json = snapshot.value as? [String: Any] else { return }
            do {
                let data = try JSONSerialization.data(withJSONObject: json)
                let result = try self.decoder.decode(RoomData.self, from: data)
                
                if let idx = self.roomList.firstIndex(where: { $0.id == result.id }) {
                    self.roomList[idx] = result
                }
                self.roomListSubject.send(self.roomList)
            } catch {
                print("[observe roomlist] an error occurred", error)
            }
        }
        
        databasePath.observe(.childRemoved) {[weak self] snapshot in
            guard let self = self, let json = snapshot.value as? [String: Any] else { return }
            do {
                let data = try JSONSerialization.data(withJSONObject: json)
                let result = try self.decoder.decode(RoomData.self, from: data)
                
                if let idx = self.roomList.firstIndex(where: { $0.id == result.id }) {
                    self.roomList.remove(at: idx)
                }
                
                self.roomListSubject.send(self.roomList)
            } catch {
                print("[observe roomlist] an error occurred", error)
            }
        }
        
    }
    
    
}
