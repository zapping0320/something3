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
    
    static let tagPlaceHolderString = NSLocalizedString("add Tag like #Tag", comment: "")
    
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
    
    static func storeTagInfo(noteid:Int = -1, tag:String) -> Bool {
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
        
        if(noteid < 1)
        {
            return true
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
    
    static func makeTagString(noteid:Int) -> String {
        if noteid < 1 {
            return ""
        }
        
        var tagString = ""
        let realm = try! Realm()
        let predicate = NSPredicate(format: "noteId = %@ ", NSNumber(value: noteid))
        for tagInfo in realm.objects(R_NoteTagRelations.self).filter(predicate) {
            if tagInfo.tagId < 1 {
                continue
            }
            let tagPredicate = NSPredicate(format: "id = %@ ", NSNumber(value: tagInfo.tagId))
            for tag in realm.objects(R_Tag.self).filter(tagPredicate){
                tagString += "#"
                tagString += tag.content
            }
        }
        
        return tagString
    }
    
    static func removeTagNTagInfo(tagId:Int)  {
        if tagId < 1 {
            return
        }
        
        let realm = try! Realm()
        try! realm.write {
            let predicate = NSPredicate(format: "tagId = %@ ", NSNumber(value: tagId))
            for tagInfo in realm.objects(R_NoteTagRelations.self).filter(predicate){
                realm.delete(tagInfo)
            }
            
            let tagPredicate = NSPredicate(format: "id = %@ ", NSNumber(value: tagId))
            for tag in realm.objects(R_Tag.self).filter(tagPredicate){
                realm.delete(tag)
            }
        }
        
    }
    
}
