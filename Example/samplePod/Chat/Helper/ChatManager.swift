//
//  ChatManager.swift
//  ConferenceAssociationApp
//
//  Created by Coruscate on 17/08/18.
//  Copyright © 2018 CS-Mac-Mini. All rights reserved.
//

import UIKit
import UserNotifications

class ChatManager: NSObject {

    static let sharedInstance = ChatManager()
    
    let realm = SyncManager.sharedInstance.realm
    private let manager: SocketManager
    private var socket: SocketIOClient
    private var isConnectUser : Bool = false
    
    var attachmentsTable = NSMapTable<NSString, AnyObject>()
    
    private override init() {
        
         manager = SocketManager(socketURL: URL(string: ChatConstant.serverURL)!, config: [.log(true), .compress])
         socket = manager.defaultSocket
    }
    
    
    //Connect Socet With Server
    func connect(success:@escaping (()->Void)) {
        
        if !ApplicationData.isUserLoggedIn {
            return
        }
        
        //if socket allready connected assign listener
        if self.isConnect() {

            print("-------> socket connected")
            
            //Assign Listener
            self.errorHandler()
            self.disconnectHandler()

            //Connect User
            self.connectUser()

            success()
            return
        }
        
        //Connect socket
        socket.off(clientEvent: .connect)
        self.socket.on(clientEvent: .connect) {data, ack in
            
            print("-------> socket connected")
            
            //Assign Listener
            self.errorHandler()
            self.disconnectHandler()
            
            //Connect User
            self.connectUser()
            
            success()
        }

        self.socket.connect()
    }
    
    //Get socket Connect Or Not
    func isConnect() -> Bool  {
        if manager.status == .connected {
            return true
        }
        
        return false
    }

    //Get socket Status
    func status() -> SocketIOStatus {
        return manager.status
    }
    
    //socket Error
    func errorHandler() {
        
        socket.off(ChatConstant.Listner.Error)
        socket.on(ChatConstant.Listner.Error) {data, ack in
            print("-------> Socet Error \(data)")
        }
    }
    
    //socket DisConnect
    func disconnect() {
        socket.disconnect()
        manager.disconnect()
    }
    
    //socket DisConnectHandler
    func disconnectHandler() {
        
        socket.off(clientEvent: .disconnect)
        socket.on(clientEvent: .disconnect) {data, ack in
            self.isConnectUser = false
            print("-------> socket disconnect")
        }
    }
    
    //Connect User
    func connectUser() {
        
        if isConnectUser == false {
            
            socket.off(ChatConstant.Listner.ConnectedSocket)
            
            //User Connect Emit
            var requestDic = [String : Any]()
            requestDic["user_id"] = ApplicationData.user.id
            requestDic["conference_id"]  = ApplicationData.ConferenceDetails.id
            socket.emit(ChatConstant.Emitter.ConnectSocket, with: [requestDic])
            
            //User Connect Listner
            socket.on(ChatConstant.Listner.ConnectedSocket) {data, ack in
                print("-------> User Connected")
                self.isConnectUser = true
                self.handleUnSendMessage()
                self.messageReceivedWithcallback({ (messages) in
                })
            }
        }
    }
    
    //Thread Sync
    func syncThread(module : Int,success:@escaping (()->Void)) {
        
        if self.isConnect() == false{
            self.connect {
            }
        }
        
        socket.off(ChatConstant.Listner.ThreadSynced)
        
        //Thread Sync Emit
        var requestDic = [String : Any]()
        requestDic["user_id"]           = ApplicationData.user.id
        requestDic["conference_id"]     = ApplicationData.ConferenceDetails.id
        requestDic["module"]            = module
        
//        if let date = self.fetchLastSyncDateForThread(module: module),date.count > 0 {
//            requestDic["last_sync_date"] = date
//        }
//        else{
//           requestDic["last_sync_date"]    = ChatConstant.FirstSyncDate
//        }
        
        if module == AppConstants.ModuleConstant.CHAT_GROUP{
            
            requestDic["last_sync_date"]    = Defaults[.ChatGroupLastSyncDate]
        }else{
            
            requestDic["last_sync_date"]    = Defaults[.SupportLastSyncDate]
        }
        
        socket.emit(ChatConstant.Emitter.ThreadSync, with: [requestDic])
        
        //Thread Sync Listner
        socket.on(ChatConstant.Listner.ThreadSynced) {data, ack in
            
            if let dict = data.first as? [String:Any] {
                
                let serverModule = dict["module"] as? Int
                let dt = dict["last_sync_date"] as? String
                if serverModule == AppConstants.ModuleConstant.SUPPORT{
                    
                    Defaults[.SupportLastSyncDate] = dt
                }else{
                    
                    Defaults[.ChatGroupLastSyncDate] = dt
                }
                
                if let list = dict["threads"] as? [[String : Any]],list.count > 0 {
                    let groupList = Mapper<GroupListModel>().mapArray(JSONArray: list)
                    self.insertGroup(list: groupList)
                }
                
                self.manageThreadSyncResponse(dict: dict)
            }
            
            print("-------> Thread Sync")
            success()
        }
    }
    
