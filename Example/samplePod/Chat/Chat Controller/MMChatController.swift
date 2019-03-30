//
//  MMChatController.swift
//  ConferenceAssociationApp
//
//  Created by Coruscate on 21/08/18.
//  Copyright © 2018 CS-Mac-Mini. All rights reserved.
//

import UIKit

class MMChatController: UIViewController {
    
    //==========================================
    //MARK: OutLet
    //==========================================
    @IBOutlet weak var table_view: UITableView!
    @IBOutlet weak var text_view: HPGrowingTextView!
    @IBOutlet weak var viewDelete: UIView!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var containerViewHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var bottomConstant: NSLayoutConstraint!
    @IBOutlet weak var btnScroll: UIButton!
    //Thread Detail
    @IBOutlet weak var imgGroup: UIImageView!
    @IBOutlet weak var lblGroupName: UILabel!
    @IBOutlet weak var lblCreatedBy: UILabel!
    @IBOutlet weak var topGropName: NSLayoutConstraint!
    
    @IBOutlet weak var btnInfo: UIButton!
    @IBOutlet weak var widthBtnInfo: NSLayoutConstraint!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var widthBtnEdit: NSLayoutConstraint!
    @IBOutlet weak var btnCall: UIButton!
    @IBOutlet weak var widthBtnCall: NSLayoutConstraint!
    @IBOutlet weak var btnAttachmentWidth: NSLayoutConstraint!
    @IBOutlet weak var btnAttachment: UIButton!
    @IBOutlet weak var vwCustomBar: UIView!
    @IBOutlet weak var tblTopSafeArea: NSLayoutConstraint!
    @IBOutlet weak var tblTopSuperView: NSLayoutConstraint!
    
    //==========================================
    //MARK: Variable
    //==========================================
    var threadId : String?
    var referenceId : String?
    var module : Int?
    var messageList = [MessageModel]()
    var isDeleteActive = false
    var isSelfieCorner = false
    var assignThreadRequest = ChatThreadModel()
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialConfig()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        IQKeyboardManager.shared().isEnabled = false
        
        if isSelfieCorner{
            
            Utilities.setNavigationBar(controller: self, isHidden: false, title: "Comments")
        }else{
            
            Utilities.setNavigationBar(controller: self, isHidden: true, title: "")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        IQKeyboardManager.shared().isEnabled = true
    }
    
    //MARK: Private Mehods
    func initialConfig() {
        
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        btnScroll.isHidden = true
        self.view.backgroundColor = ChatConstant.Color.BackGround
        table_view.separatorStyle = .none
        table_view.estimatedRowHeight = 100
        table_view.rowHeight = UITableViewAutomaticDimension
        registerCells()
        imgGroup.setCornerRadius(radius: imgGroup.frame.size.width/2.0)
        hideCreatedByAndEditInfo()
        
        if threadId == nil {
            
            DispatchQueue.main.async {
                
                self.assignChatThread()
            }
            
        }else{
            
             self.initData()
        }
        
    }
    
    private func assignChatThread(){
        
        self.viewContainer.isHidden = true
        self.table_view.loadNoDataFoundView(withMessage: "Not Connected To Server")
        
        //Assign Thread
        ChatManager.sharedInstance.assignThread(module: self.module ?? assignThreadRequest.module, referenceId: assignThreadRequest.reference_id ?? "", type: assignThreadRequest.type, name: assignThreadRequest.name, image: assignThreadRequest.image) { thread in
            
            self.table_view.removeLoadAPIFailedView()
            
            try! ChatManager.sharedInstance.realm.write {
                thread.name = self.assignThreadRequest.name
                thread.image = self.assignThreadRequest.image
                thread.type = self.assignThreadRequest.type
            }
            
            if let vc = UIViewController.current() as? MMChatController {
                
                if vc.referenceId == nil || vc.referenceId == thread.reference_id{
                    
                    self.threadId = thread.id
                    self.referenceId = thread.reference_id
                    self.initData()
                }else{
                    
                    return
                }
                
            }else{
                
                //do nothing
            }
            
        }
    }
    
