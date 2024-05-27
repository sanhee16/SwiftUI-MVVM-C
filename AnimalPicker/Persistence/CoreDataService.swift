//
//  CoreDataService.swift
//  AnimalPicker
//
//  Created by Sandy on 5/27/24.
//

import Foundation
import UIKit
import CoreData

class CoreDataService {
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "animal_picker_db")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
