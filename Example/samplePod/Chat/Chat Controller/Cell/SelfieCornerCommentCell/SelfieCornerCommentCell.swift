//
//  SelfieCornerCommentCell.swift
//  ConferenceAssociationApp
//
//  Created by CS-Mac-Mini on 01/01/19.
//  Copyright © 2019 CS-Mac-Mini. All rights reserved.
//

import UIKit

class SelfieCornerCommentCell: UITableViewCell {

    //MARK: IBOutlet
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblComments: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = .none
        imgUser.layer.cornerRadius = imgUser.frame.width / 2
        imgUser.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellData(message : MessageModel)  {
        
        let date = DateUtilities.getDateFromISO(dateStr: message.createdAt ?? "")
        
        self.lblName.text = message.postBy?.name
        self.lblTime.text = DateUtilities.getFomattedDate(date: date)
        self.lblComments.text = message.comment
        if let urlStr = message.postBy?.image,let url = URL(string: "\(ChatConstant.serverURL)\(urlStr)"){
            imgUser.setImageForURL(url: url, placeHolder: #imageLiteral(resourceName: "user_placeholder"))
        }
        else{
            imgUser.image = #imageLiteral(resourceName: "user_placeholder")
        }
    }
}
