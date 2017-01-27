//
//  MessageViewController.swift
//  QRReader
//
//  Created by Владимир Мельников on 27/01/2017.
//  Copyright © 2017 Владимир Мельников. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController {

    @IBOutlet var messageTextView: UITextView!
    
    var text: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBarButtonItemAction))
        navigationItem.rightBarButtonItem = doneBarButtonItem
        
        if let text = text {
            messageTextView.text = text
        } else {
            messageTextView.text = ""
        }
    }
    
    func doneBarButtonItemAction() {
        dismiss(animated: true, completion: nil)
    }
}
