//
//  LastMessage.swift
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

class LastMessage: Object, Mappable {
    
    @objc dynamic var createdAt: String?
    @objc dynamic var temp_id: String?
    @objc dynamic var message_id: String?
    @objc dynamic var comment: String?
    @objc dynamic var is_chat_message_deleted: Bool = false
    @objc dynamic var is_attachment: Bool = false
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override class func primaryKey() -> String? {
        return nil
    }
    
    func mapping(map: Map) {
        
        createdAt               <- map["createdAt"]
        comment                 <- map["comment"]
        is_attachment           <- map["is_attachment"]
        temp_id                 <- map["_temp_id"]
        message_id              <- map["message_id"]
        
        var del = Bool()
        del <- map["is_deleted"]
        var chatDel = Bool()
        chatDel <- map["is_chat_message_deleted"]
        if del || chatDel{
            
            is_chat_message_deleted = true
        }else{
            
            is_chat_message_deleted = false
        }
    }

}