    //Sync Message
    func syncMessage(threadId : String,isTime : Bool,success:@escaping (()->Void)) {
        
        socket.off(ChatConstant.Listner.MessageSynced)
        
        var requestDic = [String : Any]()
        requestDic["user_id"]           = ApplicationData.user.id
        requestDic["chat_thread_id"]    = threadId
        requestDic["limit"]             = 100
        requestDic["conference_id"]     = ApplicationData.ConferenceDetails.id
        
        if isTime, let date = self.fetchLastMessageDate(threadId: threadId),date.count > 0 {
            requestDic["last_sync_date"] = date
        }
        
        //Message Sync Emit
        socket.emit(ChatConstant.Emitter.MessageSync, with: [requestDic])
        
        //Message Sync Listner
        socket.on(ChatConstant.Listner.MessageSynced) {data, ack in
            
            if data.count > 0 {
                if let list = (data.first as! [String:Any])["messages"] as? [[String : Any]],list.count > 0 {
                    let messageList = Mapper<MessageModel>().mapArray(JSONArray: list)
                    self.insertMessage(list: messageList)
                }
            }
            
            print("-------> Message Sync")
            success()
        }
    }
    
    //Message Received
    func messageReceivedWithcallback(_ callback: @escaping (_ _Nonnull: [MessageModel]) -> Void) {
        
        socket.off(ChatConstant.Listner.MessageReceived)
        
        //Message Sync Listner
        socket.on(ChatConstant.Listner.MessageReceived) {data, ack in
            
            if let list = data as? [[String:Any]],list.count > 0 {
                let messageList = Mapper<MessageModel>().mapArray(JSONArray: list)
                self.insertMessage(list: messageList)
                self.handleGroupWithMessage(list: list)
                self.updateLastMessage(list: messageList)
                self.showNotification(messages: messageList)
                self.messageStatusUpdate(messages: messageList)
                self.updateCommentCount(threadId: messageList.first?.chat_thread_id ?? "")
                callback(messageList)
            }
            
            print("-------> Message Received")
        }
    }
    
    //Send Message
    func sendMessage(request : [String : Any]) {
        
        socket.emit(ChatConstant.Emitter.SendMessage, with: [request])
    }
    
    //Delete Message
    func messageDelete(ids : [String]) {
        
        var requestDic = [String : Any]()
        requestDic["user_id"]       = ApplicationData.user.id
        requestDic["messageIds"]    = ids
        requestDic["is_chat_message_deleted"] = true
        requestDic["conference_id"]     = ApplicationData.ConferenceDetails.id
        socket.emit(ChatConstant.Emitter.MessageDelete, with: [requestDic])
    }
    
    func messageDeleteWithcallback(_ callback: @escaping (_ _Nonnull: [MessageModel]) -> Void) {
        
        socket.off(ChatConstant.Listner.deletedMessages)
        
        //Message Status Listner
        socket.on(ChatConstant.Listner.deletedMessages) {data, ack in
            
            if let list = data as? [[String:Any]],list.count > 0 {
              
                if let messageDeleted = list.first?["messageDeleted"] as? [[String:Any]],messageDeleted.count > 0 {
                   let messages = self.updateMessageStatusForDelete(list: messageDeleted)
                   callback(messages)
                }
            }
            
            print("-------> Message Deleted")
        }
    }
    
