//
//  ActionViewController.swift
//  Extension
//
//  Created by Антон Кашников on 10/01/2024.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

class ActionViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // When extension is created, its extensionContext lets us control how it interacts with the parent app.
        // In the case of inputItems this will be an array of data the parent app is sending to our extension to use.
        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
            // Input item contains an array of attachments, which are given to us wrapped up as an NSItemProvider. Our code pulls out the first attachment from the first input item.
            if let itemProvider = inputItem.attachments?.first {
                if #available(iOSApplicationExtension 14.0, *) {
                    // Ask the item provider to actually provide us with its item.
                    // The method will carry on executing while the item provider is busy loading and sending us its data.
                    itemProvider.loadItem(forTypeIdentifier: UTType.propertyList.identifier as String) { [weak self] dict, error in
                        guard
                            let itemDictionary = dict as? NSDictionary,
                            let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary
                        else { return }
                        print(javaScriptValues)
                    }
                } else {
                    itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) { [weak self] dict, error in
                        guard
                            let itemDictionary = dict as? NSDictionary,
                            let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary
                        else { return }
                        print(javaScriptValues)
                    }
                }
            }
        }
    }

    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }
}
