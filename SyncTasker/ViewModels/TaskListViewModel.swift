//
//  TaskListViewModel.swift
//  SyncTasker
//
//  Created by ingvar on 10.02.2025.
//

import Foundation
import CoreData

class TaskListViewModel: NSObject, ObservableObject {
    
    // MARK: - Properties
    private let coreDataService: CoreDataService
    private let fetchController: NSFetchedResultsController<Item>
    
    @Published var errorMessage: String?
    @Published var items: [Item] = []
    
    // MARK: - Initialization
    override init() {
        self.coreDataService = CoreDataService.shared
        
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)]
        
        self.fetchController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: coreDataService.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        super.init()
        
        self.fetchController.delegate = self
        self.loadItems()
    }
    
    // MARK: - Public Methods
    func addTask() {
        let newItem = coreDataService.createItem()
        newItem.timestamp = Date()
        
        do {
            try coreDataService.saveContext()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteTask(_ task: Item) {
        do {
            try coreDataService.delete(task)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Private Methods
    private func loadItems() {
        do {
            try fetchController.performFetch()
            items = fetchController.fetchedObjects ?? []
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TaskListViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        items = controller.fetchedObjects as? [Item] ?? []
    }
}
