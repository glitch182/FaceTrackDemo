//
//  BaseViewController.swift
//  FaceTrackDemo
//
//  Created by Vishal Chandran on 27/10/24.
//

import UIKit

class BaseViewController: UIViewController, NameDescribable {

    // MARK: - View Life Cycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Public Methods

    /**
     Presents a `UIAlertController` to the user to convey an error message.
     - parameters:
     - message: A message of type `String` to be displayed on the `UIAlertController`.
     */
    func showError(with message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }

}
