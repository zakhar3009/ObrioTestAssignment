//
//  DataService.swift
//  ObrioTestAssignment
//
//  Created by Zakhar Litvinchuk on 01.04.2025.
//

import Foundation
import CoreData

class DataService {
    private var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DBDataModel")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveChanges() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            fatalError("Eror saving context: \(error.localizedDescription)")
        }
    }
    
    func fetchBatch<T: NSManagedObject>(offset: Int, limit: Int) throws -> [T] {
        let request: NSFetchRequest<T> = NSFetchRequest<T>(entityName: String(describing: T.self))
        request.fetchOffset = offset
        request.fetchLimit = limit
        return try context.fetch(request)
    }
    
    func removeAll<T: NSManagedObject>(_ model: T.Type) throws {
        let fetchRequest = T.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try context.execute(deleteRequest)
        saveChanges()
    }
}