    private func initData(){
        
        ChatManager.sharedInstance.removeUnreadCount(groupId: self.threadId ?? "")
        self.setMessageTextView()
        setGroupDetail()
        widthBtnInfo.constant = 25
        btnInfo.isHidden = false
        
        if isSelfieCorner {
            //selfie corner module
            btnAttachment.isHidden = true
            btnAttachmentWidth.constant = 8
            text_view.placeholder = "Post a comment..."
            vwCustomBar.isHidden = true
            tblTopSafeArea.constant = 0
            tblTopSuperView.constant = 0
            
        }else{
            
            btnAttachment.isHidden = false
            btnAttachmentWidth.constant = 44
            text_view.placeholder = "Message"
            vwCustomBar.isHidden = false
            tblTopSafeArea.constant = 50
            tblTopSuperView.constant = 70
        }
        //Sync Message
        self.loadAllMessage()
        self.syncMessage(isTime: false)
        self.messageReceived()
        self.messageStatusUpdate()
        self.deletedMessage()
    }
    
    //Set Group Detail
    func setGroupDetail() {
        
        if module == AppConstants.ModuleConstant.CHAT_GROUP {
            
            //Group Detail
            topGropName.constant = 4
            let threads = ChatManager.sharedInstance.fetchGroupWith(id : threadId ?? "")
            if threads.count == 0 {
                ChatManager.sharedInstance.syncThread(module: module ?? AppConstants.ModuleConstant.CHAT_GROUP, success: {
                    self.setGroupDetail()
                })
            }
            
            
            lblGroupName.text = threads.first?.title
            if let createdBy = threads.first?.referenceId?.author?.name,createdBy.count > 0 {
                lblCreatedBy.text = "Created by : \(threads.first?.referenceId?.author?.name ?? "")"
            }
            else{
                lblCreatedBy.text = ""
            }
            
            
            if let str = threads.first?.referenceId?.attachments.first?.path?.stringByAddingPercentEncodingForURL(),let url = URL(string: "\(ChatConstant.serverURL)\(str)") {
                imgGroup.setImageForURL(url: url, placeHolder: UIImage(named: "app_icon"))
            }
            
            if threads.first?.referenceId?.author?.cell == ApplicationData.user.cell && AppConfiguration.shared.isCreateCaseEnable {
                //Edit Only Admin
                widthBtnEdit.constant = 25
                btnEdit.isHidden = false
            }
            else {
                widthBtnEdit.constant = 0
                btnEdit.isHidden = true
            }
            
            widthBtnCall.constant = 0
            btnCall.isHidden = true
        }
        else if module == AppConstants.ModuleConstant.SUPPORT {
            
            if ApplicationData.user.type == AppConstants.UserType.SUB_ADMIN {
                
                //Sub Admin Support Chat
                let threads = ChatManager.sharedInstance.fetchGroupWith(id : threadId ?? "")
                if threads.count == 0 {
                    ChatManager.sharedInstance.syncThread(module: module ?? AppConstants.ModuleConstant.CHAT_GROUP, success: {
                        self.setGroupDetail()
                    })
                }
                
                lblGroupName.text = threads.first?.title
                if let str = threads.first?.image?.stringByAddingPercentEncodingForURL(),let url = URL(string: "\(ChatConstant.serverURL)\(str)") {
                    imgGroup.setImageForURL(url: url, placeHolder:  UIImage(named: "app_icon"))
                }
                
                hideCreatedByAndEditInfo()
                widthBtnCall.constant = 25
                btnCall.isHidden = false
                btnCall.setTitle(threads.first?.user_id?.cell, for: .normal)
                
            }
            else{
                
                //End User Support
               lblGroupName.text = SyncManager.sharedInstance.fetchMenuByCode(code: AppConstants.ModuleCodeConstant.SUPPORT).first?.name
               imgGroup.image = #imageLiteral(resourceName: "ic_support")
               hideCreatedByAndEditInfo()
            }
        }
        else {
            
            //All Other Chat
            let threads = ChatManager.sharedInstance.fetchModuleThread(referenceId: referenceId ?? "")
            lblGroupName.text = threads.first?.name
            
            if let str = threads.first?.image?.stringByAddingPercentEncodingForURL(), let url = URL(string: "\(AppConstants.serverURL)\(str)") {
                imgGroup.setImageForURL(url: url, placeHolder: UIImage(named: "app_icon"))
            }
            
            hideCreatedByAndEditInfo()
        }
        
    }
    
    func hideCreatedByAndEditInfo() {
        
        lblCreatedBy.text = ""
        topGropName.constant = 14
        widthBtnEdit.constant = 0
        btnEdit.isHidden = true
        widthBtnInfo.constant = 0
        btnInfo.isHidden = true
        widthBtnCall.constant = 0
        btnCall.isHidden = true
    }
    
