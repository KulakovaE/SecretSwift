//
//  ViewController.swift
//  SecretSwift
//
//  Created by Elena Kulakova on 2020-03-09.
//  Copyright © 2020 Elena Kulakova. All rights reserved.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController {
    
    @IBOutlet weak var secret: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Nothhing to see here."
        
        //To make the text view adjust its content and scroll insets when the keyboard appears and disappears. This asks iOS to tell us when the keyboard changes or when it hides.
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        //if the app stop beeing active
        notificationCenter.addObserver(self, selector: #selector(saveSecretMessage), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue //relative to our screen
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window) 
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            secret.contentInset = .zero
        } else {
            secret.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        secret.scrollIndicatorInsets = secret.contentInset
        
        let selectedRange = secret.selectedRange
        secret.scrollRangeToVisible(selectedRange)
    }
    
    @IBAction func authenticatetapped(_ sender: Any) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) { //&error is the NSError type for handling errors. By passing in &error – Objective-C’s equivalent of inout – it means “if you hit an error, here’s the place in memory where you should store that error so I can read it.”
            let reason = "Identify yourself!"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self?.unlockSecretMessage()
                    } else {
                        self?.showAlert(title: "Authentication failed", message:  "You could not be verified; please try again.")
                    }
                }
            }
        } else {
            showAlert(title: "Biometry unavailable", message:  "Your device is not configured for biometric authentication.")
        }
    }
    
    func unlockSecretMessage() {
        secret.isHidden = false
        title = "Secrt stuff!"
        
        secret.text = KeychainWrapper.standard.string(forKey: "SecretMessage") ?? ""
    }
    
    @objc func saveSecretMessage() {
        guard secret.isHidden ==  false else { return }
        
        KeychainWrapper.standard.set(secret.text, forKey: "SecretMessade")
        secret.resignFirstResponder()
        secret.isHidden = true
        title = "Nothing to see here"
    }
    
    func showAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message:message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(ac, animated: true, completion: nil)
    }
}

