//
//  CustomScriptsTableViewController.swift
//  Extension
//
//  Created by Антон Кашников on 12/01/2024.
//

import UIKit

protocol CustomScriptsDataDelegate {
    var customScripts: [CustomScript] { get }
    func setScriptToShow(at index: Int)
}

final class CustomScriptsTableViewController: UITableViewController {
    // MARK: - Public Properties
    
    var delegate: CustomScriptsDataDelegate?

    // MARK: - UITableViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        delegate?.customScripts.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customScriptCell", for: indexPath)
        
        if #available(iOSApplicationExtension 14.0, *) {
            var configuration = cell.defaultContentConfiguration()
            configuration.text = delegate?.customScripts[indexPath.row].name
            cell.contentConfiguration = configuration
        } else {
            cell.textLabel?.text = delegate?.customScripts[indexPath.row].name
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.setScriptToShow(at: indexPath.row)
        navigationController?.popViewController(animated: true)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
}