    func registerCells() {
        
        self.table_view.register(UINib(nibName: "MMChatLogCell", bundle: nil), forCellReuseIdentifier: "MMChatLogCell")
        self.table_view.register(UINib(nibName: "MMChatInCommingCell", bundle: nil), forCellReuseIdentifier: "MMChatInCommingCell")
        self.table_view.register(UINib(nibName: "MMChatOutGoingCell", bundle: nil), forCellReuseIdentifier: "MMChatOutGoingCell")
        self.table_view.register(UINib(nibName: "MMChatAttachmentInCommingCell", bundle: nil), forCellReuseIdentifier: "MMChatAttachmentInCommingCell")
        self.table_view.register(UINib(nibName: "MMChatOutAttachmentOutGoingCell", bundle: nil), forCellReuseIdentifier: "MMChatOutAttachmentOutGoingCell")
        self.table_view.register(UINib(nibName: "SelfieCornerCommentCell", bundle: nil), forCellReuseIdentifier: "SelfieCornerCommentCell")
        
    }
    
    //Text View IntialConfig
    func setMessageTextView() {
        
        self.viewContainer.isHidden = false
        self.text_view.layer.cornerRadius = 3.0
        self.text_view.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.4).cgColor
        self.text_view.layer.borderWidth = 0.5
        self.text_view.layer.masksToBounds = true
        self.text_view.isScrollable = true
        self.text_view.contentInset = UIEdgeInsetsMake(3, 5, 5, 3)
        self.text_view.minNumberOfLines = 1
        self.text_view.maxHeight = 100
        self.text_view.font = UIFont.systemFont(ofSize: 15)
        self.text_view.placeholder = "Message"
        self.text_view.delegate = self
    }
    
    //MARK: IBAction
    @IBAction func btnSend_Click(_ sender: UIButton) {
        
        if let text = text_view.text,text.count > 0,text.trimmingCharacters(in: CharacterSet.whitespaces).count > 0 {
            self.sendMessage(message: text_view.text, serverPath: "", type: 0)
            self.text_view.text = ""
        }
    }
    
    //Attachment
    @IBAction func btnPlus_click(_ sender: UIButton) {
        self.openDocumentPicker()
    }
    
    //Back
    @IBAction func btnBack_Click(_ sender: UIButton) {
        
        if let arr = UIViewController.current().navigationController?.viewControllers{
            
            for vc in arr.reversed(){
                
                if vc is MMChatController{
                    
                }else{
                    
                    UIViewController.current().navigationController?.popToViewController(vc, animated: true)
                    return
                }
            }
        }
        
        ApplicationData.gotoDashboard()
    }
    
    //Edit Thread
    @IBAction func btnEdit_Click(_ sender: UIButton) {
        
        let vc = CreateCaseVC(nibName: "CreateCaseVC", bundle: nil)
        vc.threadId = threadId
        vc.referenceId = referenceId
        vc.groupCreateUpdate = {
            ChatManager.sharedInstance.syncThread(module: AppConstants.ModuleConstant.CHAT_GROUP) {
                self.setGroupDetail()
            }
        }
        UIViewController.current().navigationController?.pushViewController(vc, animated: true)
    }
    
    //Thread Info
    @IBAction func btnInfo_Click(_ sender: UIButton) {
        
        dismissKeyboard()
        let vc = GroupDetailVC(nibName: "GroupDetailVC", bundle: nil)
        vc.groupId = threadId
        UIViewController.current().navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnCall_Click(_ sender: UIButton) {
        dismissKeyboard()
        Utilities.call(phoneNumber: sender.titleLabel?.text?.removeWhiteSpaces() ?? "")
    }
    
    
    @IBAction func btnCancel_Click(_ sender: UIButton) {
        
        hideDeleteView()
    }
    
    @IBAction func btnDelete_Click(_ sender: UIButton) {
        
        Utilities.showAlertWithTwoButtonAction(title: AppConstants.AppName, message: StringConstants.CreateCase.KDelete, attributedMessage: nil, buttonTitle1: StringConstants.kCancel, buttonTitle2: StringConstants.kDelete, onButton1Click: {
            
        }) {
            
            self.deleteMessage()
        }
    }
    
    @IBAction func btnScroll_Click(_ sender: UIButton) {
        scrollToBottomAnimated()
    }
    
}

//==========================================
//MARK: UITable DataSource & Delegate
//==========================================

