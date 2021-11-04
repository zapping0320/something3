//
//  NoteViewModel.swift
//  something3
//
//  Created by DONGHYUN KIM on 2021/11/01.
//  Copyright © 2021 John Kim. All rights reserved.
//

import Foundation

class NoteViewModel {
    private let notebookMgr = NotebookManager.shared
    private let noteMgr = NoteManager.shared
    
    public func getAllNotes() {
        
        
    }
    
    public func getNotebooks() -> [R_NoteBook] {
        return notebookMgr.getNotebooks()
    }
}
