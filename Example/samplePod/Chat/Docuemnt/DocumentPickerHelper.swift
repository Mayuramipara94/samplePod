//
//  DocumentPickerHelper.swift
//  Bank2Grow
//
//  Created by Vish on 19/05/18.
//  Copyright © 2018 Coruscate. All rights reserved.
//

import UIKit
import MobileCoreServices
import Photos

class DocumentPickerHelper: NSObject{
    
/*DocumentPickerHelper.sharedInstance.openDocumentPicker()
 DocumentPickerHelper.sharedInstance.isDocumentGet = { (image, getDocument) in
 
 model?.attachmentName =  getDocument.attachmentName
 model?.fileSize =  getDocument.fileSize
 model?.fileType =  getDocument.fileType
 self.tableView.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .automatic)
  }*/
    
    static let sharedInstance = DocumentPickerHelper()
    var model = UploadDocumentsModel()
    var isDocumentGet : ((_ image : UIImage? , _ dictInfo : UploadDocumentsModel) -> ())?
    var isMultipleSelect : ((_ arrDocument : [UploadDocumentsModel]) -> ())?
    var dictData = [String:Any]()
    
    func openImagePicker(){
        Utilities.open_galley_or_camera(delegate: self,mediaType: [kUTTypeJPEG as String, kUTTypePNG as String])
    }
    
    func openMultipleImagePicker(imageLimit:Int = 5) {
        
        Utilities.openMultipleImagePicker(delegate: self, imagePickerDelegate: self, count: imageLimit)
    }
    
