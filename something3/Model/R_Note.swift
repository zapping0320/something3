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
    //dynamic var relatedNotebook: R_Notebook?
    @objc dynamic var updated_at = Date()
    @objc dynamic var created_at = Date()
    @objc dynamic var deleted_at:Date? = nil
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
