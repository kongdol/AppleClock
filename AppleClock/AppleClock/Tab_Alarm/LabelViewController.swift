//
//  LabelViewController.swift
//  AppleClock
//
//  Created by yk on 4/25/25.
//

import UIKit

class LabelViewController: UIViewController {

    @IBOutlet weak var inputField: UITextField!
    
    var entity: AlarmEntity?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        inputField.text = entity?.name
        inputField.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        inputField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let name = inputField.text?.trimmingCharacters(in: .whitespacesAndNewlines), name.count > 0 {
            entity?.name = name
        } else {
            entity?.name = "알람"
        }
        
        if inputField.isFirstResponder {
            inputField.resignFirstResponder()
        }
    }

}

extension LabelViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let name = inputField.text?.trimmingCharacters(in: .whitespacesAndNewlines), name.count > 0 {
            entity?.name = name
        } else {
            entity?.name = "알람"
        }
        navigationController?.popViewController(animated: true)
        return true
    }
}