extension MMChatController : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messageList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = messageList[indexPath.row]
        
        if indexPath.row < (messageList.count - 16) {
            btnScroll.isHidden = false
        }else{
            btnScroll.isHidden = true
        }
        
        if isSelfieCorner{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelfieCornerCommentCell") as! SelfieCornerCommentCell
            cell.setCellData(message: model)
            return cell
            
        }else{
            
            let identifier : String = self.CellIdentifier(message: model)
            
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? MMChatCell
            cell?.selectionStyle = .none
            cell?.setCellData(message: model)
            cell?.handleDelete(message: model, isActiveselected: isDeleteActive)
            
            if model.isIncoming == false {
                
                let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(MMChatController.longPress(_:)))
                longPressRecognizer.minimumPressDuration = 0.5
                cell?.addGestureRecognizer(longPressRecognizer)
            }
            
            return cell!
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let model = messageList[indexPath.row]
        
        if !isSelfieCorner{
           
            if isDeleteActive {
                
                if model.isIncoming == false {
                    model.isSelected = !model.isSelected
                    table_view.reloadRows(at: [indexPath], with: .none)
                }
                
            }
            else if model.attachment != nil,model.attachment?.isDownloaded() == true  {
                model.attachment?.open()
            }
        }
       
    }
    
    //Cell Identifier
    func CellIdentifier(message : MessageModel) -> String {
        
        if message.type == ChatConstant.MessageType.Log {
            return "MMChatLogCell"
        }
        
        if message.isIncoming {
            
            if message.is_chat_message_deleted {
                return "MMChatInCommingCell"
            }
            else if message.attachment != nil {
                return "MMChatAttachmentInCommingCell"
            }
            else {
                return "MMChatInCommingCell"
            }
        }
        else {
            
            if message.is_chat_message_deleted {
               return "MMChatOutGoingCell"
            }
            else if message.attachment != nil {
                return "MMChatOutAttachmentOutGoingCell"
            }
            else {
                return "MMChatOutGoingCell"
            }
        }
    }
}

//==========================================
//MARK: DataBase & Sync
//==========================================
extension MMChatController {
    
    //Delete Message
    func deleteMessage() {
        
        let selected = messageList.filter { (model) -> Bool in
            return model.isSelected
        }
        
        let arrIds = selected.map{$0.id ?? ""}
        if arrIds.count > 0 {
            
            hideDeleteView()
            ChatManager.sharedInstance.messageDelete(ids: arrIds)
        }
        else{
            
            Utilities.showAlertView(title: AppConstants.AppName, message: StringConstants.CreateCase.KSelectMessage)
        }
    }
    
    //Deleted Message
    func deletedMessage() {
        
        ChatManager.sharedInstance.messageDeleteWithcallback { (messages) in
           self.insertMessage(list: messages)
        }
    }
    
    //Update Message Status
    func messageStatusUpdate() {
        
        ChatManager.sharedInstance.messageStatusUpdate(threadId: threadId ?? "", status: ChatConstant.MessageStatus.Read)
        
        ChatManager.sharedInstance.messageStatusUpdateWithcallback { (messages) in
            self.insertMessage(list: messages)
        }
    }
    
    //Sync Message
    func syncMessage(isTime : Bool) {
        
        if ChatManager.sharedInstance.isConnect() {

            ChatManager.sharedInstance.syncMessage(threadId: self.threadId!, isTime: isTime) {
                self.loadAllMessage()
            }
        }
        else {

            ChatManager.sharedInstance.connect {
                ChatManager.sharedInstance.syncMessage(threadId: self.threadId!, isTime: isTime) {
                    self.loadAllMessage()
                }
            }
        }
    }
    
    //Message Received
    func messageReceived() {
        
        ChatManager.sharedInstance.messageReceivedWithcallback { (messages) in
            self.insertMessage(list: messages)
        }
    }
    
    //Load All Message
    func loadAllMessage() {
        
        messageList.removeAll()
        if let id = self.threadId {
           let list = ChatManager.sharedInstance.fetchMessage(threadId: id)
            self.messageList = list
        }
        else{
            print("<-------------- Thread Id Not Found ------------->")
        }
        
        self.table_view.reloadData()
        self.scrollToBottomAnimated()
        self.checkNoDataView()
    }
    
