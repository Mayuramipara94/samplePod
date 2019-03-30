//
//  SelfieCornerListCell.swift
//  ConferenceAssociationApp
//
//  Created by CS-MacSierra on 28/12/18.
//  Copyright © 2018 CS-Mac-Mini. All rights reserved.
//

import UIKit

class SelfieCornerListCell: UITableViewCell {

    //MARK:- Variables
    
    //MARK:- Outlets
    @IBOutlet var vwBg: UIView!
    @IBOutlet var imgProfile: UIImageView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblDate: UILabel!
    @IBOutlet var lblDescription: UILabel!
    @IBOutlet var imgAttachment: UIImageView!
    @IBOutlet var imgAttachmentHeight: NSLayoutConstraint!
    
    @IBOutlet var btnLike: UIButton!
    @IBOutlet var lblLike: UILabel!
    @IBOutlet var btnComment: UIButton!
    @IBOutlet var lblComment: UILabel!
    
    var model = GroupListModel()
    var updateData : (()->())?
    
    //MARK:- View's Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        imgProfile.setCornerRadius(radius: imgProfile.bounds.size.height / 2)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK:- SetData
    func setCellData(model : GroupListModel) {
        
        self.model = model
        
        if let createdBy = model.referenceId?.author?.name {
            lblTitle.text = createdBy
        }
        else{
            lblTitle.text = ""
        }
        
        
        lblDate.text = DateUtilities.convertStringDateintoStringWithFormat(dateStr: model.updatedAt ?? "", format: DateUtilities.DateFormates.kCreateCaseDate)
        
        if let desc = model.referenceId?.descriptionStr, desc.count > 0 {
            lblDescription.text = desc
        }
        else{
            lblDescription.text = ""
        }
        
        lblLike.text = "\(model.likesCount)"
        lblComment.text = "\(model.commentsCount)"
        
        if model.isLike == ChatConstant.LikeConstant.Like {
            btnLike.isSelected = true
        }
        else {
            btnLike.isSelected = false
        }
        
        if let str = model.referenceId?.author?.image?.stringByAddingPercentEncodingForURL(),let url = URL(string: "\(ChatConstant.serverURL)\(str)") {
            imgProfile.setImageForURL(url: url, placeHolder: #imageLiteral(resourceName: "user_placeholder"))
        }
        else {
            imgProfile.image = #imageLiteral(resourceName: "user_placeholder")
        }
        
        if let str = model.referenceId?.attachments.first?.path?.stringByAddingPercentEncodingForURL(),let url = URL(string: "\(ChatConstant.serverURL)\(str)") {
           
            imgAttachment.setImageForURL(url: url, placeHolder: #imageLiteral(resourceName: "placeHolder"))
            imgAttachment.isHidden = false
            imgAttachmentHeight.constant = AppConstants.ScreenSize.SCREEN_WIDTH - 32
        }
        else {
           
            imgAttachment.isHidden = true
            imgAttachmentHeight.constant = 0
        }
    }
    //MARK:- IBActions
    @IBAction func btnLikeClicked(_ sender: UIButton) {
        
        GroupListModel.callAPIForLikeDislike(module: AppConstants.ModuleConstant.CHAT_GROUP, model: self.model) {
            
            self.updateData?()
        }
    }
    
    @IBAction func btnCommentClicked(_ sender: UIButton) {
        
        let vc = MMChatController(nibName: "MMChatController", bundle: nil)
        vc.threadId = self.model.id
        vc.referenceId = self.model.referenceId?.id
        vc.module = AppConstants.ModuleConstant.CHAT_GROUP
        vc.isSelfieCorner = true
        UIViewController.current().navigationController?.pushViewController(vc, animated: true)
    }
    
}
