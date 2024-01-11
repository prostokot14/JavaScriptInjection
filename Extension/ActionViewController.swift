//
//  ActionViewController.swift
//  Extension
//
//  Created by Антон Кашников on 10/01/2024.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

final class ActionViewController: UIViewController {
    // MARK: - IBOutlets
    
    @IBOutlet private var scriptTextView: UITextView!
    
    // MARK: - Private Properties
    
    private var pageTitle = ""
    private var pageURL = ""
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        // When extension is created, its extensionContext lets us control how it interacts with the parent app.
        // In the case of inputItems this will be an array of data the parent app is sending to our extension to use.
        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
            // Input item contains an array of attachments, which are given to us wrapped up as an NSItemProvider. Our code pulls out the first attachment from the first input item.
            if let itemProvider = inputItem.attachments?.first {
                let identifier = if #available(iOSApplicationExtension 14.0, *) {
                    UTType.propertyList.identifier as String
                } else {
                    kUTTypePropertyList as String
                }
                
                // Ask the item provider to actually provide us with its item.
                // The method will carry on executing while the item provider is busy loading and sending us its data.
                itemProvider.loadItem(forTypeIdentifier: identifier) { [weak self] dict, error in
                    guard
                        let itemDictionary = dict as? NSDictionary,
                        let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary
                    else { return }
                    
                    self?.pageTitle = javaScriptValues["title"] as? String ?? ""
                    self?.pageURL = javaScriptValues["URL"] as? String ?? ""
                    
                    DispatchQueue.main.async {
                        self?.title = self?.pageTitle
                    }
                }
            }
        }
    }
    
    // MARK: - Private methods
    
    @objc
    private func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        
        // We need to convert the rectangle to our view's co-ordinates.
        // This is because rotation isn't factored into the frame,
        // so if the user is in landscape we'll have the width and height flipped.
        // Using the convert() method will fix that.
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        // A check in there for UIKeyboardWillHide.
        // That's the workaround for hardware keyboards being connected by explicitly setting the insets to be zero.
        scriptTextView.contentInset = if notification.name == UIResponder.keyboardWillHideNotification {
            .zero
        } else {
            UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        scriptTextView.scrollIndicatorInsets = scriptTextView.contentInset
        scriptTextView.scrollRangeToVisible(scriptTextView.selectedRange)
    }
    
    // MARK: - IBActions

    @IBAction private func done() {
        let item = NSExtensionItem()
        let webDictionary: NSDictionary = [
            NSExtensionJavaScriptFinalizeArgumentKey: ["customJavaScript": scriptTextView.text as Any]
        ]
        
        let customJavaScript = if #available(iOSApplicationExtension 14.0, *) {
            NSItemProvider(item: webDictionary, typeIdentifier: UTType.propertyList.identifier as String)
        } else {
            NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
        }
        
        item.attachments = [customJavaScript]
        extensionContext?.completeRequest(returningItems: [item])
    }
}
