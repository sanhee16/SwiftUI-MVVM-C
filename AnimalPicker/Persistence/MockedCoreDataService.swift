//
//  MockedCoreDataService.swift
//  AnimalPicker
//
//  Created by Sandy on 7/22/24.
//

import Foundation
import UIKit
import CoreData

class MockedCoreDataService: CoreDataService {
    lazy var container: NSPersistentContainer = {
        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null")
        
        let container = NSPersistentContainer(name: "animal_picker_db")
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
}
