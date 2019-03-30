//
//  ChatThreadModel.swift
//  ConferenceAssociationApp
//
//  Created by Coruscate on 21/11/18.
//  Copyright © 2018 CS-Mac-Mini. All rights reserved.
//

import UIKit
import ObjectMapper
import RealmSwift
import Realm
import ObjectMapper_Realm

class ChatThreadModel: Object, Mappable {

    @objc dynamic var id: String?
    @objc dynamic var reference_id: String?
    @objc dynamic var module: Int = 0
    @objc dynamic var name: String?
    @objc dynamic var image: String?
    @objc dynamic var type: Int = 1
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    func mapping(map: Map) {
        
        id                 <- map["id"]
        reference_id       <- map["reference_id"]
        module             <- map["module"]
        name               <- map["title"]
        image              <- map["image"]
    }
}