    func checkNoDataView(){
        
        if messageList.count == 0{
            
            if self.isSelfieCorner{
                
                self.table_view.loadNoDataFoundView(withMessage: "No Comments Found")
            }else{
                
                self.table_view.loadNoDataFoundView(withMessage: "No Message Found")
            }
        }else{
            
            self.table_view.removeLoadAPIFailedView()
        }
    }

    
    //Send Message
    func sendMessage(message : String,serverPath : String,type : Int) {
        
        var request = [String : Any]()
        
        let text = message
        if text.trimmingCharacters(in: CharacterSet.whitespaces).count > 0 {
            request["comment"] = message
        }
        request["_temp_id"] = UUID().uuidString
        request["chat_thread_id"] = self.threadId
        request["post_by"] = ApplicationData.user.id
        request["type"] = ChatConstant.MessageType.Chat
        request["reference_id"] = referenceId
        request["module"] = module
        request["conference_id"] = ApplicationData.ConferenceDetails.id

        if serverPath.count > 0 {
            
            var attachment = [String : Any]()
            attachment["path"] = serverPath
            attachment["type"] = ChatConstant.AttachmentType.Image
            request["attachment"] = attachment
        }
        
        ChatManager.sharedInstance.sendMessage(request: request)
        self.text_view.text = ""
        self.createSendMessageModel(request: request)
    }
    
    //Create send Message Model & Insert Send Message
    func createSendMessageModel(request : [String : Any])  {
        
        //Create Model
        let model = MessageModel()
        model.isIncoming = false
        model.isSync = false
        model.comment = request["comment"] as? String
        model.chat_thread_id = self.threadId
        model.temp_id = request["_temp_id"] as? String
        model.type = request["type"] as? Int ?? ChatConstant.MessageType.Chat
        model.status = ChatConstant.MessageStatus.Sending
        
        //Post By
        model.postBy = PostByModel()
        model.postBy?.id = ApplicationData.user.id
        model.postBy?.image = ApplicationData.user.image
        
        if let attachment = request["attachment"] as? [String : Any] {
            model.attachment = ChatAttachmentModel(JSON: attachment)
        }
        
        model.createdAt = DateUtilities.getIsoFormateCurrentDate()
        model.updatedAt = DateUtilities.getIsoFormateCurrentDate()
        
        //Insert Send Message In DB
        ChatManager.sharedInstance.insertMessage(list: [model])
        self.insertMessageToTheBottomAnimatted(model: model)
    }
    
}

//==========================================
//MARK: UIScrollView Delegate
//==========================================

extension MMChatController : UIScrollViewDelegate {
    
    //Insert Update Message
    func insertMessage(list : [MessageModel]) {
        
        for item in list {
            
            if item.chat_thread_id == self.threadId {
                
                if self.indexPathForMessage(model: item) != nil {
                    self.updateMessage(model: item)
                }
                else{
                    self.insertMessageToTheBottomAnimatted(model: item)
                }
            }
        }
    }
    
    //Update Message
    func updateMessage(model : MessageModel)  {
        
        if let indexpath = self.indexPathForMessage(model: model) {
            messageList[indexpath.row] = model
            table_view.reloadRows(at: [indexpath], with: .none)
        }
    }
    
    //InsertMessage
    func insertMessageToTheBottomAnimatted(model : MessageModel) {
        
        messageList.append(model)
        table_view.beginUpdates()
        table_view.insertRows(at: [IndexPath(row: messageList.count-1, section: 0)], with: .automatic)
        table_view.endUpdates()
        self.scrollToBottomAnimated()
        self.checkNoDataView()
    }
    
    //Get Message IndexPath
    func indexPathForMessage(model : MessageModel) -> IndexPath? {
        
        let index = messageList.index { (tempModel) -> Bool in
            return model.temp_id == tempModel.temp_id
        }
        
        if let newIndex = index {
            return IndexPath(row: newIndex, section: 0)
        }
        
        return nil
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func scrollToTopAnimated() {
        if messageList.count > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.table_view.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .bottom, animated: false)
            }
        }
    }
    
    func scrollToBottomAnimated() {
        if messageList.count > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.btnScroll.isHidden = true
                self.table_view.scrollToRow(at: IndexPath.init(row: self.messageList.count - 1, section: 0), at: .bottom, animated: false)
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.dismissKeyboard()
    }
}

//==========================================
//MARK: Handle Docuemnt
//==========================================

extension MMChatController {
    
