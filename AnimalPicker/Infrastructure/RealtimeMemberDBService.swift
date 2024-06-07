//
//  RealtimeMemberDBService.swift
//  AnimalPicker
//
//  Created by Sandy on 6/7/24.
//

import Foundation
import FirebaseDatabase
import Combine

class RealtimeMemberDBService {
    private let ref: DatabaseReference
    private var databasePath: DatabaseReference?
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var roomId: String? = nil
    
    var memberChangedSubject: CurrentValueSubject<[MultiGameMemberData], Error>
    private var list: [MultiGameMemberData] = []
    
    init() {
        self.ref = Database.database().reference()
        self.databasePath = nil
        self.memberChangedSubject = .init(self.list)
    }
    
    func updateRoomId(roomId: String) {
        self.databasePath = self.ref.child("rooms/\(roomId)/members")
        self.roomId = roomId
        self.list.removeAll()
        self.start()
    }
    
    func changeStatus(memberId: String, status: MultiGameStatus) {
        self.databasePath?.child("\(memberId)").updateChildValues(["status": status.rawValue])
    }
    
    func removeMember(memberId: String) {
        self.databasePath?.child("\(memberId)").removeValue()
    }
    
    func clear(memberId: String, time: Float) {
        self.databasePath?.child("\(memberId)").updateChildValues(["time": time])
        self.databasePath?.child("\(memberId)").updateChildValues(["status": MultiGameStatus.clear.rawValue])
    }
    
    private func start() {
        databasePath?.observe(.childAdded) {[weak self] snapshot, _ in
            guard let self = self, let json = snapshot.value as? [String: Any] else { return }
            do {
                let memberData = try JSONSerialization.data(withJSONObject: json)
                let member = try self.decoder.decode(MultiGameMemberData.self, from: memberData)
                
                self.list.append(member)
                self.memberChangedSubject.send(self.list)
            } catch {
                print("[childAdded] an error occurred", error)
            }
        }
        
        databasePath?.observe(.childChanged) {[weak self] snapshot, _ in
            guard let self = self, let json = snapshot.value as? [String: Any] else { return }
            do {
                let memberData = try JSONSerialization.data(withJSONObject: json)
                let member = try self.decoder.decode(MultiGameMemberData.self, from: memberData)
                
                if let idx = self.list.firstIndex(where: { $0.id == member.id }) {
                    self.list[idx] = member
                }
                self.memberChangedSubject.send(self.list)
            } catch {
                print("[childChanged] an error occurred", error)
            }
        }
        
        databasePath?.observe(.childRemoved) {[weak self] snapshot, _ in
            guard let self = self, let json = snapshot.value as? [String: Any] else { return }
            do {
                let memberData = try JSONSerialization.data(withJSONObject: json)
                let member = try self.decoder.decode(MultiGameMemberData.self, from: memberData)
                
                for (idx, memberItem) in self.list.enumerated() where member.id == memberItem.id {
                    self.list.remove(at: idx)
                }
                self.memberChangedSubject.send(self.list)
            } catch {
                print("[childRemoved] an error occurred", error)
            }
        }
        
        // 경로에 있는 컨텐츠의 모든 변경 내용을 감지하고 읽어온다.
//        databasePath?.observe(.value) {[weak self] snapshot in
//            guard let self = self, let json = snapshot.value as? [String: Any] else { return }
//            do {
//                let memberData = try JSONSerialization.data(withJSONObject: json)
//                let member = try self.decoder.decode(MultiGameMemberData.self, from: memberData)
//
//                for (idx, memberItem) in self.list.enumerated() where member.id == memberItem.id {
//                    self.list[idx] = member
//                }
//                self.memberChangedSubject.send(self.list)
//            } catch {
//                print("[observe] an error occurred", error)
//            }
//        }
    }
    
    private func stop() {
        self.memberChangedSubject.send(completion: .finished)
        self.ref.removeAllObservers()
    }
}