    //UpdateMessage Status
    func messageStatusUpdate(messages : [MessageModel]) {
        
        var requestDic = [String : Any]()
        var messageId = [String]()
        for item in messages {
            
            if item.postBy?.id != ApplicationData.user.id && item.status != ChatConstant.MessageStatus.Read {
                messageId.append(item.id ?? "")
            }
        }
        
        if messageId.count > 0 {
            
            if let vc = UIViewController.current() as? MMChatController {
                
                if vc.threadId == messages.first?.chat_thread_id{
                    requestDic["status"]            = ChatConstant.MessageStatus.Read
                }
                else{
                    requestDic["status"]            = ChatConstant.MessageStatus.Delivered
                }
            }
            else{
                requestDic["status"]            = ChatConstant.MessageStatus.Delivered
            }
            
            requestDic["chat_thread_id"]    = messages.first?.chat_thread_id
            requestDic["user_id"]           = ApplicationData.user.id
            requestDic["id"]                = messageId
            requestDic["conference_id"]     = ApplicationData.ConferenceDetails.id
            
            //Emit Status Update
            socket.emit(ChatConstant.Emitter.UpdateStatus, with: [requestDic])
        }
    }
    
    func messageStatusUpdate(threadId : String,status : Int) {
        
        var requestDic = [String : Any]()
        requestDic["chat_thread_id"]    = threadId
        requestDic["user_id"]           = ApplicationData.user.id
        requestDic["status"]            = status
        requestDic["conference_id"]     = ApplicationData.ConferenceDetails.id
        
        //Emit Status Update
        socket.emit(ChatConstant.Emitter.UpdateStatus, with: [requestDic])
    }
    
    //Message Status Update CallBack
    func messageStatusUpdateWithcallback(_ callback: @escaping (_ _Nonnull: [MessageModel]) -> Void) {
        
        socket.off(ChatConstant.Listner.UpdatedStatus)
        
        //Message Status Listner
        socket.on(ChatConstant.Listner.UpdatedStatus) {data, ack in
            
            if let list = data as? [[String:Any]],list.count > 0 {
                let messages = self.updateMessageStatusInDB(list: list)
                callback(messages)
            }
            
            print("-------> Message Status Update")
        }
    }
    
    //UnSendMessage
    func handleUnSendMessage() {
        
        for item in self.fetchUnSyncMessage() {
            
            var request = [String : Any]()
            request["comment"] = item.comment
            request["_temp_id"] = item.temp_id
            request["chat_thread_id"] = item.chat_thread_id
            request["post_by"] = item.postBy?.id
            request["type"] = item.type
            
            if item.attachment != nil {
                
                var attachment = [String : Any]()
                attachment["path"] = item.attachment?.path
                attachment["type"] = ChatConstant.AttachmentType.Image
                request["attachment"] = attachment
            }
            
            self.sendMessage(request: request)
        }
    }
    
    //Assign Thread
    func assignThread(module : Int,referenceId : String,type : Int,name : String?,image : String?,success:@escaping ((_ chatThread : ChatThreadModel)->Void)) {
        
        //Connect Socket
        UIViewController.current().showCustomProgress(msg: ChatConstant.RefreshList)
        connect {
            
            if module != AppConstants.ModuleConstant.SUPPORT{
                
                let moduleThreads = self.fetchModuleThread(referenceId: referenceId)
                if moduleThreads.count > 0 {
                    
                    UIViewController.current().dismissCustomProgress()
                    success(moduleThreads.first!)
                    return
                }
            }
            
            var requestDic = [String : Any]()
            requestDic["user_id"]           = ApplicationData.user.id
            requestDic["module"]            = module
            requestDic["reference_id"]      = referenceId
            requestDic["type"]              = type
            requestDic["conference_id"]     = ApplicationData.ConferenceDetails.id
            
            if type == ChatConstant.ChatType.OneToOne {
                
                var loginUserDic  = [String : Any]()
                loginUserDic["user_id"]  = ApplicationData.user.id
                loginUserDic["type"]     = ChatConstant.ThreadUserType.Member
                
                var refUserDic  = [String : Any]()
                refUserDic["user_id"]  = referenceId
                refUserDic["type"]     = ChatConstant.ThreadUserType.Member
                
                requestDic["participants"]  = [loginUserDic,refUserDic]
            }
            else if module != AppConstants.ModuleConstant.SUPPORT{
                requestDic["title"]  = name
                requestDic["image"]  = image
            }
            
            
            //AssignThread Emit
            self.socket.emit(ChatConstant.Emitter.AssignThread, with: [requestDic])
            
            self.socket.off(ChatConstant.Listner.AssignedThread)
            //Message Sync Listner
            self.socket.on(ChatConstant.Listner.AssignedThread) {data, ack in
                
                UIViewController.current().dismissCustomProgress()
                if let list = data as? [[String:Any]],list.count > 0 {
                    
                    let masterList = Mapper<ChatThreadModel>().mapArray(JSONArray: list)
                    self.handleModlueThread(list: masterList)
                    success(masterList.first!)
                }
                
                print("-------> Assigned Thread")
            }
        }
    }
}

