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
    func setupCloudSyncNotifications()

    func fetchTasks() async throws -> [TaskEntity]?
    func createTask(_ task: TaskItem) async throws
    func updateTask(_ task: TaskItem) async throws
    func delete(_ task: TaskItem) async throws
    
    func fetchSleepInstructions() async throws -> [SleepInstruction]?
    func createSleepInstruction(_ item: SleepInstruction) async throws
    func updateSleepInstruction(_ item: SleepInstruction) async throws
}

class CoreDataService: CoreDataServiceProtocol {
    
    // MARK: - Singleton
    
    static let shared = CoreDataService()
    
    // MARK: - Properties
    
    private let container: NSPersistentCloudKitContainer
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
        Task {
            try? await saveContext()
        }
    }
}

extension CoreDataService {
    
    // MARK: - Public Implementations
    
    func createTask(_ task: TaskItem) async throws {
        let taskEntity = TaskEntity(context: viewContext)
        taskEntity.update(from: task)
        try await saveContext()
    }
    
    func updateTask(_ task: TaskItem) async throws {
        guard let taskEntity = try await fetchTask(for: task.id) else { return }
        taskEntity.update(from: task)
        try await saveContext()
    }
    
    func delete(_ task: TaskItem) async throws {
        guard let taskEntity = try await fetchTask(for: task.id) else { return }
        viewContext.delete(taskEntity)
        try await saveContext()
    }
    
    func fetchTasks() async throws -> [TaskEntity]? {
        try await viewContext.perform {
            let request = NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
            request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskEntity.createdAt, ascending: true)]
            return try self.viewContext.fetch(request)
        }
    }
    
    // MARK: - Private Implementations
    
    private func fetchTask(for id: UUID) async throws -> TaskEntity? {
        try await viewContext.perform {
            let request = NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
            request.predicate = NSPredicate(format: "%K == %@", "id", id as CVarArg)
            request.fetchLimit = 1
            return try self.viewContext.fetch(request).first
        }
    }
    
    private func saveContext() async throws {
        try await viewContext.perform {
            guard self.viewContext.hasChanges else { return }
            try self.viewContext.save()
        }
    }
}

extension CoreDataService {
    
    // MARK: - Public Implementations
    
    func createSleepInstruction(_ item: SleepInstruction) async throws {
        let instructionEntity = SleepInstructionEntity(context: viewContext)
        try instructionEntity.update(from: item)
        try await saveContext()
    }
    
    func updateSleepInstruction(_ item: SleepInstruction) async throws {
        guard let instructionEntity = try await fetchSleepInstructionEntity(for: item.id) else {
            print("SleepInstruction with id \(item.id) not found for update.")
            return
        }
        try instructionEntity.update(from: item)
        try await saveContext()
    }
    
    func fetchSleepInstructions() async throws -> [SleepInstruction]? {
        try await viewContext.perform {
            let request = NSFetchRequest<SleepInstructionEntity>(entityName: "SleepInstructionEntity")
            return try self.viewContext.fetch(request).map { try $0.toSleepInstruction() }
        }
    }
    
    // MARK: - Private Implementations
    
    private func fetchSleepInstructionEntity(for id: UUID) async throws -> SleepInstructionEntity? {
        try await viewContext.perform {
            let request = NSFetchRequest<SleepInstructionEntity>(entityName: "SleepInstructionEntity")
            request.predicate = NSPredicate(format: "%K == %@", "id", id as CVarArg)
            request.fetchLimit = 1
            return try self.viewContext.fetch(request).first
        }
    }
}
