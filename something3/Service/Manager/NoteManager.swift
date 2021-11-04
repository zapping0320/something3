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
    
    public func setNotesInitialized(notebookId:Int) {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "relatedNotebookId = %@",  NSNumber(value: notebookId))
        try! realm.write {
            for note in realm.objects(R_Note.self).filter(predicate){
                note.relatedNotebookId = -1
                note.oldNotebookId = notebookId
            }
        }
    }
    
    public func setNoteInitialized(noteId:Int) {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "id = %@",  NSNumber(value: noteId))
        guard let originalNote = realm.objects(R_Note.self).filter(predicate).first else { return }
        try! realm.write {
            originalNote.oldNotebookId = originalNote.relatedNotebookId
            originalNote.relatedNotebookId = -1
            
        }
    }
    
    public func restoreNotebookInfo(noteId:Int) {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "id = %@",  NSNumber(value: noteId))
        guard let originalNote = realm.objects(R_Note.self).filter(predicate).first else { return }
        try! realm.write {
            originalNote.relatedNotebookId = originalNote.oldNotebookId
            originalNote.oldNotebookId = -1
            
        }
    }
    
    public func loadNotes(notebookId:Int, searchWord:String, isIncludeAlarm:Bool, isSortByName:Bool) -> [R_Note] {
        
        var selectedNotebookContents = [R_Note]()
        
        let realm = try! Realm()
        
        let predicateNotebookId = NSPredicate(format: "relatedNotebookId = %@", NSNumber(value: notebookId))
        var predicateList = [NSPredicate]()
        predicateList.append(predicateNotebookId)

        if(searchWord.isEmpty == false)
        {
             let predicateSearch = NSPredicate(format: "title contains %@ OR content contains %@", searchWord, searchWord)

             predicateList.append(predicateSearch)
        }
        
        if(isIncludeAlarm == true)
        {
            let predicateAlarm = NSPredicate(format: "alarmDate != nil ")
            predicateList.append(predicateAlarm)
        }
        
        let andPredicate:NSCompoundPredicate = NSCompoundPredicate(type: .and, subpredicates: predicateList)
        
        var sortField : String = ""
        var sortAscending: Bool = false
        if(isSortByName == true)
        {
            sortField = "title"
            sortAscending = true
        }
        else
        {
            sortField = "updated_at"
            sortAscending = false
        }
        let results = realm.objects(R_Note.self).filter(andPredicate).sorted(byKeyPath: sortField, ascending: sortAscending)
        
        let predicateNotebook = NSPredicate(format: "id = %@", NSNumber(value:notebookId))
        let notebookResults = realm.objects(R_NoteBook.self).filter(predicateNotebook)
        if(notebookResults.count == 0){
            //trash
            selectedNotebookContents = Array(results)
        }
        else{
            let currentNotebook = notebookResults[0]
            if(currentNotebook.searchTags != "")
            {
                let predicateTagString = String.localizedStringWithFormat("tagId in { %@ } ", currentNotebook.searchTags)
                let predicateTag = NSPredicate(format: predicateTagString)
                let relationResults = realm.objects(R_NoteTagRelations.self).filter(predicateTag)
                var noteidList = [Int]()
                for i in 0..<relationResults.count {
                    let relationItem = relationResults[i]
                    if (noteidList.contains(relationItem.noteId) == false){
                        noteidList.append(relationItem.noteId)
                    }
                }
                
                if(noteidList.count == 0)
                {
                    selectedNotebookContents = Array(results)
                }
                else
                {
                    for i in 0..<results.count {
                        let noteItem = results[i]
                        if( noteidList.contains(noteItem.id)){
                            selectedNotebookContents.append(noteItem)
                        }
                    }
                }
                
            }
            else
            {
                selectedNotebookContents = Array(results)
            }
        }
        
        return selectedNotebookContents
    }
    
    public func deleteTrashNotes() {
        let realm = try! Realm()
        try! realm.write {
            let predicate = NSPredicate(format: "relatedNotebookId = -1")
            for note in realm.objects(R_Note.self).filter(predicate){
                realm.delete(note)
            }
        }
    }
    
    public func deleteNote(noteId:Int) {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "id = %@",  NSNumber(value: noteId))
        guard let originalNote = realm.objects(R_Note.self).filter(predicate).first else { return }
        
        try! realm.write {
            realm.delete(originalNote)
        }
    }
    
    public func copyNote(title:String,content:String, relatedNotebookId:Int, isFavorite:Bool, alarmDate:Date?) {
        let realm = try! Realm()
        let newnote = R_Note()
        newnote.title = title
        newnote.content = content
        newnote.relatedNotebookId = relatedNotebookId
        newnote.isfavorite = isFavorite
        newnote.id = (realm.objects(R_Note.self).max(ofProperty: "id") as Int? ?? 0) + 1
        newnote.alarmDate = alarmDate

        try! realm.write {
            realm.add(newnote)
        }
    }
    
    public func updateNote(updatedNote:R_Note) {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "id = %@",  NSNumber(value: updatedNote.id))
        guard let originalNote = realm.objects(R_Note.self).filter(predicate).first else { return }
        
        try! realm.write {
            
            originalNote.title = updatedNote.title
            originalNote.content = updatedNote.content
            originalNote.relatedNotebookId = updatedNote.relatedNotebookId
            originalNote.isfavorite = updatedNote.isfavorite
            originalNote.alarmDate = updatedNote.alarmDate
            originalNote.updated_at = Date()
        }
    }
    
    public func getNote(noteId:Int) -> R_Note?{
        let realm = try! Realm()
        let predicate = NSPredicate(format: "id = %@",  NSNumber(value: noteId))
        guard let originalNote = realm.objects(R_Note.self).filter(predicate).first else { return nil }
        
        return originalNote
    }
    
}
