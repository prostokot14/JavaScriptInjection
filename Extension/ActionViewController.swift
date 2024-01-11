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
