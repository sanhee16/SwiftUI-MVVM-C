//
//  FirestoreService.swift
//  AnimalPicker
//
//  Created by Sandy on 5/29/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

enum FirestoreError: Error {
    case noData
}

enum FirestoreTable: String {
    case ranking = "Ranking"
}


class FirestoreService {
    private let db: Firestore
    
    init() {
        self.db = Firestore.firestore()
    }
    
    func save(table: FirestoreTable, value: [String : Any]) {
        let path = self.db.collection(table.rawValue).document()
        var saveValue = value
        saveValue["id"] = path.documentID
        path.setData(saveValue)
    }
    
    func load(table: FirestoreTable) -> AnyPublisher<[[String : Any]], Error> {
        let future: (() -> Deferred) = { () -> Deferred<Future<[[String: Any]], Error>> in
            return Deferred {
                Future<[[String: Any]], Error> { promise in
                    self.db.collection(table.rawValue).getDocuments { (snapshot, err) in
                        if let err = err {
                            print(err)
                        } else {
                            guard let snapshot = snapshot else { return }
                            promise(.success(snapshot.documents.map({ $0.data() })))
                        }
                    }
                }
            }
        }
        return future().eraseToAnyPublisher()
    }
    
    func load(table: FirestoreTable, id: String) -> AnyPublisher<[String : Any], Error> {
        let future: (() -> Deferred) = { () -> Deferred<Future<[String: Any], Error>> in
            return Deferred {
                Future<[String: Any], Error> { promise in
                    self.db.collection(table.rawValue).getDocuments { (snapshot, err) in
                        if let err = err {
                            print(err)
                        } else {
                            guard let snapshot = snapshot else { return }
                            for document in snapshot.documents {
                                if document.documentID == id {
                                    promise(.success(document.data()))
                                } else {
                                    promise(.failure(FirestoreError.noData) )
                                }
                            }
                        }
                    }
                }
            }
        }
        return future().eraseToAnyPublisher()
    }
    
    func update(table: FirestoreTable, id: String, value: [String : Any]) {
        let path = self.db.collection(table.rawValue).document(id)
        path.updateData(value)
    }
    
    func delete(table: FirestoreTable, id: String, value: [String : Any]) {
        let path = self.db.collection(table.rawValue).document(id)
        path.delete()
    }
}
