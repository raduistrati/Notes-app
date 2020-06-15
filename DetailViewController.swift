//
//  DetailViewController.swift
//  Notes
//
//  Created by Radu Istrati on 15.05.20.
//  Copyright © 2020 Radu Istrati. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    // TextView outlet
    @IBOutlet var textView: UITextView!
    
    // Delegate to transfer data between viewControllers
    var delegate: TransferDelegate?
    var currentText = ""
    
    var passedNote: Note?
    var currentNote: Note!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadFromTableView()
        keyboardObservers()
        setUI()
    }
    
    // Set UI elements
    func setUI() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
    }
    
    // Method to run when action button is tapped
    @objc func shareTapped() {
        let vc = UIActivityViewController(activityItems: [currentText], applicationActivities: [])
           present(vc, animated: true)
    }
    
    // When view will disappear call the delegate method to transfer data to MainViewController
    override func viewWillDisappear(_ animated: Bool) {
        currentText = textView.text
        
        if currentText != "" {
            let title = setTitle(string: currentText)
            let body = setBody(string: currentText)
            currentNote.title = title
            currentNote.body = body
            
            delegate?.dataTransfer(createdNote: currentNote)
        }
    }
    
    // This method is called when the VC is instantiated
    func loadFromTableView() {
        if passedNote != nil {
            currentNote = passedNote
            currentText = currentNote.title + "\n" + currentNote.body
        } else {
            let uuid = UUID.init()
            currentNote = Note(title: "New", body: "", uuid: uuid)
        }
        textView.text = currentText
    }
    
    // MARK: Text processing
    
    func setBody(string: String) -> String {
        var separatedArray = string.components(separatedBy: "\n")
        separatedArray.remove(at: 0)
        let body = separatedArray.joined(separator: "\n")
        return body
    }
    
    func setTitle(string: String) -> String {
        let separatedArray = string.components(separatedBy: "\n")
        let title = separatedArray[0]
        return title
    }
    
    // MARK: TextView resize methods
    
    // This method should be called in the viewDidLoad() method
    func keyboardObservers() {
            let nc = NotificationCenter.default
            
            // Set an observer to pass data when keyboard will hide.
            nc.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
            // Set an observer to pass data when keyboard will change it's frame.
            nc.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        }
        
        @objc func adjustForKeyboard(notification: Notification) {
            // Get the notification userInfo dictionary, key called UIResponder.keyboardFrameEndUserInfoKey
            // This will give as a CGrect value type-casted as NSValue, because objC doesn't know what is a CGrect
            guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
            
            // Get the value of the frame as a CGRect
            let keyboardScreenEndFrame = keyboardValue.cgRectValue
            // Convert the rectangle to our view's co-ordinates
            let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, to: view.window)
            
            // Adjust the contentInset and scrollIndicatorInsets of our text view.
            
            // If the keyboard is hidden the text view will fill entire screen
            if notification.name == UIResponder.keyboardWillHideNotification {
                textView.contentInset = .zero
            } else {
                // Else if the keyboard is visible the textView will resize acording to the keboard frame minus botom safe area.
                textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
            }
            
            // This will adjust the scrool indicator to be the same size as textView
            textView.scrollIndicatorInsets = textView.contentInset
            
            // This will make thetext view to scrool to the selected range when user taps on keyboard.
            let selectedRange = textView.selectedRange
            textView.scrollRangeToVisible(selectedRange)
        }
}