//MARK: Handle Notification
extension ChatManager {
    
    //Open Chat Module
    func openChat(viewType:ChatConstant.ViewType,module : Int,referenceId : String,type : Int,name : String?,image : String?,isSupportScreen : Bool = false) {
        
        if (ApplicationData.user.type == AppConstants.UserType.SUB_ADMIN || ApplicationData.user.type == AppConstants.UserType.ADMIN) && isSupportScreen{
            
            //If admin Or Submin Open Support List
            let vc = SupportListVC(nibName: "SupportListVC", bundle: nil)
            UIViewController.current().navigationController?.pushViewController(vc, animated: true)
        }
        else {
           
            //OpenChat Methods
            let mm = ChatThreadModel()
            mm.module = module
            mm.reference_id = referenceId
            mm.type = type
            mm.name = name
            mm.image = image
            
            let vc = MMChatController(nibName: "MMChatController", bundle: nil)
            vc.assignThreadRequest = mm
            vc.module       = module
            if viewType == ChatConstant.ViewType.CHAT_VIEW_TYPE_WALL{
                
                vc.isSelfieCorner = true
            }
            UIViewController.current().navigationController?.pushViewController(vc, animated: true)
            
//            //Assign Thread
//            assignThread(module: module, referenceId: referenceId, type: type, name: name, image: image) { thread in
//
//                try! self.realm.write {
//                    thread.name = name
//                    thread.image = image
//                    thread.type = type
//                }
//
//                //Only Referesh
//                if let vc = UIViewController.current() as? MMChatController {
//                    if vc.threadId == thread.id {
//                        return
//                    }
//                }
//
//
//                let vc = MMChatController(nibName: "MMChatController", bundle: nil)
//                vc.threadId     = thread.id
//                vc.module       = module
//                vc.referenceId  = thread.reference_id
//                if viewType == ChatConstant.ViewType.CHAT_VIEW_TYPE_WALL{
//
//                    vc.isSelfieCorner = true
//                }
//                UIViewController.current().navigationController?.pushViewController(vc, animated: true)
//            }
            
        }
    }
    
