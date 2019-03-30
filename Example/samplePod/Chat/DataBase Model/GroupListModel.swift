//
//  GroupListModel.swift
//  ConferenceAssociationApp
//
//  Created by Coruscate on 17/08/18.
//  Copyright © 2018 CS-Mac-Mini. All rights reserved.
//

import UIKit
import ObjectMapper
import RealmSwift
import Realm
import ObjectMapper_Realm

class GroupListModel: Object, Mappable {

    @objc dynamic var id: String?
    @objc dynamic var title: String?
    @objc dynamic var createdAt: String?
    @objc dynamic var updatedAt: String?
    
    
    @objc dynamic var image: String?
    @objc dynamic var deleted_by: String?
    @objc dynamic var type: Int = 0
    @objc dynamic var unread_count: Int = 0
    @objc dynamic var is_deleted: Bool = false
    @objc dynamic var _temp_id: String?
    @objc dynamic var message_id: String?
    
    @objc dynamic var module: Int = 0
    @objc dynamic var conference_id: String?
    @objc dynamic var lastMessage: LastMessage?
    
    @objc dynamic var user_id: GroupUserModel?
    @objc dynamic var referenceId: GroupReferenceModel?
//    var participants = List<ParticipantModel>()
    
    
    @objc dynamic var tags_with_color : String? //Object
    
    @objc dynamic var commentsCount: Int = 0
    @objc dynamic var likesCount: Int = 0
    @objc dynamic var isLike: Int = 2
    @objc dynamic var isArchive: Int = 0
    @objc dynamic var refIdString: String?
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    func mapping(map: Map) {
        
        id                  <- map["id"]
        createdAt           <- map["createdAt"]
        updatedAt           <- map["updatedAt"]
        user_id             <- map["user_id"]
        
        image               <- map["image"]
        deleted_by          <- map["deleted_by"]
        is_deleted          <- map["is_deleted"]
        type                <- map["type"]
        unread_count        <- map["unread_count"]
        title               <- map["name"]
        lastMessage         <- map["last_message"]
        
        module              <- map["module"]
        conference_id       <- map["conference_id"]
        
//        commentsCount       <- map["commentsCount"]
//        likesCount          <- map["likesCount"]
//        isLike              <- map["isLike"]
        isArchive           <- map["isArchive"]
        
        if let lcreatedAt = lastMessage?.createdAt {
            self.updatedAt = lcreatedAt
        }
        
        var titleTemp : String?
        titleTemp <- map["title"]
        
        if let finalTitle = titleTemp,finalTitle.count > 0 {
            self.title = finalTitle
        }
        
        //tags_with_color
        var reference_idDic : [String : Any]?
        reference_idDic     <- map["reference_detail"]
        
        if reference_idDic != nil {
            
            //new message received
           referenceId     <- map["reference_detail"]
        }else{
            
            //id obj
            reference_idDic     <- map["reference_id"]
            
            if reference_idDic != nil {
                
                //thread sync
                referenceId <- map["reference_id"]
            }
            else{
                
                //support
                let referenceModel = GroupReferenceModel()
                referenceModel.id <- map["reference_id"]
                self.referenceId = referenceModel
            }
        }
        
        
        if let arrTags = reference_idDic?["tags_with_color"] as? [[String : Any]] {
           tags_with_color = Utilities.jsonToString(json: arrTags as Any)
        }
        
        refIdString = referenceId?.id
    }
}

//MARK: API Call
extension GroupListModel{
    
    static func callAPIForLikeDislike(module:Int,model:GroupListModel,success:@escaping (()->Void)){
        
        var request = Parameters()
        
        request["reference_id"] = model.refIdString
        request["module"] = module
        request["reaction_type"] = (model.isLike == ChatConstant.LikeConstant.Like ? ChatConstant.LikeConstant.DisLike : ChatConstant.LikeConstant.Like)
        
        NetworkClient.sharedInstance.request(AppConstants.serverURL, command: AppConstants.URL.MemberLike, method: .post, parameters: request, headers: ApplicationData.sharedInstance.authorizationHeaders, success: { (response, message) in
            
            ChatManager.sharedInstance.updateLikeStatus(model: model)
            
            success()
            
        }) { (failureMessage, failureCode) in
            
            Utilities.showAlertView(title: AppConstants.AppName, message: failureMessage)
            
        }
    }
}


//MARK: GroupReference Model

class GroupReferenceModel: Object, Mappable {
    
    @objc dynamic var id: String?
    @objc dynamic var patient_history: String?
    @objc dynamic var conclusion: String?
    @objc dynamic var treatment_and_followup: String?
    @objc dynamic var descriptionStr: String?
    @objc dynamic var links: String? //arrayObject
    var attachments = List<GroupAttachmentModel>()
    @objc dynamic var author: GroupAuthorModel?
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    func mapping(map: Map) {
        
        id                  <- map["id"]
        patient_history     <- map["patient_history"]
        conclusion          <- map["conclusion"]
        attachments         <- (map["attachments"], ListTransform<GroupAttachmentModel>())
        treatment_and_followup  <- map["treatment_and_followup"]
        descriptionStr      <- map["desc"]
        author              <- map["author"]
        
        var arrLinks  = [[String:Any]]()
        arrLinks     <- map["links"]
        links = Utilities.jsonToString(json: arrLinks as Any)
        
    }
}


//MARK: GroupAttachment Model

class GroupAttachmentModel: Object, Mappable {
    
    @objc dynamic var descriptionStr: String?
    @objc dynamic var path: String?
    @objc dynamic var type: Int = 1
    @objc dynamic var date: String?
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override class func primaryKey() -> String? {
        return nil
    }
    
    func mapping(map: Map) {
        
        descriptionStr      <- map["description"]
        path                <- map["path"]
        type                <- map["type"]
        date                <- map["date"]
        
    }
}

//MARK: GroupAuthor Model

class GroupAuthorModel: Object, Mappable {
    
    @objc dynamic var cell: String?
    @objc dynamic var image: String?
    @objc dynamic var name: String?
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override class func primaryKey() -> String? {
        return "cell"
    }
    
    func mapping(map: Map) {
        
        cell                <- map["cell"]
        image               <- map["image"]
        name                <- map["name"]
    }
}

//MARK: GroupUser Model

class GroupUserModel: Object, Mappable {
    
    @objc dynamic var cell: String?
    @objc dynamic var image: String?
    @objc dynamic var name: String?
    @objc dynamic var id: String?
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    func mapping(map: Map) {
        
        id                  <- map["id"]
        cell                <- map["cell"]
        image               <- map["image"]
        name                <- map["name"]
    }
}
