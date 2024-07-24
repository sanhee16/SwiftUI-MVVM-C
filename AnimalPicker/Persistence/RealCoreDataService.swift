//
//  RealCoreDataService.swift
//  AnimalPicker
//
//  Created by Sandy on 7/22/24.
//

import Foundation
import UIKit
import CoreData

class RealCoreDataService: CoreDataService {
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "animal_picker_db")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
}