    func openDocumentPicker() {
        
        DocumentPickerHelper.sharedInstance.openDocumentPickerWithVideo()
        DocumentPickerHelper.sharedInstance.isDocumentGet = { (image, getDocument) in
            
            var header = ApplicationData.sharedInstance.authorizationHeaders
            header["destination"] = "chat"
            
            UploadManager.sharedInstance.uploadFile(AppConstants.serverURL, command: AppConstants.URL.UploadFile, image: image, fileURL: getDocument.fileUrl, folderKeyvalue: "", uploadParamKey:"file", params: nil , headers: header, success: { (response, message) in
                
                if let respnseDict = response as? [String:Any] {
                    if let files = respnseDict["files"] as? [[String:Any]],files.count > 0 {
                        
                        if let absolutePath = files[0]["absolutePath"] as? String {
                            if image != nil {
                                self.saveImage(image: image!, name: "\(absolutePath.fileName()).\(absolutePath.fileExtension())")
                            }
                            if let fileUrl = getDocument.fileUrl{
                                self.saveVideo(fileUrl: fileUrl, name: "\(absolutePath.fileName()).\(absolutePath.fileExtension())")
                            }
                            self.sendMessage(message: self.text_view.text, serverPath: absolutePath, type: (image != nil) ? ChatConstant.AttachmentType.Image : ChatConstant.AttachmentType.Document)
                        }
                    }
                }
                
            }) { (failureMessage) in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    Utilities.showAlertView(title: AppConstants.AppName, message: failureMessage)
                })
            }
        }
    }
    
    //Save Uploaded Image
    func saveImage(image : UIImage,name : String) {
        
        do {
            try FileManager.default.createDirectory(atPath: "\(ChatAttachmentModel.documentDirectory())\(StringConstants.DownloadFolderName)/", withIntermediateDirectories: true, attributes: nil)
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
        
        let imageData = UIImagePNGRepresentation(image)
        let filePath = "\(ChatAttachmentModel.documentDirectory())\(StringConstants.DownloadFolderName)/\(name)"
        FileManager.default.createFile(atPath: filePath, contents: imageData, attributes: nil)
    }
    
    func saveVideo(fileUrl : URL,name : String) {
        
        do {
            try FileManager.default.createDirectory(atPath: "\(ChatAttachmentModel.documentDirectory())\(StringConstants.DownloadFolderName)/", withIntermediateDirectories: true, attributes: nil)
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
        
        do {
            
            let filePath = "\(ChatAttachmentModel.documentDirectory())\(StringConstants.DownloadFolderName)/\(name)"
            let myVideoVarData = try Data(contentsOf: fileUrl)
            FileManager.default.createFile(atPath: filePath, contents: myVideoVarData, attributes: nil)
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
    }
}

//==========================================
//MARK: HPGrowingTextView Delegate
//==========================================

extension MMChatController : HPGrowingTextViewDelegate {
    
    func growingTextView(_ growingTextView: HPGrowingTextView!, willChangeHeight height: Float) {
        
        containerViewHeightConstant.constant = CGFloat(height + 16)
        self.view.layoutIfNeeded()
    }
    
}

//MARK: Keybopard Delegate

extension MMChatController {
    
    @objc func keyboardWillShow(sender: NSNotification) {
        
        guard let keyboardFrame = sender.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        let keyboardHeight: CGFloat
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            let bottomPadding = window?.safeAreaInsets.bottom
            
            keyboardHeight = keyboardFrame.cgRectValue.height - (bottomPadding ?? 0.0)
        } else {
            keyboardHeight = keyboardFrame.cgRectValue.height
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.bottomConstant.constant = keyboardHeight
            self.view.layoutIfNeeded()
            self.scrollToBottomAnimated()
        })
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        
        UIView.animate(withDuration: 0.3) {
            
            self.bottomConstant.constant = 0
            self.view.layoutIfNeeded()
            self.scrollToBottomAnimated()
        }
    }
    
    @objc func longPress(_ sender: UILongPressGestureRecognizer) {
        
        dismissKeyboard()
        if sender.state == .began {
            
            let tapLocation = sender.location(in: table_view)
            let indexpath = table_view.indexPathForRow(at: tapLocation)!
            
            let model = messageList[indexpath.row]
            if model.isIncoming == false {
                model.isSelected = true
            }
            
            self.text_view.text = ""
            isDeleteActive = true
            viewDelete.isHidden = false
            viewContainer.isHidden = true
            table_view.reloadData()
        }
    }
    
    func hideDeleteView() {
        
        for item in messageList {
            item.isSelected = false
        }
        
        isDeleteActive = false
        viewDelete.isHidden = true
        viewContainer.isHidden = false
        table_view.reloadData()
    }
}
