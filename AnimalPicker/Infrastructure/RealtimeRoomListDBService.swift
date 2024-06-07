//
//  RealtimeDBService.swift
//  AnimalPicker
//
//  Created by Sandy on 6/3/24.
//

import Foundation
import FirebaseDatabase
import Combine

class RealtimeRoomListDBService {
    private let ref: DatabaseReference
    private let databasePath: DatabaseReference
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    var roomlistChangedSubject: CurrentValueSubject<[RoomData], Error>
    private var list: [RoomData] = []
    
    init() {
        self.ref = Database.database().reference()
        self.databasePath = self.ref.child("rooms")
        self.roomlistChangedSubject = .init(self.list)
        self.start()
    }
    
    func createRoom(name: String, password: Int?, managerDeviceId: String, memberName: String) {
        let roomId = UUID().uuidString
        var room = RoomData(id: roomId, name: name, status: MultiGameStatus.none.rawValue, managerDeviceId: managerDeviceId, memberIds: [managerDeviceId], items: []).toDictionary()!
        
        if let password = password {
            room["password"] = password
        }

        self.databasePath.child("\(roomId)").setValue(room)
        
        self.enterTheRoom(roomId: roomId, deviceID: managerDeviceId, memberIds: [managerDeviceId], memberName: memberName)
    }
    
    
    func deleteRoom(roomId: String) {
        self.databasePath.child("\(roomId)").removeValue()
    }
    
    func enterTheRoom(roomId: String, deviceID: String, memberIds: [String], memberName: String) {
        let member = MultiGameMemberData(
            id: deviceID,
            name: memberName, 
            time: 0.0,
            status: MultiGameStatus.none.rawValue
        ).toDictionary()
        
        self.databasePath.child("\(roomId)/members/\(deviceID)").setValue(member)
        
        var ids = memberIds
        ids.append(deviceID)
        ids = Array(Set(ids))
        self.databasePath.child("\(roomId)").updateChildValues(["memberIds": ids])
    }
    
    private func start() {  
        self.list.removeAll()
        
        databasePath.observe(.childAdded) {[weak self] snapshot, _ in
            guard let self = self, let json = snapshot.value as? [String: Any] else { return }
            do {
                let roomData = try JSONSerialization.data(withJSONObject: json)
                let room = try self.decoder.decode(RoomData.self, from: roomData)

                print("[childAdded] room: \(room)")
                self.list.append(room)
                self.roomlistChangedSubject.send(self.list)
            } catch {
                print("[childAdded] an error occurred", error)
            }
        }
        
        databasePath.observe(.childChanged) {[weak self] snapshot, _ in
            guard let self = self, let json = snapshot.value as? [String: Any] else { return }
            do {
                let roomData = try JSONSerialization.data(withJSONObject: json)
                let room = try self.decoder.decode(RoomData.self, from: roomData)
                
                if let idx = self.list.firstIndex(where: { $0.id == room.id }) {
                    self.list[idx] = room
                }
                self.roomlistChangedSubject.send(self.list)
            } catch {
                print("[childChanged] an error occurred", error)
            }
        }
        
        databasePath.observe(.childRemoved) {[weak self] snapshot, _ in
            guard let self = self, let json = snapshot.value as? [String: Any] else { return }
            do {
                let roomData = try JSONSerialization.data(withJSONObject: json)
                let room = try self.decoder.decode(RoomData.self, from: roomData)
                for (idx, roomItem) in self.list.enumerated() where room.id == roomItem.id {
                    self.list.remove(at: idx)
                }
                self.roomlistChangedSubject.send(self.list)
            } catch {
                print("[childRemoved] an error occurred", error)
            }
        }
        
        // 경로에 있는 컨텐츠의 모든 변경 내용을 감지하고 읽어온다.
//        databasePath.observe(.value) {[weak self] snapshot in
//            guard let self = self, let json = snapshot.value as? [String: Any] else { return }
//            do {
//                let roomData = try JSONSerialization.data(withJSONObject: json)
//                let room = try self.decoder.decode(RoomData.self, from: roomData)
//                for (idx, roomItem) in self.roomList.enumerated() where room.id == roomItem.id {
//                    self.list[idx] = room
//                }
//                self.roomChangedSubject.send(self.list)
//            } catch {
//                print("[observe] an error occurred", error)
//            }
//        }
    }
    
    private func stop() {
        self.roomlistChangedSubject.send(completion: .finished)
        self.ref.removeAllObservers()
    }
}