    //Show Notification
    func showNotification(messages : [MessageModel]) {
        
        let state = UIApplication.shared.applicationState
        
        if let vc = UIViewController.current() as? MMChatController,state != .background {
            
            if  vc.threadId == messages.first?.chat_thread_id {
                return
            }
        }
        
        for item in messages {
            
            if item.type != ChatConstant.MessageType.Log && item.isIncoming == true {
                
                let thread = self.fetchModuleThread(threadId: item.chat_thread_id ?? "")
                
                //PayLoad
                var payload = [String : Any]()
                payload["updated_module"] = thread.first?.module
                var data = [String :Any] ()
                data["isChat"] = true
                data["reference_id"]    = thread.first?.reference_id
                data["threadId"]        = thread.first?.id
                data["threadImage"]     = thread.first?.image
                data["threadName"]      = thread.first?.name
                data["threadType"]      = thread.first?.type
                var refDict = [String:Any]()
                refDict["viewModule"] = item.viewModule.rawValue
                data["reference_detail"] = refDict
               
                if thread.first?.type == ChatConstant.ChatType.OneToOne {
                    
                    //Payload
                    var participants = [[String : Any]]()
                    for itemParticipants in item.participants {
                        
                        var participantsDic = [String : Any]()
                        participantsDic["id"] = itemParticipants.id
                        participantsDic["name"] = itemParticipants.name
                        participantsDic["image"] = itemParticipants.image
                        participants.append(participantsDic)
                    }
                    data["participants"] = participants
                    payload["data"]      =  data
                    
                    //One to One
                    self.fireNotification(title: item.postBy?.name ?? "", message: item.comment ?? "", payLoad: payload)
                }
                else{
                    
                    payload["data"]         =  data
                    if thread.first?.module == AppConstants.ModuleConstant.SUPPORT {
                        
                        //One to Many
                        self.fireNotification(title: "\(item.postBy?.name ?? "")", message: item.comment ?? "", payLoad: payload)
                    }
                    else{
                        
                        //One to Many
                        if item.viewModule == ChatConstant.ViewType.CHAT_VIEW_TYPE_WALL{
                            
                            self.fireNotification(title: item.postBy?.name ?? "", message: item.comment ?? "", payLoad: payload)
                        }else{
                            
                            self.fireNotification(title: "\(item.postBy?.name ?? "") @\(thread.first?.name ?? "")", message: item.comment ?? "", payLoad: payload)
                        }
                    }
                }
            }
        }
    }
    
    func fireNotification(title : String,message : String,payLoad : [String : Any]?) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ChatConstant.Notification.MessageReceived), object: nil)
        }
        
        if #available(iOS 10.0, *) {
            //iOS 10 or above version
            let center = UNUserNotificationCenter.current()
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = message
            
            var userInfo    = [String : Any]()
            var aps         = [String : Any]()
            aps["data"]         = payLoad
            userInfo["aps"]     = aps
            content.userInfo    = userInfo
            content.sound = UNNotificationSound.default()
            
            let count = UIApplication.shared.applicationIconBadgeNumber
            content.badge = NSNumber(value: count + 1)
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }
    }
}

//MARK: Handle DataBase
extension ChatManager{
    
    //Update Message Status
    func updateMessageStatusInDB(list : [[String : Any]]) -> [MessageModel] {
        
        let ids = list.map { $0["_temp_id"] as? String ?? ""}
        let messages = self.fetchMessage(tempId: ids)
        
        for item in list {
            
            let filter = messages.filter({ (model) -> Bool in
                return model.temp_id == item["_temp_id"] as? String
            })
            
            try! self.realm.write {
                filter.first?.status = item["status"] as? Int ?? ChatConstant.MessageStatus.Sent
            }
        }
        
        return messages
    }
    
    //Update Message Status for delete
    func updateMessageStatusForDelete(list : [[String : Any]]) -> [MessageModel] {
        
        let ids = list.map { $0["_temp_id"] as? String ?? ""}
        let messages = self.fetchMessage(tempId: ids)
        for item in list {
            
            let filter = messages.filter({ (model) -> Bool in
                return model.temp_id == item["_temp_id"] as? String
            })
            
            try! self.realm.write {
                filter.first?.is_chat_message_deleted = item["is_chat_message_deleted"] as? Bool ?? false
            }
        }
        
        //Update threadLastMessages
        let lastMessages = self.fetchLastMessages(tempId: ids)
        for item in lastMessages {
            try! self.realm.write {
                item.is_chat_message_deleted = true
            }
        }
        
        return messages
    }
    
    //Insert Group From Message List
    func handleGroupWithMessage(list : [[String : Any]]) {
        
        for item in list {
            
            if let chat_thread_id = item["chat_thread_id"] as? [String : Any] {
                
                let threads = self.fetchGroupWith(id: chat_thread_id["id"] as? String ?? "")
                if threads.count == 0 {
                    let groupModel = GroupListModel(JSON: chat_thread_id)!
                    insertGroup(list: [groupModel])
                }
            }
        }
    }
    
