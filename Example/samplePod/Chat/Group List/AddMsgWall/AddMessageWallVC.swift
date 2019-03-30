//
//  AddMessageWallVC.swift
//  ConferenceAssociationApp
//
//  Created by CS-Mac-Mini on 01/01/19.
//  Copyright © 2019 CS-Mac-Mini. All rights reserved.
//

import UIKit

class AddMessageWallVC: UIViewController {

    //MARK: IBOutlet
    @IBOutlet weak var txtMessage: UIPlaceHolderTextView!
    @IBOutlet weak var imgWallImage: UIImageView!
    @IBOutlet weak var imgPlaceholder: UIImageView!
    
    //MARK: Variables
    var arrRequest = [CellModel]()
    var tagId : String?
    var wallCreate : (()->())?
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialConfig()
    }

    override func viewWillAppear(_ animated: Bool) {
       
        super.viewWillAppear(animated)
        Utilities.setNavigationBar(controller: self, isHidden: false, title: StringConstants.ScreenTitle.kNewMessage)
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Private Methods
    private func initialConfig(){
    
        addBackButton()
    }
    
    private func addBackButton() {
        
        //Back
        let btnBack = UIButton(frame : CGRect(x: 0, y: 0, width: 22, height: 22))
        btnBack.setImage(#imageLiteral(resourceName: "closeWhite"), for: .normal)
        btnBack.tintColor = UIColor.white
        btnBack.addTarget(self, action: #selector(btnClose_Click(sender:)), for: .touchUpInside)
        
        let back = UIBarButtonItem(customView: btnBack)
        self.navigationItem.setLeftBarButton(back, animated: true)
    }
    
    //MARK: IBAction
    
    @objc func btnClose_Click(sender:UIButton){
        
        UIViewController.current().navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnCamera_Click(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
        DocumentPickerHelper.sharedInstance.openImagePicker()
        DocumentPickerHelper.sharedInstance.isDocumentGet = { (image, getDocument) in
            
            let model1 = UploadDocumentsModel()
            model1.image = image
            model1.fileDesc = ""
            model1.fileDate = DateUtilities.getIsoFormateCurrentDate()
            
            self.imgPlaceholder.isHidden = true
            self.imgWallImage.image = image
            
            CreateGroupHelper.shared.uploadAttachment(model: model1, success: { (model) in
                
                let cellmodel = CellModel()
                cellmodel.cellType = .CreateCaseMediaCell
                cellmodel.dataArr = [model]
                
                self.arrRequest.append(cellmodel)
            })
        }
    }
    
    @IBAction func btnPost_Click(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
        if Utilities.checkStringEmptyOrNil(str: txtMessage.text){
            
            Utilities.showAlertView(title: AppConstants.AppName, message: "Please enter message")
        }else{
            
            let cellmodel = CellModel()
            cellmodel.cellType = .CreateCaseDescCell
            cellmodel.userText = txtMessage.text
            self.arrRequest.append(cellmodel)
            
            CreateGroupHelper.shared.createUpdateGroup(viewType: .CHAT_VIEW_TYPE_WALL, arrData: arrRequest, groupModel: nil, tagId: self.tagId, referenceId: nil) {
                
                UIViewController.current().navigationController?.popViewController(animated: true)
                self.wallCreate?()
                
            }
        }
    }
}
