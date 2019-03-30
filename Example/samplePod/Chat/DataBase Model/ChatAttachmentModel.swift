//
//  ChatAttachmentModel.swift
//  ConferenceAssociationApp
//
//  Created by Coruscate on 23/08/18.
//  Copyright © 2018 CS-Mac-Mini. All rights reserved.
//

import UIKit
import ObjectMapper
import RealmSwift
import Realm
import ObjectMapper_Realm

class ChatAttachmentModel: Object, Mappable {
    
    @objc dynamic var path: String?
    @objc dynamic var type: Int = 0
    
    var status = ChatConstant.AttachmentDownload.Not
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override class func primaryKey() -> String? {
        return nil
    }
    
    func mapping(map: Map) {
        
        path                <- map["path"]
        type                <- map["type"]
        
        if self.isDownloaded() {
           self.status = ChatConstant.AttachmentDownload.Downloaded
        }
    }
    
    //Get Attachment Download State
    func isDownloaded() -> Bool {
        
        if let newPath = self.path,newPath.count > 0 {
            
            let url = Utilities.getDocumentsDirectory().appendingPathComponent("\(StringConstants.DownloadFolderName)").appendingPathComponent("\(newPath.fileName()).\(newPath.fileExtension())")
            
            if DownloadManager.sharedInstance.isFileAlreadyDownload(path: url.path){
               self.status = ChatConstant.AttachmentDownload.Downloaded
               return true
            }
        }
        
        return false
    }
    
    //Get Local Path
    func localPath() -> URL? {
        
        if let newPath = self.path,newPath.count > 0 {
            
            let url = Utilities.getDocumentsDirectory().appendingPathComponent("\(StringConstants.DownloadFolderName)").appendingPathComponent("\(newPath.fileName()).\(newPath.fileExtension())")
           
            return url
        }
        
        return nil
    }
    
    //Open
    func open() {
        
        if let url = self.localPath() {
            DownloadManager.sharedInstance.openDocumentWithURL(arrUrls: [url])
        }
    }
    
    //AttachmentImage
    public func AttachmentImage() -> UIImage {
        
        if self.type == ChatConstant.AttachmentType.Image {
            return self.loadImage() ?? #imageLiteral(resourceName: "document_chat")
        }
        else if self.type == ChatConstant.AttachmentType.Video {
            return #imageLiteral(resourceName: "video_chat")
        }
        else if self.type == ChatConstant.AttachmentType.Audio {
            return #imageLiteral(resourceName: "audio_chat")
        }
        
        return #imageLiteral(resourceName: "document_chat")
    }
    
    
    func loadImage() -> UIImage? {
        
        if let image = ChatManager.sharedInstance.attachmentsTable.object(forKey: self.path!.fileName() as NSString) as? UIImage {
            return image
        }
        
        let urlStr = "\(ChatAttachmentModel.documentDirectory())\(StringConstants.DownloadFolderName)/\(self.path!.fileName()).\(self.path!.fileExtension())"
        if let image = UIImage(contentsOfFile: urlStr) {
         
            ChatManager.sharedInstance.attachmentsTable.setObject(image, forKey: self.path!.fileName() as NSString)
            return image
        }
        return nil
    }
    
    //Docuement Directory
    class func documentDirectory() -> String {
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory: String = paths[0]
        return "\(documentsDirectory)/"
    }
}
