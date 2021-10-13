//
//  SceneCoordinatorType.swift
//  something3
//
//  Created by DONGHYUN KIM on 2021/10/13.
//  Copyright © 2021 John Kim. All rights reserved.
//

import Foundation
import RxSwift

protocol SceneCoordinatorType {
    @discardableResult
    func transition(to scene: Scene, using style: TransitionStyle, animated:Bool) -> Completable
    
    @discardableResult
    func close(animated: Bool) -> Completable
}
