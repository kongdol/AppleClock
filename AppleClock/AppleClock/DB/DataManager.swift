//
//  DataManager.swift
//  AppleClock
//
//  Created by yk on 4/1/25.
//

import CoreData
import Foundation

class DataManager {
    static let shared = DataManager()
    
    private let persistentContainer: NSPersistentContainer
    let mainContext: NSManagedObjectContext
    let worldClockFetchedResults: NSFetchedResultsController<WorldClockEntity>
    
    private init() {
        let contatiner = NSPersistentContainer(name: "Clock")
        contatiner.loadPersistentStores { description, error in
            if let error {
                fatalError(error.localizedDescription)
            }
        }
        
        persistentContainer = contatiner
        mainContext = persistentContainer.viewContext
        
        let worldClockRequest = WorldClockEntity.fetchRequest()
        
        let sortByOrderAsc = NSSortDescriptor(keyPath: \WorldClockEntity.order, ascending: true)
        worldClockRequest.sortDescriptors = [sortByOrderAsc]
        
        worldClockFetchedResults = NSFetchedResultsController(fetchRequest: worldClockRequest, managedObjectContext: mainContext, sectionNameKeyPath: nil, cacheName: nil)
        
        
        
        do {
            try worldClockFetchedResults.performFetch()
        } catch {
            print(error)
        }
    }
    
    func save() {
        if mainContext.hasChanges {
            do {
                try mainContext.save()
            } catch {
                print(error)
            }
        }
    }
    
    func insertClock(timeZoneId: String){
        let request = WorldClockEntity.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(WorldClockEntity.timeZoneId), timeZoneId)
        
        do {
            let cnt = try mainContext.count(for: request)
            if cnt > 0 { return }
        } catch {
            print(error)
        }
        
        let order = worldClockFetchedResults.sections?.first?.numberOfObjects ?? 0
        
        let newClock = WorldClockEntity(context: mainContext)
        newClock.timeZoneId = timeZoneId
        newClock.order = Int16(order)
        
        save()
    }
    
    func update(worldClock: WorldClockEntity, order: Int) {
        worldClock.order = Int16(order)
        save()
    }
    
    func delete(object: NSManagedObject) {
        mainContext.delete(object)
        save()
    }
    
}
