//
//  NoteManager.swift
//  something3
//
//  Created by DONGHYUN KIM on 2021/11/01.
//  Copyright © 2021 John Kim. All rights reserved.
//

import RealmSwift

class NoteManager {
    
    static let shared = NoteManager()
    
    public func getRelatedNoteCount(notebookId:Int) -> Int {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "relatedNotebookId = %@",  NSNumber(value: notebookId))
        let results = realm.objects(R_Note.self).filter(predicate)
        
        return results.count
    }
    
}
