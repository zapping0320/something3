//
//  R_Note.swift
//  something3
//
//  Created by 김동현 on 2018. 9. 7..
//  Copyright © 2018년 John Kim. All rights reserved.
//

import RealmSwift

class R_Note: Object  {
    @objc dynamic var id = 0
    @objc dynamic var content = ""
    @objc dynamic var isfavorite = false
    @objc dynamic var title = ""
    @objc dynamic var relatedNotebookId = 0 //for trashcan : -1 /
    @objc dynamic var oldNotebookId = 0 //for trashcan
    @objc dynamic var updated_at = Date()
    @objc dynamic var created_at = Date()
    @objc dynamic var deleted_at:Date? = nil
    @objc dynamic var alarmDate:Date? = nil
    @objc dynamic var alarmIdentifier:String? = ""
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func copyFrom(source: R_Note) {
        self.id = source.id
        self.content = source.content
        self.isfavorite = source.isfavorite
        self.title = source.title
        self.relatedNotebookId = source.relatedNotebookId
        self.oldNotebookId = source.oldNotebookId
        self.updated_at = source.updated_at
        self.created_at = source.created_at
        self.deleted_at = source.deleted_at
        self.alarmDate = source.alarmDate
        self.alarmIdentifier = source.alarmIdentifier
        
    }
}
