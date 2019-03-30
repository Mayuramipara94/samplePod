//
//  ApplicationData.swift
//  MeditabSwiftArchitecture
//
//  Created by Rushi on 23/05/17.
//  Copyright © 2017 Meditab. All rights reserved.
//

import UIKit

/** This singleton class is used to store application level data. */
class ApplicationData: NSObject {

    // A Singleton instance
    static let sharedInstance = ApplicationData()
    
    // Checks if user is logged in
    static var isUserLoggedIn: Bool {
        get {
            return Defaults.bool(forKey: AppConstants.UserDefaultKey.isUserLoggedIn)
        }
    }
    
    // returns logged in user's information
    static var user: UserInfoModel {
        get {
            return Defaults[.userInfo] ?? UserInfoModel()
        }
    }
    
    //return User Primary Email
    static var primaryEmail : EmailModel? {
        
        get {
            
            if let emails = ApplicationData.user.emails,emails.count > 0 {
                
                let arrData = Mapper<EmailModel>().mapArray(JSONArray: emails)
                let filter = arrData.filter { (model) -> Bool in
                    return model.isPrimary
                }
                
                return filter.first
            }
            
            return nil
        }
    }
    
    //return User Primary Email
    static var primaryMobile : MobileModel? {
        
        get {
            
            if let mobiles = ApplicationData.user.mobiles,mobiles.count > 0 {
                
                let arrData = Mapper<MobileModel>().mapArray(JSONArray: mobiles)
                let filter = arrData.filter { (model) -> Bool in
                    return model.isPrimary
                }
                
                return filter.first
            }
            
            return nil
        }
    }
    
    // returns Token
    static var accessToken: String? {
        get {
            return Defaults[.accessToken]
        }
    }
    
    // returns Current Time Zone
    static var timeZone: String {
        get {
            let timeZone = NSTimeZone.local
            return timeZone.localizedName(for: .standard, locale: .current) ?? ""
        }
    }
    
    //retun device Id
    static var deviceId: String {
        get {
            return UIDevice.current.identifierForVendor!.uuidString
        }
    }
    
    //retun device Name
    static var deviceName: String {
        get {
            return UIDevice.current.localizedModel
        }
    }
    
    //retun device version
    static var deviceVersion: String {
        get {
            return UIDevice.current.systemVersion
        }
    }
    
    static func buildVersion() -> String {
        let dictionary = Bundle.main.infoDictionary!
        //let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return "V \(build)"
    }
    
