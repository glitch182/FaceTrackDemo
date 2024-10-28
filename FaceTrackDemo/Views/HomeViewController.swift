//
//  HomeViewController.swift
//  FaceTrackDemo
//
//  Created by Vishal Chandran on 25/10/24.
//

import UIKit

class HomeViewController: BaseViewController {

    // MARK: - IBActions

    @IBAction func visionKitButtonTapped(_ sender: UIButton) {
        guard let visionKitVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: VisionKitViewController.typeName) as? VisionKitViewController else {
            return
        }

        show(visionKitVC, sender: self)
    }

    // MARK: - View Life Cycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Home"
    }

}

