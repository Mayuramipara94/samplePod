//
//  MessageModel.swift
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

class MessageModel: Object, Mappable {

    @objc dynamic var temp_id: String?
    @objc dynamic var id: String?
    @objc dynamic var chat_thread_id: String?
    @objc dynamic var threadType: Int = 1
    @objc dynamic var comment: String?
    @objc dynamic var createdAt: String?
    @objc dynamic var updatedAt: String?
    
    @objc dynamic var status: Int = 4
    @objc dynamic var type: Int = 1
    @objc dynamic var is_chat_message_deleted: Bool = false
    @objc dynamic var isIncoming: Bool = true
    @objc dynamic var isSync : Bool = false
    
    @objc dynamic var postBy: PostByModel?
    @objc dynamic var attachment: ChatAttachmentModel?
    var participants = List<ParticipantModel>()
    
    var isSelected = false
    var viewModule = ChatConstant.ViewType.CHAT_VIEW_TYPE_GROUP
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override class func primaryKey() -> String? {
        return "temp_id"
    }
    
    func mapping(map: Map) {
        
        temp_id                 <- map["_temp_id"]
        id                      <- map["id"]
        
        var threadDic : [String : Any]?
        threadDic <- map["chat_thread_id"]
        
        if threadDic != nil {
            chat_thread_id  = threadDic?["id"] as? String
            threadType      = threadDic?["type"] as? Int ?? ChatConstant.ChatType.OneToOne
            
            //Participants
            if let arrParticipants = threadDic?["participants"] as? [[String : Any]] {
              let tempParticipants    = Mapper<ParticipantModel>().mapArray(JSONArray: arrParticipants)
                for item in tempParticipants {
                    participants.append(item)
                }
            }
            
            //reference_detail
            if let refDict = threadDic?["reference_detail"] as? [String : Any] {
                
                if let viewModule = refDict["viewModule"] as? Int {
                   if viewModule == 1{
                        
                        self.viewModule = .CHAT_VIEW_TYPE_GROUP
                    }else{
                        
                        self.viewModule = .CHAT_VIEW_TYPE_WALL
                    }
                }
            }
            
        }
        else{
           chat_thread_id          <- map["chat_thread_id"]
        }
        
        comment                 <- map["comment"]
        createdAt               <- map["createdAt"]
        updatedAt               <- map["updatedAt"]
        
        status                  <- map["status"]
        type                    <- map["type"]
        
        var del = Bool()
        del <- map["is_deleted"]
        var chatDel = Bool()
        chatDel <- map["is_chat_message_deleted"]
        if del || chatDel{
            
            is_chat_message_deleted = true
        }else{
            
            is_chat_message_deleted = false
        }
        
        
        postBy                  <- map["post_by"]
        attachment              <- map["attachment"]

        isSync = true
        if postBy?.id == ApplicationData.user.id {
            isIncoming = false
        }
        else {
            isIncoming = true
        }
    }
    
    //MARK: Message Status Image
    public func MessageStatusImage() -> String {
        
        if self.status == ChatConstant.MessageStatus.Sent {
            return "ic_sent_Message"
        }
        else if self.status == ChatConstant.MessageStatus.Sending {
            return "ic_sending_message"
        }
        else if self.status == ChatConstant.MessageStatus.Delivered {
            return "ic_deliverd_message"
        }
        else if self.status == ChatConstant.MessageStatus.Read {
            return "ic_Read_mesage"
        }
        return ""
    }
    
    //Message Date
    func messageDate() -> String {
        return DateUtilities.convertStringDateintoStringWithFormat(dateStr: self.createdAt ?? "", format: "hh:mm a")
    }
    
    //Header Date
    func headerDate() -> String {
        return DateUtilities.convertStringDateintoStringWithFormat(dateStr: self.createdAt ?? "", format: "dd MMM yyyy")
    }
}
