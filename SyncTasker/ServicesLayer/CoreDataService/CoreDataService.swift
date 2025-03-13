//
//  CoreDataService.swift
//  SyncTasker
//
//  Created by ingvar on 10.02.2025.
//

import CoreData
import CloudKit

protocol CoreDataServiceProtocol {
    var viewContext: NSManagedObjectContext { get }
    func createTask(_ task: TaskItem) throws
    func saveContext() throws
    func delete(_ object: NSManagedObject) throws
    func fetchTasks() throws -> [TaskEntity]
    func setupCloudSyncNotifications()
}

// MARK: - Error Handling
enum CoreDataError: LocalizedError {
    case saveFailed(Error)
    case deleteFailed(Error)
    case fetchFailed(Error)
    case cloudKitError(Error)
    
    var errorDescription: String? {
        switch self {
        case .saveFailed(let error):
            return "Failed to save: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete: \(error.localizedDescription)"
        case .fetchFailed(let error):
            return "Failed to fetch: \(error.localizedDescription)"
        case .cloudKitError(let error):
            return "CloudKit error: \(error.localizedDescription)"
        }
    }
}

class CoreDataService: CoreDataServiceProtocol {
    // MARK: - Singleton
    static let shared = CoreDataService()
    
    // MARK: - Properties
    let container: NSPersistentCloudKitContainer
    var viewContext: NSManagedObjectContext { container.viewContext }
    
    // MARK: - Initialization
    init() {
        container = NSPersistentCloudKitContainer(name: "SyncTasker")
        
        // Enable remote notifications
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        // Configure CloudKit sharing
        if let description = container.persistentStoreDescriptions.first {
            description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.yourdomain.SyncTasker")
            description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        }
        
        container.loadPersistentStores { description, error in
            if let error { fatalError("Core Data failed to load: \(error.localizedDescription)") }
        }
        
        setupCloudSyncNotifications()
    }
    
    // MARK: - CloudKit Setup
    func setupCloudSyncNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(managedObjectContextDidChange),
            name: .NSManagedObjectContextDidSave,
            object: container.viewContext
        )
    }
    
    @objc private func managedObjectContextDidChange(notification: NSNotification) {
        try? saveContext()
    }
    
    // MARK: - CoreDataServiceProtocol
    
    func createTask(_ task: TaskItem) throws {
        let taskEntity = TaskEntity(context: viewContext)
        taskEntity.update(from: task)
        do {
            try viewContext.save()
        } catch {
            throw CoreDataError.saveFailed(error)
        }
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
    
    func fetchTasks() throws -> [TaskEntity] {
        let request = NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskEntity.createdAt, ascending: true)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            throw CoreDataError.fetchFailed(error)
        }
    }
}
