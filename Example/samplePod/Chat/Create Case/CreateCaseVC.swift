//
//  CreateCaseVC.swift
//  ConferenceAssociationApp
//
//  Created by Coruscate on 22/11/18.
//  Copyright © 2018 CS-Mac-Mini. All rights reserved.
//

import UIKit

class CreateCaseVC: UIViewController {
    
    //MARK: OutLet
    @IBOutlet weak var table_view: UITableView!
    @IBOutlet weak var viewCemara: UIView!
    
    //MARK: Variables
    var arrFields = [CellModel]()
    var groupCreateUpdate : (() -> ())?
    var threadId : String?
    var referenceId : String?
    var tagId : String?
    var groupModel : GroupListModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        initialConfig()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        Utilities.setNavigationBar(controller: self, isHidden: false, title: "")
    }
    
    //MARK: Private Methods
    func initialConfig() {
        
        addbarButton()
        viewCemara.layer.cornerRadius = viewCemara.frame.size.height/2
        viewCemara.layer.masksToBounds = true
        table_view.separatorStyle = .none
        table_view.register(UINib.init(nibName: "CreateCaseTitleCell", bundle: nil), forCellReuseIdentifier: "CreateCaseTitleCell")
        table_view.register(UINib.init(nibName: "CreateCaseTextViewCell", bundle: nil), forCellReuseIdentifier: "CreateCaseTextViewCell")
        table_view.register(UINib.init(nibName: "CreateCaseKeywordCell", bundle: nil), forCellReuseIdentifier: "CreateCaseKeywordCell")
        table_view.register(UINib.init(nibName: "CreateCaseMediaCell", bundle: nil), forCellReuseIdentifier: "CreateCaseMediaCell")
         table_view.register(UINib.init(nibName: "GroupLinkMainCell", bundle: nil), forCellReuseIdentifier: "GroupLinkMainCell")
        
        if let id = threadId,id.count > 0 {
            groupModel = ChatManager.sharedInstance.fetchGroupWith(id: id).first
        }
        
        prepareDataSource()
    }

    //PrepareDatasource
    func prepareDataSource() {
        
        //Title
        arrFields.append(Utilities.getModel(type: .CreateCaseTitleCell, image: UIImage(), text: groupModel?.title ?? "", placeholder: "Title*", obj: nil))
        
        //Description
        arrFields.append(Utilities.getModel(type: .CreateCaseDescCell, image: UIImage(), text: groupModel?.referenceId?.descriptionStr ?? "", placeholder: "Description", obj: nil))
        
        //History
        arrFields.append(Utilities.getModel(type: .CreateCaseHistoryCell, image: UIImage(), text: groupModel?.referenceId?.patient_history ?? "", placeholder: "History", obj: nil))
        
        //Diagnosis
        arrFields.append(Utilities.getModel(type: .CreateCaseDiagnosisCell, image: UIImage(), text: groupModel?.referenceId?.conclusion ?? "", placeholder: "Diagnosis", obj: nil))
        
        //Treatment
        arrFields.append(Utilities.getModel(type: .CreateCaseTreatmentCell, image: UIImage(), text: groupModel?.referenceId?.treatment_and_followup ?? "", placeholder: "Treatment", obj: nil))
        
//        //Search Keyword
//        arrFields.append(Utilities.getModel(type: .CreateCaseSearchKeywordsCell, image: UIImage(), text: "", placeholder: "Search keywords", obj: nil))
        
        //Links
        var arrLinks = [CellModel]()
        if let link = groupModel?.referenceId?.links, let arrObj = Utilities.objectFromJsonString(str: link) as? [[String:Any]]{
            
            for dict in arrObj{
                
                if let url = dict["url"] as? String{
                    
                    let model = CellModel()
                    model.userText = url
                    arrLinks.append(model)
                }
            }
        }
        
        let mmLinks = CellModel()
        mmLinks.cellType = .CreateCaseLinkCell
        mmLinks.dataArr = arrLinks
        arrFields.append(mmLinks)
        
        //Media
        var mediaDataArr = [Any]()
        if let media = groupModel?.referenceId?.attachments {
            
            for item in media {
                
                let model = UploadDocumentsModel()
                model.fileDate = item.date
                model.fileDesc = item.descriptionStr
                model.fileServerUrl = item.path
                mediaDataArr.append(model)
            }
        }
        
        arrFields.append(Utilities.getModel(placeholder: "Media", placeholder1: nil, placeholder2: nil, userText: nil, userText1: nil, userText2: nil, type: .CreateCaseMediaCell, imageName: nil, keyboardType: nil, isSelected: false, requestKey: nil, errorMessage: nil, cellObj: nil, value: 0, dataArr: mediaDataArr))
    }
    
    //Add Barbutton
    func addbarButton() {
        
        let btnDone = UIButton(frame : CGRect(x: 0, y: 0, width: 80, height: 22))
        
        if let id = threadId,id.count > 0 {
            btnDone.setTitle("Update", for: .normal)
        }
        else{
            btnDone.setTitle("Create", for: .normal)
        }
        
        btnDone.addTarget(self, action: #selector(btnCreateUpdate_Click), for: .touchUpInside)
        let done = UIBarButtonItem(customView: btnDone)
        done.applyNavBarConstraints(width: 80, height: 30)
        self.navigationItem.setRightBarButtonItems([done], animated: true)
    }
    
    //MARK: IBAction
    @IBAction func btnCamera_Click(_ sender: UIButton) {
        
        DocumentPickerHelper.sharedInstance.openMultipleImagePicker()
        DocumentPickerHelper.sharedInstance.isMultipleSelect = { arrModels in
            
            let vc = ImagecropVC(nibName: "ImagecropVC", bundle: nil)
            vc.arrAttachments = arrModels
            vc.isAllowEdit = true
            vc.documentUpdate = { arrDocument in
               
                self.handleDocument(arrDocument: arrDocument)

            }
            UIViewController.current().navigationController?.pushViewController(vc, animated: true)

        }
       
    }
    
    @IBAction func btnCreateUpdate_Click(_ sender: UIButton) {
        
        if isValidGroup() {
            
            CreateGroupHelper.shared.createUpdateGroup(viewType: .CHAT_VIEW_TYPE_GROUP, arrData: self.arrFields, groupModel: self.groupModel, tagId: self.tagId, referenceId: self.referenceId) {
                
                self.groupCreateUpdate?()
                UIViewController.current().navigationController?.popViewController(animated: true)
            }
        }
    }
}

