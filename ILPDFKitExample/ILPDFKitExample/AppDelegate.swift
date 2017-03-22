//
//  AppDelegate.swift
//  ILPDFKitExample
//
//  Created by Derek Blair on 2016-07-18.
//  Copyright © 2016 Derek Blair. All rights reserved.
//

import UIKit
import ILPDFKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var pdfVC : ILPDFViewController? = nil


   func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool { 
        // Override point for customization after application launch.
        pdfVC = (self.window?.rootViewController as? UINavigationController)?.viewControllers.first as? ILPDFViewController
        let document = ILPDFDocument(resource:"testA")
        pdfVC?.document = document
        let printButton = UIBarButtonItem(title: "Save Static PDF", style: .plain, target: self, action: #selector(print))
        pdfVC?.navigationItem.setRightBarButton(printButton, animated: false)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


    //MARK: Print Responder

    @objc func print(sender:AnyObject?) {
        let data = pdfVC?.document?.savedStaticPDFData()

        let savedVCDocument = ILPDFDocument(data: data!)

        let alert = UIAlertController(title: "Will Save PDF", message: "The PDF file displayed next is a static version of the previous file, but with the form values added. The starting PDF has not been modified and this static pdf no longer contains forms.", preferredStyle: .alert)

        let action = UIAlertAction(title: "Show Saved Static PDF", style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
            self.pdfVC?.document = savedVCDocument
            self.pdfVC?.navigationItem.setRightBarButton(nil, animated: false)
        }

        alert.addAction(action)
        window?.rootViewController?.present(alert, animated: true, completion: nil)
    }


}

