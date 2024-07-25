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
    case parsingError
}

enum FirestoreTable: String {
    case ranking = "Ranking"
    case test = "RankingTest"
}


protocol FirestoreService {
    var db: Firestore { get set }
    func save(table: FirestoreTable, value: [String : Any]) -> AnyPublisher<String, Error>
    func load(table: FirestoreTable) -> AnyPublisher<[[String : Any]], Error>
    func load(table: FirestoreTable, id: String) -> AnyPublisher<[String : Any], Error>
    func update(table: FirestoreTable, id: String, value: [String : Any])
    func delete(table: FirestoreTable, id: String, value: [String : Any])
}

class RealFirestoreService: FirestoreService {
    var db: Firestore
    
    init() {
        self.db = Firestore.firestore()
    }
    
    func save(table: FirestoreTable, value: [String : Any]) -> AnyPublisher<String, Error> {
        let path = self.db.collection(table.rawValue).document()
        var saveValue = value
        let documentID = path.documentID
        saveValue["id"] = documentID
        let future: (() -> Deferred) = { () -> Deferred<Future<String, Error>> in
            return Deferred {
                Future<String, Error> { promise in
                    path.setData(saveValue) { err in
                        if let err = err {
                            promise(.failure(err))
                            return
                        } else {
                            promise(.success(documentID))
                            return
                        }
                    }
                }
            }
        }
        return future().eraseToAnyPublisher()
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
