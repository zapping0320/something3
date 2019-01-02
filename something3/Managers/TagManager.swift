//
//  TagManager.swift
//  something3
//
//  Created by 김동현 on 02/01/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import Foundation
import RealmSwift

class TagManager {
    static func addTagsToNote(noteid:Int, tagString:String?) -> Bool {
        clearTagInfos(noteid: noteid)
        if tagString == "" {
            return false
        }
        
        var tags:[String] = []
        if tagString!.contains("#") {
            tags = tagString!.components(separatedBy: "#")
        }
        
        if tags.count > 1 {
            for tag in tags {
                _ = storeTagInfo(noteid: noteid, tag: tag)
            }
            
            return true
        }
        else {
            return storeTagInfo(noteid: noteid, tag: tagString!)
        }
    }
    
    static func storeTagInfo(noteid:Int, tag:String) -> Bool {
        let trimmedTag = tag.trimmingCharacters(in: .whitespaces)
        if trimmedTag == ""  {
            return true
        }
        
        let realm = try! Realm()
        let predicateSearch = NSPredicate(format: "content = %@ ", trimmedTag)
        let results = realm.objects(R_Tag.self).filter(predicateSearch).sorted(byKeyPath: "updated_at", ascending: false)
        
        var tagId:Int = -1
        if results.count > 0 {
            let tagItem = results[0]
            tagId = tagItem.id
        }else {
            tagId = (realm.objects(R_Tag.self).max(ofProperty: "id") as Int? ?? 0) + 1
            
            let newTag = R_Tag()
            newTag.content = trimmedTag
            newTag.id = tagId
            
            try! realm.write {
                realm.add(newTag)
            }
        }
        
        let newRelationId = (realm.objects(R_NoteTagRelations.self).max(ofProperty: "id") as Int? ?? 0) + 1
        let newRelation = R_NoteTagRelations()
        newRelation.id = newRelationId
        newRelation.noteId = noteid
        newRelation.tagId = tagId
        
        try! realm.write {
            realm.add(newRelation)
        }
        
        return true
        
    }
    
    static func clearTagInfos(noteid:Int) {
        if noteid < 1 {
            return
        }
        
        let realm = try! Realm()
        try! realm.write {
            let predicate = NSPredicate(format: "noteId = %@ ", NSNumber(value: noteid))
            for tagInfo in realm.objects(R_NoteTagRelations.self).filter(predicate){
                realm.delete(tagInfo)
            }
        }
       
    }
    
}
