//
//  NotebookViewModel.swift
//  something3
//
//  Created by DONGHYUN KIM on 2021/10/13.
//  Copyright © 2021 John Kim. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Action
import RxDataSources

typealias NotebookSectionModel = AnimatableSectionModel<Int, R_NoteBook>

class NotebookViewModel : CommonViewModel {
    let dataSource:RxTableViewSectionedAnimatedDataSource<NotebookSectionModel> = {
        let ds = RxTableViewSectionedAnimatedDataSource<NotebookSectionModel>(configureCell: {
            (dataSource, tableView, indexPath, notebook) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: "notebookCell", for: indexPath)
            cell.textLabel?.text = notebook.name
            return cell
        })
        
        ds.canEditRowAtIndexPath = { _, _ in return true }
        
        return ds
    }()
    
//    var notebookList: Observable<[NoteBookSectionModel]> {
//        return storage.memoList()
//    }
}