    //Insert Group List
    func insertGroup(list : [GroupListModel]) {
        
        var chatThreads = [ChatThreadModel]()
        
        for obj in list
        {
            let model = ChatThreadModel()
            model.id = obj.id
            model.reference_id = obj.referenceId?.id
            model.module    = obj.module
            model.name      = obj.title
            model.image     = obj.image
            model.type      = obj.type
            chatThreads.append(model)
            
            if self.realm.isInWriteTransaction {
                self.realm.add(obj, update: true)
            }
            else {
                try! self.realm.write {
                    self.realm.add(obj, update: true)
                }
            }
        }
        
        self.handleModlueThread(list: chatThreads)
    }
    
    func manageThreadSyncResponse(dict:[String:Any]){
        
        //chatCount
        if let list = dict["chatCountSummary"] as? [[String : Any]],list.count > 0 {
            
            for dict in list{
                
                let id = dict["_id"] as? String ?? ""
                let model = ChatManager.sharedInstance.fetchGroupWith(id: id).first
                try! self.realm.write {
                    
                    model?.commentsCount = dict["myCount"] as? Int ?? 0
                }
            }
            
        }
        
        //data
        if let data = dict["data"] as? [String:Any]{
            
            //memberReactions
            if let list = data["memberReactions"] as? [[String : Any]],list.count > 0 {
                
                for mmDict in list{
                    
                    let id = mmDict["reference_id"] as? String ?? ""
                    let model = ChatManager.sharedInstance.fetchGroupWithRefrence(refrenceId: id).first
                    try! self.realm.write {
                        
                        var type = Utilities.getIntValue(value: mmDict["reaction_type"])
                        if type == 0{
                            
                            type = ChatConstant.LikeConstant.DisLike
                        }
                        model?.isLike = type
                    }
                }
            }
            
            //chatCount
            if let list = data["reactionSummary"] as? [[String : Any]],list.count > 0 {
                
                for mmDict in list{
                    
                    let refId = mmDict["reference_id"] as? String ?? ""
                    var totalLike = 0
                    if let ratingParams = mmDict["ratingParams"] as? [[String:Any]]{
                        
                        let ratingDict = ratingParams.first
                        if let userCount = ratingDict?["userCountByReaction"] as? [String:Any]{
                            
                            var type = Utilities.getIntValue(value: userCount["1"])
                            if type == 0{
                                
                                type = ChatConstant.LikeConstant.DisLike
                            }
                            totalLike = type
                        }
                    }
                    let model = ChatManager.sharedInstance.fetchGroupWithRefrence(refrenceId: refId).first
                    try! self.realm.write {
                        
                        model?.likesCount = totalLike
                    }
                }
            }
        }
        
        //Unread Count And LastMessage
        if let list = dict["chatCounts"] as? [[String : Any]],list.count > 0 {
            
            for item in list {
                
                let threadId = (item["id"] as? [String : Any])?["chat_thread_id"] as? String
                let thread = self.fetchGroupWith(id: threadId ?? "")
                let value = item["value"] as? [String : Any]
                
                if let threadModel = thread.first {
                    
                    try! self.realm.write {
                        
                        threadModel.updatedAt = value?["lastCreatedAt"] as? String
                        threadModel.unread_count = value?["unread_count"] as? Int ?? 0
                        threadModel.lastMessage?.comment = value?["comment"] as? String
                        threadModel.lastMessage?.is_attachment = value?["is_attachment"] as? Bool ?? false
                    }
                }
            }
        }
        
        //deleted
        if let list = dict["deleted"] as? [[String : Any]],list.count > 0 {
            
            let arrIds = list.map {$0["record_id"] as? String ?? ""}
            let pre = NSPredicate(format: "id IN %@",arrIds)
            let grpListModel = realm.objects(GroupListModel.self).filter(pre)
            let thrdListModel = realm.objects(ChatThreadModel.self).filter(pre)
            
            // and then just remove the set with
            try! realm.write {
                realm.delete(grpListModel)
                realm.delete(thrdListModel)
            }
        }
    }
    
    //Insert Message List
    func insertMessage(list : [MessageModel]) {
        
        for obj in list
        {
            if self.realm.isInWriteTransaction {
                self.realm.add(obj, update: true)
            }
            else {
                try! self.realm.write {
                    self.realm.add(obj, update: true)
                }
            }
        }
    }
    
