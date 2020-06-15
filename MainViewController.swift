//
//  MainViewController.swift
//  Notes
//
//  Created by Radu Istrati on 15.05.20.
//  Copyright © 2020 Radu Istrati. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TransferDelegate {
    
    // Outlets
    @IBOutlet var table: UITableView!
    @IBOutlet var notesCountLabel: UILabel!
    @IBOutlet var footerBar: UIToolbar!

    // Variable to keep the array of all the Note objects that are currently showed in the MainViewController
    var notes = [Note]()
    
    // Notes count to set the label
    var notesCount = 0 { didSet { notesCountLabel.text = "\(notesCount) Notes" } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        initialSetup()
        
    }
    
    // Set some initial UI elements and other stuff
    func initialSetup() {

        table.delegate = self
        table.dataSource = self
        
        title = "Notes"
        
        notesCount = notes.count
        
        footerBar.clipsToBounds = true
    }
    
    // Method called when "Create button" is tapped.
    @IBAction func newNote(_ sender: Any) {
        if let vc = storyboard?.instantiateViewController(identifier: "Detail") as? DetailViewController {
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    // MARK: TableView methods
    
    // Swipe to delete rows
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            notes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            notesCount = notes.count
            saveData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseCell", for: indexPath)
        cell.textLabel?.text = notes[indexPath.row].title
        cell.detailTextLabel?.text = notes[indexPath.row].body
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(identifier: "Detail") as? DetailViewController {
            vc.delegate = self
            //vc.currentNote = notes[indexPath.row]
            vc.passedNote = notes[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // Protocol method to add a new note or update existing
    func dataTransfer(createdNote: Note) {
        for (index, note) in notes.enumerated() {
            if createdNote.uuid == note.uuid {
                notes.remove(at: index)
            }
        }
        notes.insert(createdNote, at: 0)
        table.reloadData()
        notesCount = notes.count
        saveData()
    }
    
    // Save notes to disk
    func saveData() {
        // Initiate a JSON Encoder
        let jsonEncoder = JSONEncoder()
        // Encode data
        if let dataToSave = try? jsonEncoder.encode(notes) {
            // Initiate UserDefaults
            let defaults = UserDefaults.standard
            // Save data in app directory
            defaults.set(dataToSave, forKey: "notes")
        } else {
            // Inform if it fails to save data
            print("Failed to save data")
        }
    }
    
    // Load notes from disk
    func loadData() {
        let defaults = UserDefaults.standard
        if let savedData = defaults.object(forKey: "notes") as? Data {
            let jsonDecoder = JSONDecoder()
            do {
                notes = try jsonDecoder.decode([Note].self, from: savedData)
            }
            catch {
                print("Error to load data!")
            }
        }
    }
    
}
