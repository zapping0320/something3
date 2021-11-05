//
//  TagFilterViewModel.swift
//  something3
//
//  Created by DONGHYUN KIM on 2021/11/05.
//  Copyright © 2021 John Kim. All rights reserved.
//

import Foundation

class TagFilterViewModel {
    private let notebookMgr = NotebookManager.shared
    private let tagMgr = TagManager.shared
    
    private var tagArray:[Int:[R_Tag]] = [Int:[R_Tag]]()
    
    public func getItemCount(section:Int) -> Int {
        if section >= tagArray.count {
            return 0
        }
        
        guard let dataList = tagArray[section] as [R_Tag]? else { return 0 }
        
        return dataList.count
        
    }
    
    public func loadTags(selectedNoteBookId:Int, noteTagString:String, searchKeyword:String) -> [Int:[R_Tag]] {
        
        tagArray = tagMgr.loadTags(selectedNoteBookId: selectedNoteBookId, noteTagString: noteTagString, searchKeyword: searchKeyword)
        
        return tagArray
    }
    
    public func getNotebook(notebookId:Int) -> R_NoteBook? {
        return notebookMgr.getNotebook(notebookId: notebookId)
    }
}