    //Update Last Message
    func updateLastMessage(list : [MessageModel]) {
        
        var isUpdateCount = true
        if let vc = UIViewController.current() as? MMChatController,vc.threadId == list.first?.chat_thread_id {
            isUpdateCount = false
        }
        
        for item in list {
            
            let groups = self.fetchGroupWith(id: item.chat_thread_id ?? "")
            for group in groups {
                
                try! self.realm.write {
                    group.updatedAt = item.updatedAt
                    
                    if isUpdateCount {
                        group.unread_count = group.unread_count + 1
                    }
                    
                    group.lastMessage = LastMessage()
                    group.lastMessage?.comment = item.comment
                    group.lastMessage?.createdAt = item.createdAt
                    group.lastMessage?.temp_id = item.temp_id
                    group.lastMessage?.message_id = item.id
                    group.lastMessage?.is_chat_message_deleted = item.is_chat_message_deleted
                    
                    if item.attachment != nil {
                        group.lastMessage?.is_attachment = true
                    }
                }
            }
        }
    }
    
    //Handle Module Wise Chat Thread
    func handleModlueThread(list : [ChatThreadModel]) {
        
        for obj in list
        {
            if self.realm.isInWriteTransaction {
                self.realm.add(obj, update: true)
            }
            else {
                try! self.realm.write {
                    self.realm.add(obj, update: true)
                }
            }
        }
    }
    
    //Fetch ModuleThread
    func fetchModuleThread(referenceId : String) -> [ChatThreadModel] {
        
        let predicate = NSPredicate(format: "reference_id = %@",referenceId)
        let masters = realm.objects(ChatThreadModel.self).filter(predicate)
        return Array(masters)
    }
    
    func fetchModuleThread(threadId : String) -> [ChatThreadModel] {
        
        let predicate = NSPredicate(format: "id = %@",threadId)
        let masters = realm.objects(ChatThreadModel.self).filter(predicate)
        return Array(masters)
    }
    
    //Fetch Group List
    func fetchGroupList(viewType:ChatConstant.ViewType,tagId : String) -> [GroupListModel] {
        
        var pre = NSPredicate()
        if tagId.count > 0 {
            pre = NSPredicate(format: "conference_id = %@ AND tags_with_color CONTAINS %@",ApplicationData.ConferenceDetails.id ?? "",tagId)
        }
        else{
            pre = NSPredicate(format: "conference_id = %@",ApplicationData.ConferenceDetails.id ?? "")
        }
        
        let preDeleted = NSPredicate(format: "is_deleted = %@ AND isArchive = %@",NSNumber(value: false),NSNumber(value: false))
        var sortby = "updatedAt"
        if viewType == .CHAT_VIEW_TYPE_WALL{
            
            sortby = "createdAt"
        }
        
        let predicateModule = NSPredicate(format: "module != %@",NSNumber(value: AppConstants.ModuleConstant.SUPPORT))
        let masters = realm.objects(GroupListModel.self).filter(pre).filter(preDeleted).filter(predicateModule).sorted(byKeyPath: sortby, ascending: false)
        return Array(masters)
    }
    
    //Fetch Group With Id
    func fetchGroupWith(id : String) -> [GroupListModel] {
        
        let preDeleted = NSPredicate(format: "is_deleted = %@ AND isArchive = %@",NSNumber(value: false),NSNumber(value: false))
        let predicate = NSPredicate(format: "id = %@",id)
        let masters = realm.objects(GroupListModel.self).filter(predicate).filter(preDeleted).sorted(byKeyPath: "updatedAt", ascending: false)
        return Array(masters)
    }
    
    func fetchGroupWithRefrence(refrenceId : String) -> [GroupListModel] {
        
        let preDeleted = NSPredicate(format: "is_deleted = %@ AND isArchive = %@",NSNumber(value: false),NSNumber(value: false))
        let predicate = NSPredicate(format: "refIdString = %@",refrenceId)
        let masters = realm.objects(GroupListModel.self).filter(predicate).filter(preDeleted).sorted(byKeyPath: "updatedAt", ascending: false)
        return Array(masters)
    }
    
