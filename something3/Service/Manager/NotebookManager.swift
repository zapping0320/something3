//
//  NotebookManager.swift
//  something3
//
//  Created by DONGHYUN KIM on 2021/11/01.
//  Copyright © 2021 John Kim. All rights reserved.
//

import RealmSwift

class NotebookManager {
    
    static let shared = NotebookManager()
    
    init() {
        setRealmInfo()
        
    }
    
    private func setRealmInfo() {
        print(Realm.Configuration.defaultConfiguration.fileURL!)//only for simulator
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 8,
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 1) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
        })
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
    }
    
    public func loadNotebooks(searchWord:String) -> [Int:[R_NoteBook]] {
        var notebookArray:[Int:[R_NoteBook]] = [Int:[R_NoteBook]]()
        
        var notebookarray_recent = [R_NoteBook]()
        var notebookarray_all = [R_NoteBook]()
        
        let realm = try! Realm()
        if(searchWord.isEmpty == true)
        {
            let recentResults = realm.objects(R_NoteBook.self).sorted(byKeyPath: "updated_at", ascending: false)
            let recentCount = recentResults.count > 5 ? 4 : recentResults.count
            for i in 0..<recentCount {
                let item = recentResults[i]
                notebookarray_recent.append(item)
            }
            
            let allResults = realm.objects(R_NoteBook.self).sorted(byKeyPath: "name", ascending: true)
            for i in 0..<allResults.count {
                let item = allResults[i]
                notebookarray_all.append(item)
            }
            
            let trashCan = R_NoteBook()
            trashCan.name = "Trash"
            trashCan.id = -1
            notebookarray_all.append(trashCan)
        }
        else
        {
            let predicateSearch = NSPredicate(format: "name contains %@", searchWord)
            let results = realm.objects(R_NoteBook.self).filter(predicateSearch).sorted(byKeyPath: "updated_at", ascending: false)
            notebookarray_all = Array(results)
        }
        
        notebookArray[0] = notebookarray_recent
        notebookArray[1] = notebookarray_all
        
        return notebookArray
    }
    
    
}
