//
//  CustomCameraViewController.swift
//  Degoo Photo Editor
//
//  Created by TIC on 2/1/18.
//  Copyright © 2018 Degoo. All rights reserved.
//

import UIKit
import PhotoEditorSDK

class CustomCameraViewController: UIViewController {
    
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
                options.includeUserLocation = false
                options.backgroundColor = Colors.DegooBrandedColor;
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
        let cameraViewController:CameraViewController = CameraViewController(configuration: configuration)
        present(cameraViewController, animated: true, completion: nil)
    }
    
}
