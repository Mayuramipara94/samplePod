//
//  UploadDocumentsModel.swift
//  Bank2Grow
//
//  Created by Vish on 19/05/18.
//  Copyright © 2018 Coruscate. All rights reserved.
//

import UIKit

class UploadDocumentsModel: NSObject {

    var strTitle : String?
    var requiredTitle : String?
    var attachmentName : String?
    var isAllowPDF : Bool?
    var isSelected = false
    var fileSize  : String?
    var fileType : String?
    var fileExtension : String?
    var fileUrl : URL?
    var image : UIImage?
    var fileSizeDouble : Double?
    var fileDesc : String?
    var fileDate : String?
    var fileServerUrl : String?
    
    
    override init() {
        
    }
    
}
