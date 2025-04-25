//
//  LabelViewController.swift
//  AppleClock
//
//  Created by yk on 4/25/25.
//

import UIKit

class LabelViewController: UIViewController {

    @IBOutlet weak var inputField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        inputField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if inputField.isFirstResponder {
            inputField.resignFirstResponder()
        }
    }

}
