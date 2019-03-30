//
//  SelfieCornerDetailCell.swift
//  ConferenceAssociationApp
//
//  Created by CS-MacSierra on 29/12/18.
//  Copyright © 2018 CS-Mac-Mini. All rights reserved.
//

import UIKit

class SelfieCornerDetailCell: UITableViewCell {
    
    //MARK:- Variables
    var cellModel: GroupListModel?
    
    //MARK:- Outlets
    @IBOutlet var vwBg: UIView!
    @IBOutlet var imgProfile: UIImageView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblDate: UILabel!
    @IBOutlet var lblDescription: UILabel!
    @IBOutlet var imgAttachment: UIImageView!
    @IBOutlet var imgAttachmentHeight: NSLayoutConstraint!
    
    @IBOutlet var btnAttachment: UIButton!
    
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
    
    func setCellData(model : GroupListModel) {
        
        cellModel = model
        
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
        
        if let strMain = model.referenceId?.author?.image,let str = strMain.stringByAddingPercentEncodingForURL(),let url = URL(string: "\(ChatConstant.serverURL)\(str)") {
            imgProfile.setImageForURL(url: url, placeHolder: #imageLiteral(resourceName: "user_placeholder"))
        }
        else {
            imgProfile.image = #imageLiteral(resourceName: "user_placeholder")
        }
        
        if let strMain = model.referenceId?.attachments.first?.path,let str = strMain.stringByAddingPercentEncodingForURL(),let url = URL(string: "\(ChatConstant.serverURL)\(str)") {
            imgAttachment.setImageForURL(url: url, placeHolder: #imageLiteral(resourceName: "placeHolder"))
            imgAttachment.isHidden = false
            imgAttachmentHeight.constant = imgAttachment.bounds.size.width
        }
        else {
            imgAttachment.isHidden = true
            imgAttachmentHeight.constant = 0
        }
    }
    
    
    //MARK:- IBActions
    @IBAction func btnAttachmentClicked(_ sender: UIButton) {
        
        if let url = cellModel?.referenceId?.attachments.first?.path,url.count > 0 {
            
            var images = [SKPhoto]()
            let photo = SKPhoto.photoWithImageURL("\(ChatConstant.serverURL)\(url)")
            photo.shouldCachePhotoURLImage = true // you can use image cache by true(NSCache)
            images.append(photo)
            
            // 2. create PhotoBrowser Instance, and present.
            let browser = SKPhotoBrowser(photos: images)
            browser.initializePageIndex(0)
            UIViewController.current().present(browser, animated: true, completion: nil)
            
        }
       
    }
    
}
