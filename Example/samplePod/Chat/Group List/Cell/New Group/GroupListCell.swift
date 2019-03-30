//
//  GroupListCell.swift
//  ConferenceAssociationApp
//
//  Created by Coruscate on 17/08/18.
//  Copyright © 2018 CS-Mac-Mini. All rights reserved.
//

import UIKit

class GroupListCell: UITableViewCell {
    
    @IBOutlet weak var imgGroup: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblLastMessage: UILabel!
    @IBOutlet weak var lblCount: UILabel!
    
    @IBOutlet weak var lblCreatedBy: UILabel!
    @IBOutlet weak var lblCreatedAt: UILabel!
    @IBOutlet weak var lblCreatedByTitle: UILabel!
    @IBOutlet weak var lblCreatedAtTitle: UILabel!
    @IBOutlet weak var lblCreatedByTop: NSLayoutConstraint!
    @IBOutlet weak var lblCreatedAtTop: NSLayoutConstraint!
    
    
    @IBOutlet weak var heightAttachment: NSLayoutConstraint!
    @IBOutlet weak var widthAttachment: NSLayoutConstraint!
    
    @IBOutlet weak var vwArchiveDeleteHeight: NSLayoutConstraint!
    @IBOutlet weak var vwArchiveDelete: UIView!
    
    var module = 0
    var model = GroupListModel()
    
    var reloadData : (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.selectionStyle = .none
        imgGroup.setCornerRadius(radius: imgGroup.frame.size.height/2)
        lblCount.setCornerRadius(radius: lblCount.frame.size.height/2)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellData(model : GroupListModel) {
        
        self.model = model
        
        if let createdBy = model.referenceId?.author?.name {
            lblCreatedBy.text = createdBy
            lblCreatedByTitle.text = "Created By :- "
            lblCreatedByTop.constant = 8
        }
        else{
           lblCreatedBy.text = ""
           lblCreatedByTitle.text = ""
           lblCreatedByTop.constant = 0
        }
        
        if ApplicationData.user.type == AppConstants.UserType.SUB_ADMIN || ApplicationData.user.type == AppConstants.UserType.ADMIN {
            
            lblCreatedAt.text = ""
            lblCreatedAtTitle.text = ""
            lblCreatedAtTop.constant = 0
        }
        else{
            
            lblCreatedAt.text = DateUtilities.convertStringDateintoStringWithFormat(dateStr: model.createdAt ?? "", format: DateUtilities.DateFormates.kCreateCaseDate)
            lblCreatedAtTitle.text = "Created At :- "
            lblCreatedAtTop.constant = 8
        }
        
        if self.module == AppConstants.ModuleConstant.SUPPORT && (ApplicationData.user.type == AppConstants.UserType.SUB_ADMIN || ApplicationData.user.type == AppConstants.UserType.ADMIN) {
        
            vwArchiveDelete.isHidden = false
            vwArchiveDeleteHeight.constant = 35
        }
        else{
            
            vwArchiveDelete.isHidden = true
            vwArchiveDeleteHeight.constant = 0
        }
        
        heightAttachment.constant = 0
        widthAttachment.constant = 0
        lblLastMessage.text = ""
        lblTitle.text = model.title
        lblTime.text = DateUtilities.convertStringDateintoStringWithFormat(dateStr: model.updatedAt ?? "", format: DateUtilities.DateFormates.kOnlyTime)
        
        //Count
        lblCount.text = "\(model.unread_count)"
        if model.unread_count > 0 {
            lblCount.isHidden = false
        }
        else{
            lblCount.isHidden = true
        }
        
        //Last Message
        if let lastMessage = model.lastMessage {
            
            lblLastMessage.text = lastMessage.comment
            if lastMessage.is_chat_message_deleted {
                lblLastMessage.text = StringConstants.CreateCase.KDeletedMessage
            }
            else  if lastMessage.is_attachment {
                heightAttachment.constant = 16
                widthAttachment.constant = 16
            }
        }
        
        if let str = model.referenceId?.attachments.first?.path?.stringByAddingPercentEncodingForURL(),let url = URL(string: "\(ChatConstant.serverURL)\(str)") {
            
            imgGroup.setImageForURL(url: url, placeHolder: #imageLiteral(resourceName: "user_placeholder"))
        }
        else if let str = model.image?.stringByAddingPercentEncodingForURL(),let url = URL(string: "\(ChatConstant.serverURL)\(str)") {
            imgGroup.setImageForURL(url: url, placeHolder: #imageLiteral(resourceName: "user_placeholder"))
        }
        else if let title = model.title,title.count > 0{
            let chr = title.uppercased()
            imgGroup.setImage(string: String(format:"%c", (chr as NSString).character(at: 0)), color: ColorConstants.ThemeColor, circular: true, textAttributes: nil)
        }else{
            
            imgGroup.image = #imageLiteral(resourceName: "user_placeholder")
        }

    }
    
    @IBAction func btnArchive_Click(_ sender: UIButton) {
        
        callAPIForArchive {
            
            self.reloadData?()
        }
    }
    
    @IBAction func btnDelete_Click(_ sender: UIButton) {
        
        callAPIForDelete {
            
            self.reloadData?()
        }
    }
    
}

extension GroupListCell{
    
     func callAPIForArchive(success:@escaping (()->Void)){
        
        var request = Parameters()
     
        request["chat_thread_id"] = self.model.id
        request["is_archive"] = true
        
        NetworkClient.sharedInstance.showIndicator("", stopAfter: 0.0)
        NetworkClient.sharedInstance.request(AppConstants.serverURL, command: AppConstants.URL.ArchiveGroup, method: .post, parameters: request, headers: ApplicationData.sharedInstance.authorizationHeaders, success: { (response, message) in
           
            ChatManager.sharedInstance.updateArchive(threadId: self.model.id ?? "")
            Utilities.showAlertWithButtonAction(title: AppConstants.AppName, message: message, buttonTitle: StringConstants.kOk, onOKClick: {
                
                success()
            })
            
            
        }) { (failureMessage, failureCode) in
            
            Utilities.showAlertView(title: AppConstants.AppName, message: failureMessage)
            
        }
    }
    
    func callAPIForDelete(success:@escaping (()->Void)){
        
        var request = Parameters()
        
        request["chat_thread_id"] = self.model.id
        NetworkClient.sharedInstance.showIndicator("", stopAfter: 0.0)
        NetworkClient.sharedInstance.request(AppConstants.serverURL, command: AppConstants.URL.DeleteGroup, method: .post, parameters: request, headers: ApplicationData.sharedInstance.authorizationHeaders, success: { (response, message) in
            
            ChatManager.sharedInstance.updateDelete(threadId: self.model.id ?? "")
            Utilities.showAlertWithButtonAction(title: AppConstants.AppName, message: message, buttonTitle: StringConstants.kOk, onOKClick: {
                
                success()
            })
            
        }) { (failureMessage, failureCode) in
            
            Utilities.showAlertView(title: AppConstants.AppName, message: failureMessage)
            
        }
    }
}
