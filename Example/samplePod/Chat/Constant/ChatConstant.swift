//
//  ChatConstant.swift
//  ConferenceAssociationApp
//
//  Created by Coruscate on 17/08/18.
//  Copyright © 2018 CS-Mac-Mini. All rights reserved.
//

import UIKit

class ChatConstant: NSObject {
    
    //Server URL
    static let serverURL                 = AppConstants.serverURL
    static let FirstSyncDate             = "1970-01-01T00:00:00.000Z"
    
    static let RefreshList       = "Refreshing List"
    static let RefreshMessage       = "Refreshing Message"
    
    struct URL {
        static let UploadChatDocument        = "/upload-file-device"
    }
    
    //MARK: Color
    struct Color {
        
        static let BackGround            = #colorLiteral(red: 0.9333333333, green: 0.9254901961, blue: 0.9529411765, alpha: 1)
        static let ChatNotification      = #colorLiteral(red: 0, green: 0.5019607843, blue: 0, alpha: 1)
    }
    
    //MARK: Notification
    struct Notification {
        
        static let MessageReceived      = "MessageReceivedNotification"
    }
    
    //MARK: User Image
    struct Avtar {
        
        static let InCommingHeight       = 0
        static let InCommingWidth        = 0
        
        static let OutGoingHeight        = 0
        static let OutGoingWidth         = 0
    }
    
    //MARK: Chat Type
    struct ChatType {
        
        static let OneToOne             = 1
        static let OneToMany            = 2
        static let BroadCast            = 3
    }
    
    enum ViewType : Int {
        
        case CHAT_VIEW_TYPE_GROUP = 1
        case CHAT_VIEW_TYPE_WALL = 2
    }
    
    //MARK: Attachment Type
    struct AttachmentType {
        
        static let Image               = 1
        static let Video               = 2
        static let Document            = 3
        static let Audio               = 4
    }
    
    //MARK: Attachment Download State
    struct AttachmentDownload {
        
        static let Not                 = 1
        static let Downloading         = 2
        static let Downloaded          = 3
        static let Error               = 4
    }
    
    //MARK: Like Constant
    struct LikeConstant {
        static let Like = 1
        static let DisLike = 2
    }
    
    //MARK: Message Type
    struct MessageType {
        
        static let Chat                = 1
        static let Log                 = 2
    }
    
    //MARK: Message Status
    struct MessageStatus {
        
        static let Sent                = 1
        static let Delivered           = 2
        static let Read                = 3
        static let Sending             = 4
        static let Delete              = 5
    }
    
    //MARK: Chat Thread User Type
    struct ThreadUserType {
        
        static let Admin               = 1
        static let Member              = 2
    }
    
    //MARK: Chat Participant Add/Remove
    struct ParticipantType {
        
        static let Add                = 1
        static let Remove             = 2
    }
    
    //MARK: Listner
    struct Listner {
        
        static let ThreadSynced          = "threadSynced"
        static let MessageSynced         = "messageSynced"
        static let Error                 = "message"
        static let ConnectedSocket       = "connectedSocket"
        static let UpdatedStatus         = "updatedStatus"
        static let MessageReceived       = "broadCastedMessage"
        static let MessageStatusUpdate   = "changedStatus"
        static let AssignedThread        = "assignedThread"
        static let ModifyThread          = "modifiedThread"
        static let Participate           = "participate"
        static let ChangeParticipate     = "changeParticipate"
        static let deletedMessages       = "deletedMessages"
    }
    
    //MARK: Emitter
    struct Emitter {
        
        static let ConnectSocket         = "connectSocket"
        static let SendMessage           = "broadCastMessage"
        static let JoinThread            = "joinThread"
        static let LeaveThread           = "leaveThread"
        static let UpdateStatus          = "updateStatus"
        static let ThreadSync            = "threadSync"
        static let MessageSync           = "messageSync"
        static let AssignThread          = "assignThread"
        static let ModifyThread          = "modifyThread"
        static let Participants          = "participant"
        static let ChangeParticipants    = "changeParticipant"
        static let MessageDelete         = "deleteMessages"
        
    }

}