    //Fetch Group With Module
    func fetchGroupWith(module : Int) -> [GroupListModel] {
        
        let preDeleted = NSPredicate(format: "is_deleted = %@ AND isArchive = %@",NSNumber(value: false),NSNumber(value: false))
        let predicate = NSPredicate(format: "module = %@",NSNumber(value: module))
        let masters = realm.objects(GroupListModel.self).filter(predicate).filter(preDeleted).sorted(byKeyPath: "updatedAt", ascending: false)
        return Array(masters)
    }
    
    //Fetch Last Sync Date
    func fetchLastSyncDateForThread(module:Int) -> String? {
        
        let predicate = NSPredicate(format: "module = %@",NSNumber(value: module))
        let masters = realm.objects(GroupListModel.self).filter(predicate)
        let min = masters.min { (model1, model2) -> Bool in
            return DateUtilities.convertDateFromString(dateStr: model1.updatedAt ?? "") > DateUtilities.convertDateFromString(dateStr: model2.updatedAt ?? "")
        }
        
        return min?.updatedAt
    }
    
    //FetchGroupLastMessage
    func fetchLastMessages(tempId : [String]) -> [LastMessage] {
        
        let predicate = NSPredicate(format: "temp_id IN %@",tempId)
        let masters = realm.objects(LastMessage.self).filter(predicate)
        return Array(masters)
    }
    
    //Fetch Message Sync Date
    func fetchLastMessageDate(threadId : String) -> String? {
        
        let predicate = NSPredicate(format: "chat_thread_id = %@",threadId)
        let masters = realm.objects(MessageModel.self).filter(predicate)
        let min = masters.min { (model1, model2) -> Bool in
            return DateUtilities.convertDateFromString(dateStr: model1.createdAt ?? "") > DateUtilities.convertDateFromString(dateStr: model2.createdAt ?? "")
        }
        
        return min?.createdAt
    }
    
    //Fetch All Message
    func fetchMessage(threadId : String) -> [MessageModel] {
        
        let predicate = NSPredicate(format: "chat_thread_id = %@",threadId)
        let masters = realm.objects(MessageModel.self).filter(predicate).sorted(byKeyPath: "createdAt", ascending: true)
        return Array(masters)
    }
    
    func fetchMessage(tempId : [String]) -> [MessageModel]  {
        
        let predicate = NSPredicate(format: "temp_id IN %@",tempId)
        let masters = realm.objects(MessageModel.self).filter(predicate)
        return Array(masters)
    }
    
    //Fetch UnSync Message
    func fetchUnSyncMessage() -> [MessageModel]  {
        
        let predicate = NSPredicate(format: "isSync = %@ AND is_chat_message_deleted = %@",NSNumber(value: false),NSNumber(value: false))
        let masters = realm.objects(MessageModel.self).filter(predicate)
        return Array(masters)
    }
    
    //Remove Unread Count
    func removeUnreadCount(groupId : String)  {
        
        let group = self.fetchGroupWith(id: groupId)
        if group.count > 0 {
            try! self.realm.write {
                group.first?.unread_count = 0
            }
        }
    }
    
    //MARK: Like - Dislike Post
    func updateLikeStatus(model:GroupListModel){
    
        try! self.realm.write {
            
            model.likesCount = (model.isLike == ChatConstant.LikeConstant.Like ? model.likesCount - 1 : model.likesCount + 1)
            model.isLike = (model.isLike == ChatConstant.LikeConstant.Like ? ChatConstant.LikeConstant.DisLike : ChatConstant.LikeConstant.Like)
        }
    }
    
    //MARK: Comment Count
    func updateCommentCount(threadId:String){
        
        let model = self.fetchGroupWith(id: threadId).first
        let count = model?.commentsCount ?? 0
        try! self.realm.write {
            
            model?.commentsCount = count + 1
        }
    }
    
    //MARK: Comment Count
    func updateArchive(threadId:String){
        
        let model = self.fetchGroupWith(id: threadId).first
        try! self.realm.write {
            
            model?.isArchive = 1
        }
    }
    
    //MARK: Comment Count
    func updateDelete(threadId:String){
        
        let model = self.fetchGroupWith(id: threadId).first
        try! self.realm.write {
            
            model?.is_deleted = true
        }
    }
}
