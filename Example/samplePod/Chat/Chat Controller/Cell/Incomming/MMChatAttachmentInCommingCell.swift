//
//  MMChatAttachmentInCommingCell.swift
//  Chat
//
//  Created by Coruscate on 06/10/17.
//  Copyright © 2017 Coruscate. All rights reserved.
//

import UIKit

class MMChatAttachmentInCommingCell: MMChatCell {
    
    @IBOutlet var Image_View: UIImageView!
    @IBOutlet var BtnDownload: UIButton!
    @IBOutlet var AvtarHeight: NSLayoutConstraint!
    @IBOutlet var AvtarWidth: NSLayoutConstraint!

    var message : MessageModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.intialConfig()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    private func intialConfig() {
        
        self.Image_View.layer.cornerRadius = 5.0
        self.Image_View.layer.masksToBounds = true
        self.AvtarWidth.constant  =  CGFloat(ChatConstant.Avtar.InCommingWidth)
        self.AvtarHeight.constant =  CGFloat(ChatConstant.Avtar.InCommingHeight)
    }
    
    //Set Attachment
    func setAttachment(model : MessageModel) {
        
        self.message = model
        if model.attachment?.status == ChatConstant.AttachmentDownload.Downloading {
            self.BtnDownload.isHidden = true
            self.Image_View.image = nil
        }
        else if model.attachment?.isDownloaded() == true {
            self.BtnDownload.isHidden = true
            self.Image_View.image = model.attachment?.AttachmentImage()
        }
        else {
            self.BtnDownload.isHidden = false
            self.Image_View.image = nil
        }
    }

    
    @IBAction func downloadBtnTap(_ sender: Any) {
        
        self.BtnDownload.isHidden = true
        self.message?.attachment?.status = ChatConstant.AttachmentDownload.Downloading
        DownloadManager.sharedInstance.downloadFileWithURL(fileUrl: "\(self.message?.attachment?.path ?? "")", saveFileWithName: (self.message?.attachment?.path?.fileName())!, isProgeressShow: false, success: {
            
            self.message?.attachment?.status = ChatConstant.AttachmentDownload.Downloaded
            self.setAttachment(model: self.message!)
            
        }) {
            self.BtnDownload.isHidden = false
            self.message?.attachment?.status = ChatConstant.AttachmentDownload.Not
        }
    }
    
}
