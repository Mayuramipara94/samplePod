//
//  DownloadManager.swift
//  Bank2Grow
//
//  Created by CS-Mac-Mini on 15/12/17.
//  Copyright © 2017 Coruscate. All rights reserved.
//

import UIKit

class DownloadManager: NSObject,UIDocumentInteractionControllerDelegate {
    
    // A Singleton instance
    static let sharedInstance = DownloadManager()
    var uploadAlertView = UIAlertController()
    var progressUpload = UIProgressView()
    var request: Alamofire.Request?
    var docController:UIDocumentInteractionController?
    
    // Initialize
    private override init() {
        super.init()
   
        self.setupUploadAlert()
    }
    
    //MARK: Download File
    
    func downloadFileWithURL(fileUrl:String,saveFileWithName:String, showProgressView : Bool = true,success: @escaping (()-> ()),failure:@escaping (()-> ())){
        
        // check network reachability
        guard (NetworkClient.sharedInstance.networkReachability?.isReachable)! else {
            failure()
            return
        }
        
        //this will Create Directory if not exist
        do {
            let dataPath = Utilities.getDocumentsDirectory().appendingPathComponent(StringConstants.DownloadFolderName)
            try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription);
        }
        
        let url = URL(string: "\(AppConstants.serverURL)\(fileUrl)")
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = Utilities.getDocumentsDirectory().appendingPathComponent("\(StringConstants.DownloadFolderName)/\(saveFileWithName).\(fileUrl.fileExtension())")
            print(documentsURL)
            return (documentsURL, [.removePreviousFile])
        }
        
        if showProgressView == true{
            self.progressUpload.setProgress(0, animated: true)
            UIViewController.current().present(self.uploadAlertView, animated: true, completion: nil)
        }
        
        self.request = Alamofire.download(
            url!,
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: ApplicationData.sharedInstance.authorizationHeaders,to: destination).downloadProgress(closure: { (progress) in
                //progress closure
                self.progressUpload.setProgress(Float(progress.fractionCompleted), animated: true)
            }).response(completionHandler: { (response) in
                
                self.uploadAlertView.dismiss(animated: true, completion: nil)
                // check result is success
                guard response.error == nil else {

                    failure()
                    return
                }
                
                success()
               
            })
    }
    
    //MARK: Already Download
    
    func isFileAlreadyDownload(path:String) -> Bool{
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            return true
        }else{
            return false
        }
    }
    
    //MARK: Private Methods
    
    func setupUploadAlert() {
        
        uploadAlertView = UIAlertController(title: "Downloading..", message: "", preferredStyle: .alert)
        uploadAlertView.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
            self.request?.cancel()
        }))
        progressUpload  = UIProgressView(progressViewStyle: .default)
        progressUpload.setProgress(0, animated: true)
        progressUpload.frame = CGRect(x: 10, y: 55, width: 250, height: 0)
        uploadAlertView.view.addSubview(progressUpload)
        
    }
    
    func openDocumentWithURL(url:URL){
        
        self.docController = UIDocumentInteractionController(url: url)
        self.docController?.delegate = self
        self.docController?.name = "Preview"
        self.docController?.presentPreview(animated: true)
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        UINavigationBar.appearance().barTintColor = ColorConstants.WhiteColor
        UINavigationBar.appearance().tintColor = UIColor.white
        let BarButtonItemAppearance = UIBarButtonItem.appearance()
        BarButtonItemAppearance.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        BarButtonItemAppearance.setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -200, vertical: 0), for:UIBarMetrics.default)
        return UIViewController.current()
    }
}
