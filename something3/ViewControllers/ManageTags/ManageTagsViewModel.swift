//
//  ManagetTagsViewModel.swift
//  something3
//
//  Created by DONGHYUN KIM on 2021/11/08.
//  Copyright © 2021 John Kim. All rights reserved.
//

import Foundation

class ManageTagsViewModel {
    private let tagMgr = TagManager.shared
    
    private var tagArray = [TagSectionInfos]()
    
    public func getTagArray() -> [TagSectionInfos] {
        return tagArray
    }
    
    public func loadTags(searchKeyword:String) {
        
        let allResults = tagMgr.loadTags(searchKeyword: searchKeyword)
        
        var lastTagHeader = ""
        var thisTagHeader = ""
        var tagList:[TagUI] = [TagUI]()
        for i in 0..<allResults.count {
            let item = allResults[i]
            
            let tagFirst = item.content[item.content.startIndex]
            thisTagHeader = String(tagFirst)
            
//            let tagPredicate = NSPredicate(format: "tagId = %@ ", NSNumber(value: item.id))
//            let taggedNotes = realm.objects(R_NoteTagRelations.self).filter(tagPredicate)
            let noteCount = NoteTagRelationsManager.shared.getTagNoteCount(tagId: item.id)
            let tatUI = TagUI(tag: item, count: noteCount)
            
            if(lastTagHeader == "" || lastTagHeader != thisTagHeader)
            {
                if(tagList.count > 0)
                {
                    tagArray.append(TagSectionInfos(title: lastTagHeader, tagList: tagList))
                }
                
                lastTagHeader = thisTagHeader
                tagList = [TagUI]()
                tagList.append(tatUI)
            }
            else {
                tagList.append(tatUI)
            }
        }
        
        if(lastTagHeader != "" && tagList.count > 0)
        {
            tagArray.append(TagSectionInfos(title: lastTagHeader, tagList: tagList))
        }
    }
}
