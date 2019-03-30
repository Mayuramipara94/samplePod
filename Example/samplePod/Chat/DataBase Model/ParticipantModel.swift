//
//  ParticipantModel.swift
//  ConferenceAssociationApp
//
//  Created by Coruscate on 20/08/18.
//  Copyright © 2018 CS-Mac-Mini. All rights reserved.
//

import UIKit
import ObjectMapper
import RealmSwift
import Realm
import ObjectMapper_Realm

class ParticipantModel: Object,Mappable {

    @objc dynamic var id: String?
    @objc dynamic var status: Int = 0
    @objc dynamic var status_updated_on: String?
    @objc dynamic var first_name: String?
    @objc dynamic var image: String?
    @objc dynamic var last_name: String?
    @objc dynamic var name: String?
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    func mapping(map: Map) {
        
        status_updated_on               <- map["status_updated_on"]
        status                          <- map["status"]
       
        //tags_with_color
        var user_id : [String : Any]?
        user_id     <- map["user_id"]
        
        id          = user_id?["id"] as? String
        first_name  = user_id?["first_name"] as? String
        last_name   = user_id?["last_name"] as? String
        image       = user_id?["image"] as? String
        name        = user_id?["name"] as? String
    }
}
