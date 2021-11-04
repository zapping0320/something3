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
    
    public var selectedNote:R_Note?
    private var selectedNoteId:Int {
        if self.selectedNote == nil {
            return -1
        }
        
        return self.selectedNote!.id
    }
    let dateformatter = DateFormatter()
    
    init() {
        dateformatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
    }
    
   
    
    public func getUpdatedDateString() -> String {
        if self.selectedNote == nil {
            return ""
        }
        return NSLocalizedString("Last Modified" , comment: "") + ":" + dateformatter.string(from: selectedNote!.updated_at)
    }
    
    public func getAllNotes() {
        
        
    }
    
    public func getNotebooks() -> [R_NoteBook] {
        return notebookMgr.getNotebooks()
    }
    
    public func copyNote(title:String,content:String, relatedNotebookId:Int, isFavorite:Bool, alarmDate:Date?) {
        noteMgr.copyNote(title: title, content: content, relatedNotebookId: relatedNotebookId, isFavorite: isFavorite, alarmDate: alarmDate)
    }
    
    public func restoreNotebookInfo() {
        if selectedNoteId == -1 {
            return
        }
        noteMgr.restoreNotebookInfo(noteId: self.selectedNoteId)
    }
    
    public func setNoteInitialized() {
        if selectedNoteId == -1 {
            return
        }
        noteMgr.setNoteInitialized(noteId: self.selectedNoteId)
    }
    
    public func deleteNote() {
        if selectedNoteId == -1 {
            return
        }
        noteMgr.deleteNote(noteId: self.selectedNoteId)
    }
    
    public func updateNote(updatedNote:R_Note) {
        if selectedNoteId == -1 {
            return
        }
        updatedNote.id = selectedNoteId
        notebookMgr.updateNotebook(id: updatedNote.relatedNotebookId)
        noteMgr.updateNote(updatedNote: updatedNote)
        
        self.selectedNote = noteMgr.getNote(noteId: selectedNoteId)
    }
    
    public func addTags(tagString:String) {
        if selectedNoteId == -1 {
            return
        }
        _ = TagManager.addTagsToNote(noteid: selectedNoteId, tagString: tagString)
    }
    
}