    static var ipAddress : String {
        
        get {
            
            var address : String?
            
            // Get list of all interfaces on the local machine:
            var ifaddr : UnsafeMutablePointer<ifaddrs>?
            guard getifaddrs(&ifaddr) == 0 else { return "" }
            guard let firstAddr = ifaddr else { return "" }
            
            // For each interface ...
            for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
                let interface = ifptr.pointee
                
                // Check for IPv4 or IPv6 interface:
                let addrFamily = interface.ifa_addr.pointee.sa_family
                
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    
                    // Check interface name:
                    let name = String(cString: interface.ifa_name)
                    
                    if  name == "en0" || name == "pdp_ip0"  {
                        
                        // Convert interface address to a human readable string:
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                    &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                    }
                }
            }
            freeifaddrs(ifaddr)
            return address ?? ""
        }
    }
    
    
    /// Default headers to be passed in CenterAPI requests
    var authorizationHeaders: HTTPHeaders {
        
        get{
            var headers: HTTPHeaders = [:]
            if ApplicationData.isUserLoggedIn{
                headers = [NetworkClient.Constants.HeaderKey.Authorization:"jwt \(ApplicationData.accessToken!)","destination":"user"]
            }
            return headers
        }
    }
    
    //MARK: Privates
    //Move To Home
    func moveToHome() {
        
        SyncManager.sharedInstance.upsertPlayerId()
//        SyncManager.sharedInstance.syncDataBase()
        SyncManager.sharedInstance.syncService(success: nil)
        NotificationManager.sharedInstance.connect(success: nil)
        
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to: #selector(setter: UIView.backgroundColor)){
            statusBar.backgroundColor = ColorConstants.ThemeColor
        }
        
        let vc = TabBarController(nibName: "TabBarController", bundle: nil)
        SlideNavigationController.sharedInstance().popAllAndSwitch(to: vc, withCompletion: nil)
   
    }
    
    // Save user details
    func saveLoginData(data: [String : Any]) {
        
        Defaults[.accessToken] = (data["token"] as! [String : Any])["jwt"] as? String
        Defaults[.isUserLoggedIn] = true
        
        if let userObj = data["user"] as? [String:Any]{
            
            self.refreshUserData(objUser: userObj)
        }
    }
    
    func refreshUserData(objUser:[String:Any]){
        
        let userInfo = Mapper<UserInfoModel>().map(JSON: objUser)
        Defaults[.userInfo] = userInfo
        
        if let listAddress = objUser["addresses"] as? [[String : Any]] {
            
            SyncManager.sharedInstance.insertAddress(list: listAddress)
        }
        
        if let listCard = objUser["cards"] as? [[String : Any]] {
            
            SyncManager.sharedInstance.deleteAllCards()
            SyncManager.sharedInstance.insertCard(list:  listCard)
        }
        
    }
    
    //checkForPendingRating
    func checkForPendingRatingReviewOfJobs()
    {
        let jobs = SyncManager.sharedInstance.fetchJobsWithoutRatingReview()
        
        if jobs.count > 0{
            
            let mmJob = jobs.first
            
            let model = JobsWithoutRatingReviewModel()
            model.id = mmJob?.id
            model.totalCharge = mmJob?.totalCharge ?? 0.0
            model.reqNumber = mmJob?.reqNumber
            
            //Cleaner Model
            let cleaner = CleanerModel()
            cleaner.id = mmJob?.cleanerId?.id
            cleaner.name = mmJob?.cleanerId?.name
            cleaner.image = mmJob?.cleanerId?.image
            model.cleanerId = cleaner
            
            let vc = RatingVC(nibName: "RatingVC", bundle: nil)
            vc.model = model
            SlideNavigationController.sharedInstance()?.present(vc, animated: true, completion: nil)
        }
    }
    
    //Check Email Verify Or not
    func isEmailVerify() -> Bool {
        
        if let emails = ApplicationData.user.emails,emails.count > 0 {
            
            let arrData = Mapper<EmailModel>().mapArray(JSONArray: emails)
            let filter = arrData.filter { (model) -> Bool in
                return model.isPrimary && model.isVerified
            }
            
            if filter.count > 0{ return true }
        }
        
        return false
    }

    func isMobileVerify() -> Bool {
        
        if let mobiles = ApplicationData.user.mobiles,mobiles.count > 0 {
            
            let arrData = Mapper<MobileModel>().mapArray(JSONArray: mobiles)
            let filter = arrData.filter { (model) -> Bool in
                return model.isPrimary && model.isVerified
            }
            
            if filter.count > 0{ return true }
        }
        
        return false
    }
    
    // Logout User
     func logoutUser(){
        
        var header = HTTPHeaders()
        header = authorizationHeaders
        header["playerid"] = Defaults[.playerID]
        
        NetworkClient.sharedInstance.showIndicator("", stopAfter: 0.0)
        NetworkClient.sharedInstance.request(AppConstants.serverURL, command: AppConstants.URL.Logout, method: .post, parameters: nil, headers: header, success: { (response, message) in
            
            self.clearUserData()
            
        }) { (failureMessage, failureCode) in
            
            Utilities.showAlertView(message: failureMessage)
        }
    }
    
    func clearUserData(){
        
        NotificationManager.sharedInstance.disconnect()
        SyncManager.sharedInstance.clearDataBase()
        
        let isIntroDone = Defaults[.isIntroDone]
        let playerID    = Defaults[.playerID]
        let contactEmail    = Defaults[.supportEmail]
        
        // user default clear
        UserDefaults.removeAllData()
        
        Defaults[.isIntroDone]  = isIntroDone
        Defaults[.playerID]     = playerID
        Defaults[.supportEmail] = contactEmail
        
        // redirect to Login Screen
        let vc = LoginVC(nibName: "LoginVC", bundle: nil)
        SlideNavigationController.sharedInstance().popAllAndSwitch(to: vc, withCompletion: nil)
    }
}
