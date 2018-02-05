//
//  ActionViewController.swift
//  Edit Photo
//
//  Created by TIC on 2/4/18.
//  Copyright © 2018 Degoo. All rights reserved.
//

import UIKit
import MobileCoreServices
import PhotoEditorSDK

class ActionViewController: UIViewController, PhotoEditViewControllerDelegate {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Activate Photo Editor SDK license
        if let licenseURL = Bundle.main.url(forResource: "ios_license", withExtension: "dms") {
            PESDK.unlockWithLicense(at: licenseURL)
        }
        handleImageFromExtensionContext();
    }
    
    func handleImageFromExtensionContext(){
        // Get the item[s] we're handling from the extension context.
        // Replace this with something appropriate for the type[s] your extension supports.
        var imageFound = false
        for item in self.extensionContext!.inputItems as! [NSExtensionItem] {
            for provider in item.attachments! as! [NSItemProvider] {
                if provider.hasItemConformingToTypeIdentifier(kUTTypeImage as String) {
                    // This is an image. We'll load it, then place it in our image view.
                    provider.loadItem(forTypeIdentifier: kUTTypeImage as String, options: nil, completionHandler: { (data, error) in
                        OperationQueue.main.addOperation {
                            var contentData: Data? = nil
                            if let data = data as? Data {
                                contentData = data
                            } else if let url = data as? URL {
                                contentData = try? Data(contentsOf: url)
                            }else if let imageData = data as? UIImage {
                                contentData = UIImagePNGRepresentation(imageData)
                            }
                            if let contentData = contentData{
                                let photo = Photo(data: contentData)
                                self.presentPhotoEditorController(photoAsset: photo)
                            }
                        }
                    })
                    
                    imageFound = true
                    break
                }
            }
            
            if (imageFound) {
                // We only handle one image, so stop looking for more.
                break
            }
        }
    }
    
    func presentPhotoEditorController(photoAsset: Photo){
        let photoEditViewController = PhotoEditViewController(photoAsset: photoAsset, configuration: buildConfiguration())
        photoEditViewController.delegate = self
        photoEditViewController.toolbar.backgroundColor = Colors.DegooBrandedPhotoEditorToolBarColor
        self.present(photoEditViewController, animated: false, completion: nil)
    }
    
    // MARK: - Configuration
    private func buildConfiguration() -> Configuration {
        let configuration = Configuration() { builder in
            builder.configurePhotoEditorViewController({ (options) in
                options.menuBackgroundColor = Colors.DegooBrandedColor
            })
        }
        return configuration
    }
    
    func didSaveImage(photoEditViewController: PhotoEditViewController){
        let alert =  UIAlertController(title: "Great!", message: "Your edited photo successfully saved to Camera Roll", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (alertAction) in
            // Return any edited content to the host app.
            self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
        }))
        photoEditViewController.present(alert, animated: true)
    }
    
    // MARK: - PhotoEditViewControllerDelegate Methods
    func photoEditViewController(_ photoEditViewController: PhotoEditViewController, didSave image: UIImage, and data: Data) {
        UIImageWriteToSavedPhotosAlbum(image, didSaveImage(photoEditViewController: photoEditViewController), nil, nil)
    }
    
    func photoEditViewControllerDidFailToGeneratePhoto(_ photoEditViewController: PhotoEditViewController) {
        // Return any edited content to the host app.
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }
    
    func photoEditViewControllerDidCancel(_ photoEditViewController: PhotoEditViewController) {
        // Return any edited content to the host app.
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }
    
}
