//
//  CoreDataService.swift
//  SyncTasker
//
//  Created by ingvar on 10.02.2025.
//

import CoreData

protocol CoreDataServiceProtocol {
    var viewContext: NSManagedObjectContext { get }
    func createItem() -> Item
    func saveContext() throws
    func delete(_ object: NSManagedObject) throws
}

// MARK: - Error Handling
enum CoreDataError: LocalizedError {
    case saveFailed(Error)
    case deleteFailed(Error)
    case fetchFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .saveFailed(let error):
            return "Failed to save: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete: \(error.localizedDescription)"
        case .fetchFailed(let error):
            return "Failed to fetch: \(error.localizedDescription)"
        }
    }
}

class CoreDataService: CoreDataServiceProtocol {
    // MARK: - Singleton
    static let shared = CoreDataService()
    
    // MARK: - Properties
    let container: NSPersistentContainer
    var viewContext: NSManagedObjectContext { container.viewContext }
    
    // MARK: - Initialization
    init() {
        container = NSPersistentContainer(name: "SyncTasker")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - CoreDataServiceProtocol
    func createItem() -> Item {
        return Item(context: viewContext)
    }
    
    func saveContext() throws {
        guard viewContext.hasChanges else { return }
        
        do {
            try viewContext.save()
        } catch {
            throw CoreDataError.saveFailed(error)
        }
    }
    
    func delete(_ object: NSManagedObject) throws {
        viewContext.delete(object)
        do {
            try saveContext()
        } catch {
            throw CoreDataError.deleteFailed(error)
        }
    }
}
