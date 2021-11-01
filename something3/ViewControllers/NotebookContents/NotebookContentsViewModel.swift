//
//  NotebookContentsViewModel.swift
//  something3
//
//  Created by DONGHYUN KIM on 2021/11/01.
//  Copyright © 2021 John Kim. All rights reserved.
//

import Foundation

class NotebookContentsViewModel {
    
    private let noteMgr = NoteManager.shared
    
    
    public var isSortTypeByName:Bool = true
    public var isAlarmIncluded:Bool = false
    
    public func getNotes(notebookId:Int, searchWord:String) -> [R_Note] {
        
    
        return noteMgr.loadNotes(notebookId: notebookId, searchWord: searchWord, isIncludeAlarm: self.isAlarmIncluded, isSortByName: self.isSortTypeByName)
    }
    
    public func deleteTrashNotes() {
        noteMgr.deleteTrashNotes()
    }
    
    public func setNoteInitialized(noteId:Int) {
        noteMgr.setNoteInitialized(noteId: noteId)
    }
}
