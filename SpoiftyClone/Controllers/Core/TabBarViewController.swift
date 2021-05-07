//
//  TabBarViewController.swift
//  SpoiftyClone
//
//  Created by Sandeep Kumar on 27/03/21.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        Utils.setUserIdForCurrentUser()
        
        let vc1 = HomeViewController()
        let vc2 = SearchViewController()
        let vc3 = LibraryViewController()
        
        let nav1 = UINavigationController(rootViewController: vc1).setUpNavForMainView(vc: vc1,title: "Browse", uiImageSystemName: "house")
        let nav2 = UINavigationController(rootViewController: vc2).setUpNavForMainView(vc: vc2,title: "Search", uiImageSystemName: "magnifyingglass")
        let nav3 = UINavigationController(rootViewController: vc3).setUpNavForMainView(vc: vc3,title: "Library", uiImageSystemName: "music.note.list")
        
        setViewControllers([nav1,nav2,nav3], animated: true)
    }
}
