//
//  ViewController+Extension.swift
//  VirtualTourist
//
//  Created by Luis Alberto Rosas Arce on 16/11/21.
//

import Foundation
import UIKit

extension UIViewController {
    func showErrorAlert(message: String) {
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alertVC, animated: true, completion: nil)
        }
    }
}
