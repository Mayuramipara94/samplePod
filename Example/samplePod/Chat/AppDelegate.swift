//
//  AppDelegate.swift
//  SnapAcleaner
//
//  Created by Coruscate on 17/09/18.
//  Copyright © 2018 Coruscate. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDynamicLinks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate  ,OSPermissionObserver, OSSubscriptionObserver{

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        self.intialConfig()
        self.configurePushNotification(launchOptions: launchOptions)
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

        if url.absoluteString.contains("google") {

            //Dip Linking
            return application(app, open: url,
                               sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                               annotation: "")
        }

        let checkFb = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])

        return checkFb
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {

        let checkGoogle = GIDSignIn.sharedInstance().handle(url ,sourceApplication: sourceApplication,annotation: annotation)
        return checkGoogle
    }
    
    func onOSPermissionChanged(_ stateChanges: OSPermissionStateChanges!) {
        // Example of detecting answering the permission prompt
        if stateChanges.from.status == OSNotificationPermission.notDetermined {
            if stateChanges.to.status == OSNotificationPermission.authorized {
                print("Thanks for accepting notifications!")
            } else if stateChanges.to.status == OSNotificationPermission.denied {
                print("Notifications not accepted. You can turn them on later under your iOS settings.")
            }
        }
    }
    
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!) {
        if !stateChanges.from.subscribed && stateChanges.to.subscribed {
            print("Subscribed for OneSignal push notifications!")
        }
        
        if let playerId = stateChanges.to.userId,playerId.count > 0 {
            Defaults[.playerID] = playerId
            SyncManager.sharedInstance.upsertPlayerId()
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
        NotificationManager.sharedInstance.disconnect()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        NotificationManager.sharedInstance.connect(success: nil)
        
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
        NotificationManager.sharedInstance.disconnect()
    }
    
    //MARK: handle push notification
    func configurePushNotification( launchOptions : [UIApplication.LaunchOptionsKey: Any]?){
        
        let notificationReceivedBlock: OSHandleNotificationReceivedBlock = { notification in
            
            if let additionalData = notification?.payload.additionalData as? [String : Any]{
                
                self.updateRespectedVC(dict: additionalData)
            }
            
        }
        
        let notificationOpenedBlock: OSHandleNotificationActionBlock = { result in
            
            // This block gets called when the user reacts to a notification received
            let payload: OSNotificationPayload = result!.notification.payload
            
            if payload.additionalData != nil {
            
                if let additionalData = payload.additionalData as? [String : Any] {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                        NotificationManager.sharedInstance.handleNotification(model: NotificationModel(JSON: additionalData)!, isFromNotification: true)
                    })
                }
            }
        }
        
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: true,
                                     kOSSettingsKeyInAppLaunchURL: false]
        
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: AppConstants.AppIdOneSignal,
                                        handleNotificationReceived: notificationReceivedBlock,
                                        handleNotificationAction: notificationOpenedBlock,
                                        settings: onesignalInitSettings)
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification
        
        OneSignal.add(self as OSPermissionObserver)
        
        OneSignal.add(self as OSSubscriptionObserver)
        
    }
    
    func updateRespectedVC(dict : [String:Any]){
        
        if dict["isEmailVerification"] as? Bool ?? false == true{
            
            if let vc = UIViewController.current() as? AccountVC{
                
                SyncManager.sharedInstance.syncMaster {
                    vc.setData()
                }
                
            }else if let vc = UIViewController.current() as? AccountDetailVC{
                vc.initialConfig()
            }
            
        }
    }
    
    //MARK: Private Methods
    func intialConfig(){
        
        STPPaymentConfiguration.shared().publishableKey = AppConstants.StripeTestKey
        
        let BarButtonItemAppearance = UIBarButtonItem.appearance()

        BarButtonItemAppearance.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .normal)
        BarButtonItemAppearance.setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -200, vertical: 0), for:UIBarMetrics.default)
        
        GMSServices.provideAPIKey(AppConstants.googleApiKey)
        GMSPlacesClient.provideAPIKey(AppConstants.googleApiKey)
        GIDSignIn.sharedInstance().clientID = AppConstants.GoogleClientId
        
        IQKeyboardManager.shared().isEnabled = true
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
//        IQKeyboardManager.shared().
        
        //Change status bar color
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        
        if statusBar.responds(to: #selector(setter: UIView.backgroundColor)){
            statusBar.backgroundColor = ColorConstants.NavigationBarColor
        }
        
        let vc = SplashVC.init(nibName: "SplashVC", bundle: nil)
        let root = SlideNavigationController(rootViewController: vc)
        root.navigationBar.isHidden = false
        
        let leftMenu = LeftMenuVC.init(nibName: "LeftMenuVC", bundle: nil)
        SlideNavigationController.sharedInstance().leftMenu = leftMenu
        
        SlideNavigationController.sharedInstance().navigationBar.isTranslucent = false
        SlideNavigationController.sharedInstance().enableSwipeGesture = false
        SlideNavigationController.sharedInstance().menuRevealAnimationOption = .beginFromCurrentState
        SlideNavigationController.sharedInstance().navigationBar.backIndicatorImage = UIImage(named : "arrowLeft")
        SlideNavigationController.sharedInstance().navigationBar.backIndicatorTransitionMaskImage = UIImage(named : "arrowLeft")
        
        self.window?.rootViewController = root
        self.window?.makeKeyAndVisible()
        
    }
    
    //DipLinking
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {

        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, error) in

            guard error == nil else {
                print("Found an error! \(error?.localizedDescription ?? "")")
                return
            }

            if let dynamicLink = dynamiclink {
                self.handleDynamicLink(dynamicLink)
            }
        }

        return handled
    }
    
    func handleDynamicLink(_ dynamicLink: DynamicLink) {
        
        guard let url = dynamicLink.url else {
            return
        }
        
        let urlArray = url.absoluteString.components(separatedBy: "/")
        var giftCode = Defaults[.giftCode]
        giftCode.append(urlArray.last ?? "")
        Defaults[.giftCode] = giftCode
        SyncManager.sharedInstance.sendGiftCode()
    }
}