    func openDocumentPicker(){
        
        UIViewController.current().view.endEditing(true)
        let alert = UIAlertController(title: "Pick Document", message: "Choose option", preferredStyle: AppConstants.DeviceType.IS_IPAD ? .alert : .actionSheet)
        alert.addAction(UIAlertAction(title: "Pick Image", style: .default, handler: { (alert) in
            
            Utilities.open_galley_or_camera(delegate: self,mediaType: [kUTTypeJPEG as String, kUTTypePNG as String])
            
        }))
        
        alert.addAction(UIAlertAction(title: "Pick Document from Files", style: .default, handler: { (alert) in
            
            let types = [kUTTypePDF as String]
            let documentPicker = UIDocumentPickerViewController(documentTypes: types, in: .import)
            documentPicker.delegate = self
            UIViewController.current().present(documentPicker, animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (alert) in
            
        }))
        
        alert.popoverPresentationController?.sourceView = UIViewController.current().view
        UIViewController.current().present(alert, animated: true, completion: nil)
    }
    
    func openDocumentPickerWithVideo() {
        
        UIViewController.current().view.endEditing(true)
        let alert = UIAlertController(title: "Pick Document", message: "Choose option", preferredStyle: AppConstants.DeviceType.IS_IPAD ? .alert : .actionSheet)
        alert.addAction(UIAlertAction(title: "Pick Image", style: .default, handler: { (alert) in
            
            Utilities.open_galley_or_camera(delegate: self,mediaType: [kUTTypeJPEG as String, kUTTypePNG as String])
            
        }))
        
        alert.addAction(UIAlertAction(title: "Pick Video", style: .default, handler: { (alert) in
            
            Utilities.openVideoPicker(delegate: self)
        }))
        
        alert.addAction(UIAlertAction(title: "Pick Document from Files", style: .default, handler: { (alert) in
            
            let types = [kUTTypePDF as String]
            let documentPicker = UIDocumentPickerViewController(documentTypes: types, in: .import)
            documentPicker.delegate = self
            UIViewController.current().present(documentPicker, animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (alert) in
            
        }))
        
        alert.popoverPresentationController?.sourceView = UIViewController.current().view
        UIViewController.current().present(alert, animated: true, completion: nil)
    }
}

//Multiple Image select Delegate
extension DocumentPickerHelper : OpalImagePickerControllerDelegate{
    
    func imagePicker(_ picker: OpalImagePickerController, didFinishPickingImages images: [UIImage]) {
        
        picker.dismiss(animated: true) {
            
            var imagesModel = [UploadDocumentsModel]()
            for item in images {
                
                let model1 = UploadDocumentsModel()
                model1.image = item
                model1.fileDesc = ""
                model1.fileDate = DateUtilities.getIsoFormateCurrentDate()
                imagesModel.append(model1)
            }
            
            if let documentPicked = self.isMultipleSelect {
                documentPicked(imagesModel)
            }
        }
    }
    
    func imagePickerDidCancel(_ picker: OpalImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}


extension DocumentPickerHelper : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        picker.dismiss(animated: true, completion: nil)
        picker.dismiss(animated: true) {
            if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
                
                //Image
                var fileName : String?
                if let imageURL = info[UIImagePickerControllerReferenceURL] as? URL {
                    let result = PHAsset.fetchAssets(withALAssetURLs: [imageURL], options: nil)
                    let asset = result.firstObject
                    
                    fileName = asset?.value(forKey: "filename") as? String
                    
                    if fileName == nil{
                        fileName = "image"
                        self.model.fileType = "image"
                    }else{
                        self.model.fileType = fileName?.components(separatedBy: ".")[1]
                    }
                    
                    self.model.fileExtension = imageURL.pathExtension
                    self.model.fileSize = "\(self.toDouble(value: pickedImage.sizePerMB())) MB"
                    self.model.fileSizeDouble = pickedImage.sizePerMB()
                    self.model.attachmentName = fileName
                }else{
                    UIImageWriteToSavedPhotosAlbum(pickedImage, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                }
                
                if let documentPicked = self.isDocumentGet {
                    documentPicked(pickedImage , self.model)
                }
            }
            else if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL {
                
                //Video
               
                self.model = UploadDocumentsModel()
                self.model.fileType = "video"
                self.model.fileExtension = videoUrl.pathExtension
                self.model.fileSize = "\(self.toDouble(value: videoUrl.sizePerMB())) MB"
                self.model.fileSizeDouble = videoUrl.sizePerMB()
                self.model.fileUrl = videoUrl
                if let documentPicked = self.isDocumentGet {
                    documentPicked(nil , self.model)
                }
            }
        }
        
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        self.fetchLastImage { (value) in
            
            model.fileType = "image"
            model.fileSize = "\(self.toDouble(value: image.sizePerMB())) MB"
            model.attachmentName = value?.fileName()
            model.fileExtension = value?.fileExtension()
            model.fileSizeDouble = image.sizePerMB()
            
//            if let documentPicked = isDocumentGet {
//                documentPicked(image , model)
//            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension DocumentPickerHelper : UIDocumentPickerDelegate{
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        
        let myURL = url as URL
        
        let size =  self.toDouble(value: myURL.sizePerMB())

        model.fileType = "PDF"
        model.fileSize = "\(size) MB"
        model.attachmentName = (myURL.absoluteString as NSString).lastPathComponent
        model.fileUrl = myURL
        model.fileExtension = myURL.pathExtension
        model.fileSizeDouble = myURL.sizePerMB()
        
        if let documentPicked = isDocumentGet {
            documentPicked(nil , model)
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func toDouble(value : Double) -> String{
        
        //let disValue = dis.toDouble()
        let disValue = String(format: "%0.2f",value)
        if disValue != "0.0" && disValue != "0.00"{
            
            return "\(disValue)"
        }
        
        return "-"
    }
}

extension DocumentPickerHelper{
    func fetchLastImage(completion: (_ localIdentifier: String?) -> Void)
    {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 1
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        if (fetchResult.firstObject != nil)
        {
            let lastImageAsset: PHAsset = fetchResult.firstObject as! PHAsset
            completion(lastImageAsset.localIdentifier)
        }
        else
        {
            completion(nil)
        }
    }
}

extension URL{
    
    func sizePerMB() -> Double {
        do {
            let attribute = try FileManager.default.attributesOfItem(atPath: self.path)
            if let size = attribute[FileAttributeKey.size] as? NSNumber {
                return size.doubleValue / 1000000.0
            }
        } catch {
            print("Error: \(error)")
        }
        return 0.0
    }
    
    func convertToBase64() -> String? {
        
        do {
            let fileData = try Data (contentsOf: self)
            let imageString = fileData.base64EncodedString ()
            return imageString
            
        } catch let error as NSError {
            print(error)
        }
       return nil
    }
}

extension UIImage {
    
    func sizePerMB() -> Double {
        
        let image = self
        let imgData: NSData = NSData(data: UIImageJPEGRepresentation((image), 1)!)
        
        let imageSize: Int = imgData.length
        let size =  (Double(imageSize) / 1024.0)/1024.0
        return size
    }
    
    public func convertToBase64(formats: String) -> String? {
        var imageData: Data?
        
        if formats == "PNG" || formats == "png" {
            imageData = UIImagePNGRepresentation(self)
        }
        else if formats == "JPEG" || formats == "JPG" || formats == "jpeg" || formats == "jpg"{
             imageData = UIImageJPEGRepresentation(self, 0.50)
        }
        return imageData?.base64EncodedString()
    }
}
