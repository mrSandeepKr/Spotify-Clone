//
//  AppDelegate.swift
//  SpoiftyClone
//
//  Created by Sandeep Kumar on 26/03/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window : UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        if(!AuthManager.shared.isSignedIn){
            let nav = UINavigationController(rootViewController: WelcomeViewController())
            nav.navigationBar.prefersLargeTitles = true
            nav.viewControllers.first?.navigationItem.largeTitleDisplayMode = .always
            window.rootViewController = nav
        }
        else{
            DispatchQueue.background(background: {
                AuthManager.shared.refreshIfNeeded(completion: { success in
                    if success {
                        print("AppDelegate: Valid Token Present")
                    }
                })
            })
            Utils.setUserIdForCurrentUser()
            window.rootViewController = TabBarViewController()
        }

        window.makeKeyAndVisible()
        self.window = window
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