//MARK: TableView Delegates & DataSource

extension CreateCaseVC : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrFields.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = arrFields[indexPath.row]
        
        if model.cellType == .CreateCaseTitleCell {
            
            //Title cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "CreateCaseTitleCell") as! CreateCaseTitleCell
            cell.setCellData(model: model)
            return cell
        }
        else if model.cellType == .CreateCaseDescCell || model.cellType == .CreateCaseHistoryCell || model.cellType == .CreateCaseDiagnosisCell || model.cellType == .CreateCaseTreatmentCell {
            
            //TextView cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "CreateCaseTextViewCell") as! CreateCaseTextViewCell
            cell.setCellData(model: model)
            return cell
        }
        else if model.cellType == .CreateCaseSearchKeywordsCell {
            
            //Search Keyword cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "CreateCaseKeywordCell") as! CreateCaseKeywordCell
            cell.setCellData(model: model)
            return cell
        }
        else if model.cellType == .CreateCaseMediaCell {
            
            //Media cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "CreateCaseMediaCell") as! CreateCaseMediaCell
            cell.setCellData(model: model, isAllowDelete: true)
            cell.deletedIndex = { index in
                self.deleteImageWithIndex(index: index)
            }
            return cell
        }
        else if model.cellType == .CreateCaseLinkCell {
            
            //Media cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "GroupLinkMainCell") as! GroupLinkMainCell
            cell.setCellData(model: model)
            cell.reloadData = {
                
                self.table_view.reloadRows(at: [indexPath], with: .automatic)
            }
            return cell
        }
        
        return UITableViewCell()
    }
    
    func deleteImageWithIndex(index : Int) {
        
        let medias = self.arrFields.filter({ (cellModel) -> Bool in
            return cellModel.cellType == .CreateCaseMediaCell
        })
        
        medias.last?.dataArr.remove(at: index)
        table_view.reloadData()
    }
}

//MARK: Api
extension CreateCaseVC {
    
    //Valid
    func isValidGroup() -> Bool {
        
        self.view.endEditing(true)
        for model in arrFields {
            
            if model.cellType == .CreateCaseTitleCell {
                if Utilities.checkStringEmptyOrNil(str: model.userText) {
                    
                    Utilities.showAlertView(title: AppConstants.AppName, message: StringConstants.CreateCase.kEnterTitle)
                    return false
                }
            }
            else if model.cellType == .CreateCaseLinkCell{
                
                for mm1 in model.dataArr{
                    
                    let mm = mm1 as? CellModel ?? CellModel()
                    if mm.userText == nil {
                        
                        Utilities.showAlertView(title: AppConstants.AppName, message: "Please enter link")
                        return false
                    }
                    else if !mm.userText!.isValidUrl(){
                        
                        Utilities.showAlertView(title: AppConstants.AppName, message: "Please enter valid link")
                        return false
                    }
                }
            }
            
        }
        
        return true
    }
    
    //Handle Upload Document
    func handleDocument(arrDocument : [UploadDocumentsModel]){
        
        let filter = arrDocument.filter { (model) -> Bool in
            return model.fileServerUrl == nil
        }
        
        if filter.count > 0 {
           
            self.uploadImage(model: filter.first!) { (model) in
                self.handleDocument(arrDocument: filter)
            }
        }
    }
    
    //Upload Image
    func uploadImage(model : UploadDocumentsModel,success:@escaping ((_ model : UploadDocumentsModel)->Void)) {
        
        var header = ApplicationData.sharedInstance.authorizationHeaders
        header["destination"] = "group"
        
        UploadManager.sharedInstance.uploadFile(AppConstants.serverURL, command: AppConstants.URL.UploadFile, image: model.image!, fileURL: nil, folderKeyvalue: "", uploadParamKey:"file", params: nil , headers: header, success: { (response, message) in
            
            if let respnseDict = response as? [String:Any] {
                if let files = respnseDict["files"] as? [[String:Any]] {
                    
                    if let absolutePath = files[0]["absolutePath"] as? String {
                        model.fileServerUrl = absolutePath
                        let medias = self.arrFields.filter({ (cellModel) -> Bool in
                            return cellModel.cellType == .CreateCaseMediaCell
                        })
                        
                        medias.last?.dataArr.append(model)
                        self.table_view.reloadData()
                        success(model)
                    }
                }
            }
            
        }) { (failureMessage) in
            
            Utilities.showAlertView(title: AppConstants.AppName, message: failureMessage)
        }
    }
}
