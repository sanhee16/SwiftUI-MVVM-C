//
//  CoreDataService.swift
//  AnimalPicker
//
//  Created by Sandy on 5/27/24.
//

import Foundation
import UIKit
import CoreData

protocol CoreDataService {
    var container: NSPersistentContainer { get set }
}

extension CoreDataService {
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
