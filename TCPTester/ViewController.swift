//
//  ViewController.swift
//  TCPTester
//
//  Created by Noah Peeters on 5/5/17.
//  Copyright © 2017 Noah Peeters. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var hostTextField: NSTextField!
    @IBOutlet weak var portTextField: NSTextField!
    @IBOutlet weak var messageTextField: NSComboBox!
    @IBOutlet weak var encodingPopUpButton: NSPopUpButton!
    @IBOutlet weak var messagesTableView: NSTableView!
    
    
    var messages: [TCPMessage] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init table view
        messagesTableView.delegate = self
        messagesTableView.dataSource = self
        messagesTableView.rowHeight = 26
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func connect(_ sender: NSButton) {
        
    }
    
    func addMessage(message: TCPMessage) {
        messages.append(message)
        messagesTableView.beginUpdates()
        messagesTableView.insertRows(at: IndexSet(integer: messages.count - 1), withAnimation: NSTableViewAnimationOptions())
        messagesTableView.endUpdates()
        messagesTableView.scrollRowToVisible(messages.count - 1)
    }
    
    @IBAction func send(_ sender: NSButton) {
        let rawMessage = messageTextField.stringValue; //TODO check selected encoding
        
        let encoding = InputEncoding(rawValue: encodingPopUpButton.titleOfSelectedItem ?? "UTF-8") ?? .utf8
        
        if let data = encoding.decode(input: rawMessage) {
            let currentTime: Double = Date().timeIntervalSince1970
            addMessage(message: TCPMessage(time: currentTime, fromServer: false, encoding: OutputEncoding(from: encoding), message: data))
            if messageTextField.indexOfItem(withObjectValue: rawMessage) >= messageTextField.numberOfItems {
                messageTextField.addItem(withObjectValue: rawMessage)
            }
        }
    }
}

extension ViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return messages.count
    }
}


extension ViewController: NSTableViewDelegate {
    func tableEncodingChanged(_ sender: NSPopUpButton) {
        let row = messagesTableView.row(for: sender)
        messages[row].encoding = OutputEncoding(rawValue: sender.titleOfSelectedItem ?? "hex") ?? .hex
        messagesTableView.beginUpdates()
        messagesTableView.reloadData(forRowIndexes: IndexSet(integer: row), columnIndexes: IndexSet(integersIn: 3...4))
        messagesTableView.endUpdates()
    }

    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let rowData = messages[row]
        var text = ""
        
        if tableColumn == tableView.tableColumns[0] {
            let date = Date(timeIntervalSince1970: rowData.time)
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .medium
            text = formatter.string(from: date)
        } else if tableColumn == tableView.tableColumns[1] {
            text = String(rowData.fromServer ? "Incomming" : "Outgoing")
        } else if tableColumn == tableView.tableColumns[2] {
            text = String(rowData.message.count)
        } else if tableColumn == tableView.tableColumns[4] {
            text = rowData.getEncodedMessage()
        } else {
            let popUpButton = NSPopUpButton()
            popUpButton.addItems(withTitles: ["Hex", "UTF-8"])
            popUpButton.selectItem(withTitle: rowData.encoding.rawValue)
            popUpButton.target = self
            popUpButton.action = #selector(tableEncodingChanged)
            
            return popUpButton
        }

        if let cell = tableView.make(withIdentifier: tableColumn!.identifier, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
}
