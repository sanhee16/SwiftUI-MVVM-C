//
//  RealtimeRoomDBService.swift
//  AnimalPicker
//
//  Created by Sandy on 6/7/24.
//

import Foundation
import FirebaseDatabase
import Combine

class RealtimeRoomDBService {
    private let ref: DatabaseReference
    private var databasePath: DatabaseReference?
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var roomId: String? = nil
    
    var roomChangedSubject: CurrentValueSubject<RoomData?, Error>
    private var roomData: RoomData? = nil
    
    init() {
        self.ref = Database.database().reference()
        self.databasePath = nil
        self.roomChangedSubject = .init(self.roomData)
    }
    
    func updateRoomId(roomId: String) {
        self.databasePath = self.ref.child("rooms/\(roomId)")
        self.roomId = roomId
        self.start()
    }
    
    func changeStatus(status: MultiGameStatus) {
        self.databasePath?.updateChildValues(["status": status.rawValue])
    }
    
    func removeRoom() {
        self.databasePath?.removeValue()
    }
    
    private func start() {
        self.roomData = nil
        
//        databasePath?.observe(.childAdded) {[weak self] snapshot, _ in
//            guard let self = self, let json = snapshot.value as? [String: Any] else { return }
//            do {
//                let roomData = try JSONSerialization.data(withJSONObject: json)
//                let room = try self.decoder.decode(RoomData.self, from: roomData)
//                self.roomData = room
//                self.roomChangedSubject.send(self.roomData)
//            } catch {
//                print("[childAdded] an error occurred", error)
//            }
//        }
//        
//        databasePath?.observe(.childChanged) {[weak self] snapshot, _ in
//            guard let self = self, let json = snapshot.value as? [String: Any] else { return }
//            do {
//                let roomData = try JSONSerialization.data(withJSONObject: json)
//                let room = try self.decoder.decode(RoomData.self, from: roomData)
//                self.roomData = room
//                self.roomChangedSubject.send(self.roomData)
//            } catch {
//                print("[childChanged] an error occurred", error)
//            }
//        }
//        
//        databasePath?.observe(.childRemoved) {[weak self] snapshot, _ in
//            guard let self = self, let json = snapshot.value as? [String: Any] else { return }
//            do {
//                let roomData = try JSONSerialization.data(withJSONObject: json)
//                let room = try self.decoder.decode(RoomData.self, from: roomData)
//                self.roomData = room
//                self.roomChangedSubject.send(self.roomData)
//            } catch {
//                print("[childRemoved] an error occurred", error)
//            }
//        }
        
        // 경로에 있는 컨텐츠의 모든 변경 내용을 감지하고 읽어온다.
        databasePath?.observe(.value) {[weak self] snapshot in
            guard let self = self, let json = snapshot.value as? [String: Any] else { return }
            do {
                let roomData = try JSONSerialization.data(withJSONObject: json)
                let room = try self.decoder.decode(RoomData.self, from: roomData)
                self.roomData = room
                self.roomChangedSubject.send(self.roomData)
            } catch {
                print("[observe] an error occurred", error)
            }
        }
    }
    
    private func stop() {
        self.roomChangedSubject.send(completion: .finished)
        self.ref.removeAllObservers()
    }
}
