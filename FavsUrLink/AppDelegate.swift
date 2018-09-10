//
//  AppDelegate.swift
//  FavsUrLink
//
//  Created by Mattia Cantalù on 10/03/16.
//  Copyright © 2016 Mattia Cantalù. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let apiKey = "<api key>"
    
    private var subscription: GNSSubscription?
    var publication: GNSPublication?
    var messageManager = GNSMessageManager()

    var email : String?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        messageManager = GNSMessageManager(APIKey: apiKey)
        email = NSUserDefaults.standardUserDefaults().objectForKey("email") as? String
        
        startShareContext()

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


    //MARK: - Nearby Methods
    func startShareContext() {
        if (self.email == nil || self.email == "") {
            return;
        }
        
        if (!GNSPermission.isGranted()) {
            GNSPermission.setGranted(true)
        }
//        
//        let content = NSData(data: (self.email!.dataUsingEncoding(NSUTF8StringEncoding))!)
//        let pubMessage: GNSMessage = GNSMessage(content: content)
//        publication = self.messageManager.publicationWithMessage(pubMessage)
        
        self.subscription = self.messageManager.subscriptionWithMessageFoundHandler({[unowned self] (message: GNSMessage!) -> Void in
            print("Received message: \(message)")
            }, messageLostHandler: {[unowned self](message: GNSMessage!) -> Void in
                print("Message lost: \(message.description)")
            })
    }

    func stopShareContext() {
        self.publication = nil
        self.subscription = nil
    }
    
}

