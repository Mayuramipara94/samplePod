//
//  MMChatCell.swift
//  ConferenceAssociationApp
//
//  Created by Coruscate on 23/08/18.
//  Copyright © 2018 CS-Mac-Mini. All rights reserved.
//

import UIKit

class MMChatCell: UITableViewCell {
    
    @IBOutlet var LblSenderName: UILabel!
    @IBOutlet var LblMessage: UILabel!
    @IBOutlet var LblTime: UILabel!
    
    @IBOutlet var ImgUser: UIImageView!
    @IBOutlet var ImgStatus: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        ImgUser.layer.cornerRadius = ImgUser.frame.size.width/2
        ImgUser.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellData(message : MessageModel)  {
        
        if message.type == ChatConstant.MessageType.Log {
            self.LblTime.text = message.comment
        }
        else
        {
            if message.isIncoming == true {
               self.LblSenderName.text = message.postBy?.name
            }
            else{
              self.LblSenderName.text = ""
            }
            
            if message.is_chat_message_deleted{
               self.LblMessage.text = StringConstants.CreateCase.KDeletedMessage
            }
            else{
              self.LblMessage.text = message.comment
            }
            
            
            self.LblTime.text = message.messageDate()
            if let urlStr = message.postBy?.image,urlStr.count > 0, let url = URL(string: urlStr){
                
                ImgUser.setImageForURL(url: url, placeHolder: #imageLiteral(resourceName: "userChat"))
            }
            else{
                ImgUser.image = #imageLiteral(resourceName: "userChat")
            }
            
            self.ImgStatus.image = UIImage(named: message.MessageStatusImage())
        }
        
        //Attachemnt
        self.handleAttachment(message: message)
    }
    
    //Delete
    func handleDelete(message : MessageModel,isActiveselected : Bool) {
        
        if self is MMChatOutGoingCell {
            let cell = self as? MMChatOutGoingCell
            cell?.setDeleteOnOff(model: message, isActiveselected: isActiveselected)
        }
        else if self is MMChatOutAttachmentOutGoingCell {
            let cell = self as? MMChatOutAttachmentOutGoingCell
            cell?.setDeleteOnOff(model: message, isActiveselected: isActiveselected)
        }
    }
    
    //Attachment
    func handleAttachment(message : MessageModel) {
        
        if self is MMChatOutAttachmentOutGoingCell {
            let cell = self as? MMChatOutAttachmentOutGoingCell
            cell?.setAttachment(model: message)
        }
        else if self is MMChatAttachmentInCommingCell {
            let cell = self as? MMChatAttachmentInCommingCell
            cell?.setAttachment(model: message)
        }
    }
}
