//
//  PostByModel.swift
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

class PostByModel: Object, Mappable {

    @objc dynamic var image: String?
    @objc dynamic var id: String?
    @objc dynamic var name: String?
    @objc dynamic var first_name: String?
    @objc dynamic var last_name: String?
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    func mapping(map: Map) {
        
        image              <- map["image"]
        id                 <- map["id"]
//        name               <- map["name"]
        first_name         <- map["first_name"]
        last_name          <- map["last_name"]
        
        name = "\(first_name ?? "") \(last_name ?? "")"
    }
}
