//
//  Scene.swift
//  something3
//
//  Created by DONGHYUN KIM on 2021/10/13.
//  Copyright © 2021 John Kim. All rights reserved.
//

import UIKit

enum Scene {
    case tabBar
    case list(NotebookViewModel)
//    case detail(MemoDetailViewModel)
//    case compose(MemoComposeViewModel)
}

extension Scene {
    func instantiate(from storyboard:String = "Main") -> UIViewController {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        
        switch self {
        case .tabBar:
            guard let tabBar = storyboard.instantiateViewController(withIdentifier: "tabBar") as? UITabBarController else {
                fatalError()
            }

            return tabBar
        case .list://(let viewModel):
            guard let nav = storyboard.instantiateViewController(withIdentifier: "noteBookView") as? NotebookViewController else {
                fatalError()
            }
            
//            guard var listVC = nav.viewControllers.first as? MemoListViewController else {
//                fatalError()
//            }
//
//            listVC.bind(viewModel: viewModel)
            return nav
        }
//        case .detail(let viewModel):
//            guard var detailVC = storyboard.instantiateViewController(withIdentifier: "DetailVC") as? MemoDetailViewController else {
//                fatalError()
//            }
//
//            detailVC.bind(viewModel: viewModel)
//            return detailVC
//        case .compose(let viewModel):
//            guard let nav = storyboard.instantiateViewController(withIdentifier: "ComposeNav") as? UINavigationController else {
//                fatalError()
//            }
//
//            guard var composeVC = nav.viewControllers.first as? MemoComposeViewController else {
//                fatalError()
//            }
//
//            composeVC.bind(viewModel: viewModel)
//            return nav
//        }
    }
}
