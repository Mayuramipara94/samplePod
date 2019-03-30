//
//  ImageCropCell.swift
//  ConferenceAssociationApp
//
//  Created by Coruscate on 22/11/18.
//  Copyright © 2018 CS-Mac-Mini. All rights reserved.
//

import UIKit

class ImageCropCell: UICollectionViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    func setCellData(model : UploadDocumentsModel) {
        
        if model.image != nil {
            imgView.image = model.image
        }
        else if let url = URL(string: "\(AppConstants.serverURL)\(model.fileServerUrl ?? "")"){
            
            imgView.setImageForURL(url: url, placeHolder: #imageLiteral(resourceName: "image"))
        }
        else{
            imgView.image = #imageLiteral(resourceName: "image")
        }
    }
    
}
