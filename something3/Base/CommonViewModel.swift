//
//  CommonViewModel.swift
//  something3
//
//  Created by DONGHYUN KIM on 2021/10/13.
//  Copyright © 2021 John Kim. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class CommonViewModel : NSObject {
    let title: Driver<String>
    let sceneCoordinator: SceneCoordinatorType
    //let storage: MemoStorageType
    
    init(title:String, sceneCoordinator: SceneCoordinatorType){ //, storage: MemoStorageType) {
    
        self.title = Observable.just(title).asDriver(onErrorJustReturn: "")
        self.sceneCoordinator = sceneCoordinator
      //  self.storage = storage
    }
}
