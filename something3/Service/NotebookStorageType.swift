//
//  MemoStorageType.swift
//  something3
//
//  Created by DONGHYUN KIM on 2021/10/21.
//  Copyright © 2021 John Kim. All rights reserved.
//

import Foundation
import RxSwift

protocol NotebookStorageType {
    @discardableResult
    func createNotebook(content:String) -> Observable<R_NoteBook>
    
    @discardableResult
    func notebookList() -> Observable<[NotebookSectionModel]>
    
    @discardableResult
    func update(notebook:R_NoteBook, content:String) -> Observable<R_NoteBook>
    
    @discardableResult
    func delete(notebook:R_NoteBook) -> Observable<R_NoteBook>
}
