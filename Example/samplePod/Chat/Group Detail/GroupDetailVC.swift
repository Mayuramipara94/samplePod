//
//  GroupDetailVC.swift
//  ConferenceAssociationApp
//
//  Created by Coruscate on 29/11/18.
//  Copyright © 2018 CS-Mac-Mini. All rights reserved.
//

import UIKit

class GroupDetailVC: UIViewController {
    
    //MARK: OutLet
    @IBOutlet weak var table_view: UITableView!
    
    //MARK: Variables
    var groupId : String?
    var groupModel : GroupListModel?
    var arrFields = [CellModel]()

    override func viewDidLoad() {
        super.viewDidLoad()

        initialConfig()
    }
    
    //MARK: Private Methods
    func initialConfig() {
        
        table_view.separatorStyle = .none
        table_view.register(UINib.init(nibName: "CreateCaseMediaCell", bundle: nil), forCellReuseIdentifier: "CreateCaseMediaCell")
        table_view.register(UINib.init(nibName: "GroupDetailTabCell", bundle: nil), forCellReuseIdentifier: "GroupDetailTabCell")
       

        if let id = groupId,id.count > 0 {
            groupModel = ChatManager.sharedInstance.fetchGroupWith(id: id).first
        }

        Utilities.setNavigationBar(controller: self, isHidden: false, title: groupModel?.title ?? "")
        prepareDataSource()
    }
    
    //PrepareDatasource
    func prepareDataSource() {
        
        //Media
        if let media = groupModel?.referenceId?.attachments,media.count > 0 {
            
            var mediaDataArr = [Any]()
            for item in media {
                
                let model = UploadDocumentsModel()
                model.fileDate = item.date
                model.fileDesc = item.descriptionStr
                model.fileServerUrl = item.path
                mediaDataArr.append(model)
            }
            
            arrFields.append(Utilities.getModel(placeholder: "Media", placeholder1: nil, placeholder2: nil, userText: nil, userText1: nil, userText2: nil, type: .CreateCaseMediaCell, imageName: nil, keyboardType: nil, isSelected: false, requestKey: nil, errorMessage: nil, cellObj: nil, value: 0, dataArr: mediaDataArr))
        }
        
        
        //var userText = ""
//        if let desc = groupModel?.referenceId?.descriptionStr,desc.count > 0 {
//            userText = "Title\n\(groupModel?.title ?? "")\n\nDescription\n\(desc)"
//        }
//        else{
//            userText = "Title\n\(groupModel?.title ?? "")"
//        }
        
        let titleDesc = Utilities.getModel(type: .groupDetailDataCell, image: UIImage(), text: groupModel?.title ?? "", placeholder: "Title", obj: nil)
        titleDesc.isSelected = true
        
        let desc = Utilities.getModel(type: .groupDetailDataCell, image: UIImage(), text: groupModel?.referenceId?.descriptionStr ?? "", placeholder: "Description", obj: nil)
        
        let history = Utilities.getModel(type: .groupDetailDataCell, image: UIImage(), text: groupModel?.referenceId?.patient_history ?? "", placeholder: "History", obj: nil)
        
        let diagnosis = Utilities.getModel(type: .groupDetailDataCell, image: UIImage(), text: groupModel?.referenceId?.conclusion ?? "", placeholder: "Diagnosis", obj: nil)
        
        let treatment = Utilities.getModel(type: .groupDetailDataCell, image: UIImage(), text: groupModel?.referenceId?.treatment_and_followup ?? "", placeholder: "Treatment", obj: nil)
        
        let link = Utilities.getModel(type: .groupDetailDataCell, image: UIImage(), text: groupModel?.referenceId?.links ?? "", placeholder: "Link", obj: nil)
        
        arrFields.append(Utilities.getModel(placeholder: "", placeholder1: nil, placeholder2: nil, userText: nil, userText1: nil, userText2: nil, type: .groupDetailTabCell, imageName: nil, keyboardType: nil, isSelected: false, requestKey: nil, errorMessage: nil, cellObj: nil, value: 0, dataArr: [titleDesc,desc,history,diagnosis,treatment,link]))
    }
}

//MARK: TableView Delegates & DataSource

extension GroupDetailVC : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrFields.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = arrFields[indexPath.row]
        
         if model.cellType == .CreateCaseMediaCell {
            
            //Media cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "CreateCaseMediaCell") as! CreateCaseMediaCell
            cell.setCellData(model: model, isAllowDelete: false)
            return cell
        }
        else if model.cellType == .groupDetailTabCell {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "GroupDetailTabCell") as! GroupDetailTabCell
            cell.setCellData(model: model)
            cell.reloadTable = {
                self.table_view.reloadData()
            }
            return cell
        }
        
        return UITableViewCell()
    }
}

