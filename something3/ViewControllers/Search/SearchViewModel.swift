//
//  SearchViewModel.swift
//  something3
//
//  Created by DONGHYUN KIM on 2021/11/05.
//  Copyright © 2021 John Kim. All rights reserved.
//

import Foundation

class SearchViewModel {
    private let noteMgr = NoteManager.shared
    
    public var searchText:String = ""
    private var searchedNotes:[R_Note] = [R_Note]()
    private var keywordList:[String] = [String]()
    
    init() {
        self.keywordList = SearchKeywordHelper.getKeywordList()
    }
    
    public func getItemCount() -> Int {
        if searchText.isEmpty == true {
            return keywordList.count
        }
        
        return searchedNotes.count
    }
    
    public func getKeywords() -> [String] {
        return self.keywordList
    }
    
    public func getNotes() -> [R_Note] {
        return self.searchedNotes
    }
    
    public func loadNotes(searchKeyword:String) {
        self.searchedNotes = noteMgr.loadNotes(searchKeyword: searchKeyword)
    }
    
    public func setNoteUnfavorite(note:R_Note) {
        let updatedNote = R_Note()
        updatedNote.copyFrom(source: note)
        updatedNote.isfavorite = false
        noteMgr.updateNote(updatedNote: updatedNote)
    }
}
