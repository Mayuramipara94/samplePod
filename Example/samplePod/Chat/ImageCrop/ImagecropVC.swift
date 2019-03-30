//
//  ImagecropVC.swift
//  ConferenceAssociationApp
//
//  Created by Coruscate on 22/11/18.
//  Copyright © 2018 CS-Mac-Mini. All rights reserved.
//

import UIKit

class ImagecropVC: UIViewController {
    
    //MARK: OutLet
    @IBOutlet weak var collectionTop: UICollectionView!
    @IBOutlet weak var collectionBottom: UICollectionView!
    @IBOutlet weak var txtComment: UITextField!
    
    //MARK: Variable
    var arrAttachments = [UploadDocumentsModel]()
    var documentUpdate : ((_ arrDocuemnt : [UploadDocumentsModel]) -> ())?
    var isAllowEdit = false
    var btnDate : UIButton?
    var currentIndex : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialConfig()
    }

    override func viewWillAppear(_ animated: Bool) {
        
        Utilities.setNavigationBar(controller: self, isHidden: false, title: "")
    }
   
    //MARK: Private Methods
    func initialConfig() {
        
        txtComment.attributedPlaceholder = NSAttributedString(string: "Comment", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        collectionTop.register(UINib(nibName: "ImageCropCell", bundle: nil), forCellWithReuseIdentifier: "ImageCropCell")
        collectionBottom.register(UINib(nibName: "ImageCropCell", bundle: nil), forCellWithReuseIdentifier: "ImageCropCell")
        
        addbarButton()
        setCurrentDateAndComment()
    }
    
    func addbarButton() {
        
        btnDate = UIButton(frame : CGRect(x: 0, y: 0, width: 100, height: 22))
        btnDate?.layer.cornerRadius = 15
        btnDate?.clipsToBounds = true
        btnDate?.addTarget(self, action: #selector(btnDate_Click), for: .touchUpInside)
        btnDate?.isUserInteractionEnabled = isAllowEdit
        let date = UIBarButtonItem(customView: btnDate!)
        date.applyNavBarConstraints(width: 100, height: 30)
        
        let btnDone = UIButton(frame : CGRect(x: 0, y: 0, width: 22, height: 22))
        btnDone.setImage(UIImage(named: "icon_Right_white"), for: .normal)
        btnDone.addTarget(self, action: #selector(btnDone_Click), for: .touchUpInside)
        let done = UIBarButtonItem(customView: btnDone)
        done.applyNavBarConstraints(width: 30, height: 30)
        
        
        if isAllowEdit == true{
            self.navigationItem.setRightBarButtonItems([done,date], animated: true)
        }
        else{
            txtComment.isUserInteractionEnabled = false
            self.navigationItem.setRightBarButtonItems([date], animated: true)
        }
    }
    
    //Set Current Attachment Date And Comment
    func setCurrentDateAndComment() {
        
        btnDate?.setTitle(DateUtilities.convertStringDateintoStringWithFormat(dateStr: arrAttachments[currentIndex].fileDate ?? "", format: DateUtilities.DateFormates.kCreateCaseDate), for: .normal)
        
        txtComment.text = arrAttachments[currentIndex].fileDesc
        
    }
    
    //MARK: IBAction
    
    @IBAction func btnDate_Click(_ sender: UIButton) {
        
        hideKeyBoard()
        let datePicker = GMDatePicker()
        datePicker.datePicker.maximumDate = Date()
        Utilities.openDatePicker(datePicker: datePicker, delegate: self, selectedDate:DateUtilities.convertDateFromString(dateStr: arrAttachments[currentIndex].fileDate ?? ""))
    }
    
    @IBAction func btnDone_Click(_ sender: UIButton) {
        
        UIViewController.current().navigationController?.popViewController(animated: true)
        if let click = documentUpdate {
            click(arrAttachments)
        }
    }
}

//MARK: UICollectionViewDataSource methods

extension ImagecropVC : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == collectionBottom {
            
            return CGSize(width: 100, height: 100)
        }
        
        return CGSize(width: AppConstants.ScreenSize.SCREEN_WIDTH, height: AppConstants.ScreenSize.SCREEN_HEIGHT - 197)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return arrAttachments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCropCell", for: indexPath) as? ImageCropCell
        cell?.setCellData(model: arrAttachments[indexPath.row])
        
        if collectionView == collectionBottom {
            cell?.layer.borderWidth = 1
            cell?.layer.borderColor = UIColor.white.cgColor
            cell?.layer.masksToBounds = true
        }
        else{
            cell?.layer.borderWidth = 0
            cell?.layer.borderColor = UIColor.clear.cgColor
            cell?.layer.masksToBounds = true
        }
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == collectionBottom {
            
            hideKeyBoard()
            collectionTop.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            currentIndex = indexPath.row
            setCurrentDateAndComment()
        }
    }
}

//MARK: DatePicker Delegate Methods
extension ImagecropVC: GMDatePickerDelegate {
    
    func gmDatePicker(_ gmDatePicker: GMDatePicker, didSelect date: Date) {
        
       arrAttachments[currentIndex].fileDate = DateUtilities.convertDateToString(date: date, formate: DateUtilities.DateFormates.kIsoFormate)
       setCurrentDateAndComment()
    }
    
    func gmDatePickerDidCancelSelection(_ gmDatePicker: GMDatePicker) {
    }
}

//MARK: UIScrollViewDelegate Methods

extension ImagecropVC: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        hideKeyBoard()
        if let cell = collectionTop.visibleCells.first {
            currentIndex = collectionTop.indexPath(for: cell)?.row ?? 0
            setCurrentDateAndComment()
        }
    }
}

//MARK: textField delegate methods
extension ImagecropVC : UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if range.location == 0{
            
            if string == " " {
                return false
            }
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        arrAttachments[currentIndex].fileDesc = textField.text
    }
    
    func hideKeyBoard() {
        view.endEditing(true)
    }
}
