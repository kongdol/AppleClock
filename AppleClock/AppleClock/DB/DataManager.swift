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
    let alarmFetchedResults: NSFetchedResultsController<AlarmEntity>
    
    private init() {
        let contatiner = NSPersistentContainer(name: "Clock")
        contatiner.loadPersistentStores { description, error in
            if let error {
                fatalError(error.localizedDescription)
            }
        }
        
        persistentContainer = contatiner //DB전체엔진
        mainContext = persistentContainer.viewContext //작업공간
        mainContext.undoManager = UndoManager()
        
        let worldClockRequest = WorldClockEntity.fetchRequest()
        
        let sortByOrderAsc = NSSortDescriptor(keyPath: \WorldClockEntity.order, ascending: true)
        worldClockRequest.sortDescriptors = [sortByOrderAsc]
        
        // 자동으로 리스트 관리해주는 컨트롤러
        worldClockFetchedResults = NSFetchedResultsController(fetchRequest: worldClockRequest, managedObjectContext: mainContext, sectionNameKeyPath: nil, cacheName: nil)
        
        let alarmRequest = AlarmEntity.fetchRequest() // 코어데이터에서 데이터 불러옴
        
        let sortByHour = NSSortDescriptor(keyPath: \AlarmEntity.hour, ascending: true)
        let sortByMinute = NSSortDescriptor(keyPath: \AlarmEntity.minute, ascending: true)
        alarmRequest.sortDescriptors = [sortByHour, sortByMinute] //시간으로 정렬, 똑같으면 분으로 정렬
        
        alarmFetchedResults = NSFetchedResultsController(fetchRequest: alarmRequest, managedObjectContext: mainContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try worldClockFetchedResults.performFetch()
            try alarmFetchedResults.performFetch()
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
    
    func rollback() {
        mainContext.rollback()
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
    
    // 패치리퀘스트 만들고 모든 엔티티 가져옴
    func refreshActivationState(pendingIds: [String]) {
        let request = AlarmEntity.fetchRequest()
        
        do {
            let list = try mainContext.fetch(request)
            
            for alarm in list {
                if let id = alarm.identifier {
                    alarm.activated = pendingIds.contains(where: {$0.hasPrefix(id)})
                }
            }
            
            save()
        } catch {
            print(error)
        }
    }
}
