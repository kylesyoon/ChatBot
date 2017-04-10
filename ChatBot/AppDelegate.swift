//
//  AppDelegate.swift
//  ChatBot
//
//  Created by Yoon, Kyle on 3/2/17.
//  Copyright © 2017 Kyle Yoon. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.vok_primary], for: .normal)
        UINavigationBar.appearance().tintColor = UIColor.vok_primary
        UIActivityIndicatorView.appearance().tintColor  = UIColor.vok_primary
        UIButton.appearance().tintColor = UIColor.vok_primary
        return true
    }
    
}

