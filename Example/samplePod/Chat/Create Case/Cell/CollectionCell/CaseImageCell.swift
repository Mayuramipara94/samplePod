//
//  CaseImageCell.swift
//  ConferenceAssociationApp
//
//  Created by Coruscate on 22/11/18.
//  Copyright © 2018 CS-Mac-Mini. All rights reserved.
//

import UIKit

class CaseImageCell: UICollectionViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var btnDelete: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.layer.cornerRadius = 4.0
        self.layer.masksToBounds = true
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
        
        if let desc = model.fileDesc,desc.count > 0 {
           lblDesc.isHidden = false
        }
        else{
            lblDesc.isHidden = true
        }
        
        lblDesc.text = model.fileDesc
        lblDate.text = DateUtilities.convertStringDateintoStringWithFormat(dateStr: model.fileDate ?? "", format: DateUtilities.DateFormates.kCreateCaseDate)
        
    }
}
