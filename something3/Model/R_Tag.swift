//
//  R_Tag.swift
//  something3
//
//  Created by 김동현 on 01/01/2019.
//  Copyright © 2019 John Kim. All rights reserved.
//

import RealmSwift

class R_Tag: Object  {
    @objc dynamic var id = 0
    @objc dynamic var content = ""
    @objc dynamic var updated_at = Date()
    @objc dynamic var created_at = Date()
    @objc dynamic var deleted_at:Date? = nil
    override static func primaryKey() -> String? {
        return "id"
    }
}

