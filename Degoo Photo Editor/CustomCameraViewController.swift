//
//  CustomCameraViewController.swift
//  Degoo Photo Editor
//
//  Created by TIC on 2/1/18.
//  Copyright © 2018 Degoo. All rights reserved.
//

import UIKit
import PhotoEditorSDK
class CustomCameraViewController: UIViewController, PhotoEditViewControllerDelegate {
    var cameraViewController:CameraViewController!
    var photoEditViewController:PhotoEditViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        presentCameraViewController()
    }
    // MARK: - Configuration
    
    private func buildConfiguration() -> Configuration {
        let configuration = Configuration() { builder in
            // Configure camera
            builder.configureCameraViewController() { options in
                // Just enable Photos
                options.allowedRecordingModes = [.photo]
                options.showFilterIntensitySlider = false
                options.includeUserLocation = false
                options.photoActionButtonConfigurationClosure = {button in
                    button.tintColor = UIColor.white
                }
                options.flashButtonConfigurationClosure = {button in
                    button.tintColor = UIColor.white
                }
                options.switchCameraButtonConfigurationClosure = {button in
                    button.tintColor = UIColor.white
                }
                options.filterSelectorButtonConfigurationClosure = {button in
                    button.tintColor = UIColor.white
                }
            }
        }
        return configuration
    }
    
    // MARK: - Presentation
    
    private func presentCameraViewController() {
        let configuration = buildConfiguration()
        cameraViewController = CameraViewController(configuration: configuration)
        cameraViewController.dataCompletionBlock = {data in
            if let data = data {
                let photo = Photo(data: data)
                self.cameraViewController.present(self.createPhotoEditViewController(with: photo), animated: true, completion: nil)
            }
        }
        
        present(cameraViewController, animated: true, completion: nil)
    }
    private func createPhotoEditViewController(with photo: Photo) -> PhotoEditViewController {
        // Create a photo edit view controller
        photoEditViewController = PhotoEditViewController(photoAsset: photo)
        photoEditViewController.delegate = self
        return photoEditViewController
    }
    
    // MARK: - PhotoEditViewControllerDelegate Methods
    
    func photoEditViewController(_ photoEditViewController: PhotoEditViewController, didSave image: UIImage, and data: Data) {
        // set up activity view controller
        let imageToShare = [image]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = photoEditViewController.view // so that iPads won't crash
        // present the view controller
        photoEditViewController.present(activityViewController, animated: true, completion: nil)
        activityViewController.completionWithItemsHandler = {
            (activity, success, items, error) in
            photoEditViewController.dismiss(animated: true, completion: nil)
        };
    }
    
    func photoEditViewControllerDidFailToGeneratePhoto(_ photoEditViewController: PhotoEditViewController) {
        photoEditViewController.dismiss(animated: true, completion: nil)
    }
    func photoEditViewControllerDidCancel(_ photoEditViewController: PhotoEditViewController) {
        photoEditViewController.dismiss(animated: true, completion: nil)
    }
}
