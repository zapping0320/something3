//
//  FavoriteViewModel.swift
//  something3
//
//  Created by DONGHYUN KIM on 2021/11/05.
//  Copyright © 2021 John Kim. All rights reserved.
//

import Foundation

class FavoriteViewModel {
    private let noteMgr = NoteManager.shared
    
    
    public func loadNotes(searchWord:String) -> [Int:[R_Note]] {
        return noteMgr.loadFavoriteNotes(searchWord: searchWord)
    }
    
    public func setNoteUnfavorite(note:R_Note) {
        let updatedNote = R_Note()
        updatedNote.copyFrom(source: note)
        updatedNote.isfavorite = false
        noteMgr.updateNote(updatedNote: updatedNote)
    }
}
