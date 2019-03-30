//
//  CreateGroupHelper.swift
//  ConferenceAssociationApp
//
//  Created by CS-Mac-Mini on 31/12/18.
//  Copyright © 2018 CS-Mac-Mini. All rights reserved.
//

import UIKit

class CreateGroupHelper: NSObject {

    static let shared = CreateGroupHelper()
   
    //Create Update Group
    func createUpdateGroup(viewType:ChatConstant.ViewType,arrData:[CellModel],groupModel:GroupListModel?,tagId:String?,referenceId:String?,success: @escaping (() -> ())) {
        
//        var name = ""
//        var imageName = ""
        var request = [String : Any]()
        for model in arrData {
            
            if model.cellType == .CreateCaseTitleCell {
                request["name"] = model.userText
               // name = model.userText ?? ""
            }
            else if model.cellType == .CreateCaseDescCell {
                request["desc"] = model.userText
            }
            else if model.cellType == .CreateCaseHistoryCell {
                request["patient_history"] = model.userText
            }
            else if model.cellType == .CreateCaseDiagnosisCell {
                request["conclusion"] = model.userText
            }
            else if model.cellType == .CreateCaseTreatmentCell {
                request["treatment_and_followup"] = model.userText
            }
            else if model.cellType == .CreateCaseLinkCell{
                
                var arrLinks = [[String:Any]]()
                for mm1 in model.dataArr{
                    let mm = mm1 as? CellModel ?? CellModel()
                    var dict = Parameters()
                    dict["url"] = mm.userText
                    arrLinks.append(dict)
                }
                
                request["links"] = arrLinks
            }
            else if model.cellType == .CreateCaseMediaCell {
                
                var arrAttachment = [[String : Any]]()
                var index = 0
                for aModel in model.dataArr  {
                    
                    let atModel = aModel as? UploadDocumentsModel
                    var aDic = [String : Any]()
                    if index == 0 {
                        aDic["isPrimary"] = true
                      //  imageName = atModel?.fileServerUrl ?? ""
                    }
                    aDic["path"] = atModel?.fileServerUrl
                    aDic["type"] = ChatConstant.AttachmentType.Image
                    aDic["description"] = atModel?.fileDesc
                    aDic["date"] = atModel?.fileDate
                    arrAttachment.append(aDic)
                    index = index + 1
                }
                
                request["attachments"] = arrAttachment
            }
        }
        
        if groupModel != nil {
            
            //use in Edit Time
            if let tagStr = groupModel?.tags_with_color,tagStr.count > 0 {
                request["tags_with_color"] = Utilities.objectFromJsonString(str: tagStr)
            }
        }
        else{
            
            var tags_with_colorArr = [[String : Any]]()
            var tagDic = [String : Any]()
            tagDic["id"] = tagId
            tags_with_colorArr.append(tagDic)
            request["tags_with_color"] = tags_with_colorArr
        }
        
        var author          = [String : Any]()
        author["name"]      = "\(ApplicationData.user.first_name ?? "") \(ApplicationData.user.last_name ?? "")"
        author["cell"]      = ApplicationData.user.cell
        author["image"]     = ApplicationData.user.image
        request["author"]   = author
        
        request["viewModule"] = viewType.rawValue
        
        if viewType == .CHAT_VIEW_TYPE_WALL{
            
            var arrName = [String]()
            arrName.append("post")
            if let fname = ApplicationData.user.first_name,fname.count > 0{
                
                arrName.append(fname)
            }
            if let lname = ApplicationData.user.last_name,lname.count > 0{
                
                arrName.append(lname)
            }
            arrName.append("\(Date().toMillis()!)")
            request["name"] = arrName.joined(separator: "_").uppercased()
        }
        
        if let id = referenceId,id.count > 0 {
            
            //Update Group
            NetworkClient.sharedInstance.showIndicator("", stopAfter: 0)
            NetworkClient.sharedInstance.request(AppConstants.serverURL, command: "\(AppConstants.URL.UpdateGroup)\(id)", method: .put, parameters: request, headers: ApplicationData.sharedInstance.authorizationHeaders, success: { (response, message) in
                
                //save Data
                success()
                
            }) { (failureMessage, failureCode) in
                
                Utilities.showAlertView(title: AppConstants.AppName, message: failureMessage)
            }
        }
        else {
            
            //Create Group
            NetworkClient.sharedInstance.showIndicator("", stopAfter: 0)
            NetworkClient.sharedInstance.request(AppConstants.serverURL, command: AppConstants.URL.CreateGroup, method: .post, parameters: request, headers: ApplicationData.sharedInstance.authorizationHeaders, success: { (response, message) in
                
//                //save Data
//                if let dict = response as? [String:Any]{
//                    if let id  = dict["id"] as? String{
//                        
//                        ChatManager.sharedInstance.assignThread(module: AppConstants.ModuleConstant.CHAT_GROUP, referenceId: id, type: ChatConstant.ChatType.OneToMany, name: name, image: imageName, success: { (model) in
//                            
//                            
//                        })
//                    }
//                }
                
                success()
                
            }) { (failureMessage, failureCode) in
                
                Utilities.showAlertView(title: AppConstants.AppName, message: failureMessage)
            }
        }
    }
    
    //Upload Image
    func uploadAttachment(model : UploadDocumentsModel,success:@escaping ((_ model : UploadDocumentsModel)->Void)) {
        
        var header = ApplicationData.sharedInstance.authorizationHeaders
        header["destination"] = "group"
        
        UploadManager.sharedInstance.uploadFile(AppConstants.serverURL, command: AppConstants.URL.UploadFile, image: model.image!, fileURL: nil, folderKeyvalue: "", uploadParamKey:"file", params: nil , headers: header, success: { (response, message) in
            
            if let respnseDict = response as? [String:Any] {
                if let files = respnseDict["files"] as? [[String:Any]] {
                    
                    if let absolutePath = files[0]["absolutePath"] as? String {
                        model.fileServerUrl = absolutePath
                        
                        success(model)
                    }
                }
            }
            
        }) { (failureMessage) in
            
            Utilities.showAlertView(title: AppConstants.AppName, message: failureMessage)
        }
    }
}
