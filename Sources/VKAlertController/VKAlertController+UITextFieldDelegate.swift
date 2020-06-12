//
//  File.swift
//  
//
//  Created by Valentin Kiselev on 6/12/20.
//

import UIKit

extension VKAlertController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
