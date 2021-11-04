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
    
    public var selectedNote:R_Note = R_Note()
    
    let dateformatter = DateFormatter()
    
    init() {
        dateformatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
    }
    
    public func getUpdatedDateString() -> String {
        return NSLocalizedString("Last Modified" , comment: "") + ":" + dateformatter.string(from: selectedNote.updated_at)
    }
    
    public func getAllNotes() {
        
        
    }
    
    public func getNotebooks() -> [R_NoteBook] {
        return notebookMgr.getNotebooks()
    }
    
    public func copyNote(title:String,content:String, relatedNotebookId:Int, isFavorite:Bool, alarmDate:Date?) {
        noteMgr.copyNote(title: title, content: content, relatedNotebookId: relatedNotebookId, isFavorite: isFavorite, alarmDate: alarmDate)
    }
}
