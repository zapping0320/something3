//
//  AddNoteViewModel.swift
//  something3
//
//  Created by DONGHYUN KIM on 2021/11/04.
//  Copyright © 2021 John Kim. All rights reserved.
//

import Foundation

class AddNoteViewModel {
    private let notebookMgr = NotebookManager.shared
    private let noteMgr = NoteManager.shared
    
    public func getNotebooks() -> [R_NoteBook] {
        return notebookMgr.getNotebooks()
    }
    
    public func addNote(newNote:R_Note) -> Int {
        notebookMgr.updateNotebook(id: newNote.relatedNotebookId)
        return noteMgr.addNote(newNote: newNote)
    }
    
    public func addTags(noteId:Int, tagString:String) {
        
        _ = TagManager.addTagsToNote(noteid: noteId, tagString: tagString)
    }
}
