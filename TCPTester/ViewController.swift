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
    @IBOutlet weak var connectButton: NSButton!
    
    @IBOutlet weak var messageTextField: NSComboBox!
    @IBOutlet weak var encodingPopUpButton: NSPopUpButton!
    @IBOutlet weak var messagesTableView: NSTableView!
    @IBOutlet weak var sendButton: NSButton!
    
    
    var messages: [TCPMessage] = [];
    
    var connected: Bool = false;
    
    var inputStream: InputStream!
    var outputStream: OutputStream!
    var maxBufferSize: Int = 1024
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init table view
        messagesTableView.delegate = self
        messagesTableView.dataSource = self
        messagesTableView.rowHeight = 26
        
        //setup ui
        disableSending()
        enableConnecting()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func connect(_ sender: NSButton) {
        if connected {
            inputStream.close()
            outputStream.close()
            connected = false
            disableSending()
            enableConnecting()
        } else {
            let host = hostTextField.stringValue
            
            if let port = UInt32(portTextField.stringValue) {
                initNetworkCommunication(host: host as CFString, port: port)
            }
        }
    }
    
    
    /// Returns the current time
    ///
    /// - Returns: The current time as a Double
    func getCurrentTime() -> Double {
        return Date().timeIntervalSince1970
    }
    
    /// Adds a message to the `messages` array and makes sure that `messagesTableView` shows it.
    ///
    /// - Parameter message: The Message
    func addMessage(message: TCPMessage) {
        messages.append(message)
        messagesTableView.beginUpdates()
        messagesTableView.insertRows(at: IndexSet(integer: messages.count - 1), withAnimation: NSTableViewAnimationOptions.slideDown)
        messagesTableView.endUpdates()
        messagesTableView.scrollRowToVisible(messages.count - 1)
    }

    @IBAction func send(_ sender: Any) {
        let rawMessage = messageTextField.stringValue;
        
        let encoding = InputEncoding(rawValue: encodingPopUpButton.titleOfSelectedItem ?? "UTF-8") ?? .utf8
        
        if let data = encoding.decode(input: rawMessage) {
            addMessage(message: TCPMessage(time: getCurrentTime(), fromServer: false, encoding: OutputEncoding(from: encoding), message: data))
            send(data: data)
            if messageTextField.indexOfItem(withObjectValue: rawMessage) >= messageTextField.numberOfItems {
                messageTextField.addItem(withObjectValue: rawMessage)
            }
        }
    }
    
    /// Removes a message at a specific row.
    ///
    /// - Parameter row: The index of the row. This is equal to the index of the message in the `messages` array.
    func remove(row: Int) {
        messages.remove(at: row)
        messagesTableView.beginUpdates()
        messagesTableView.removeRows(at: IndexSet(integer: row), withAnimation: NSTableViewAnimationOptions())
        messagesTableView.endUpdates()
    }
    
    /// Copys the message of a row into the user's clipboard
    ///
    /// - Parameters:
    ///   - row: The index of the row. This is equal to the index of the message in the `messages` array.
    ///   - encoding: The encoding that will be used
    func copy(row: Int, withEncoding encoding: OutputEncoding) {
        let rowData = messages[row]
        let pasteBoard = NSPasteboard.general()
        pasteBoard.clearContents()
        pasteBoard.writeObjects([encoding.encode(data: rowData.message) as NSPasteboardWriting])
    }
    
    /// Copys the message of a row utf-8 encoded into the user's clipboard
    ///
    /// - Parameter row: The index of the row. This is equal to the index of the message in the `messages` array.
    func copyUTF8(ofRow row: Int) {
        copy(row: row, withEncoding: OutputEncoding.utf8)
    }
    
    /// Copys the message of a row hex encoded into the user's clipboard
    ///
    /// Example output: `48 65 6c 6c 6f 20 57 6f 72 6c 64 21`
    ///
    /// - Parameter row: The index of the row. This is equal to the index of the message in the `messages` array.
    func copyHex(ofRow row: Int) {
        copy(row: row, withEncoding: OutputEncoding.hex)
    }
    
    @IBAction func rightClickDeleteRow(_ sender: NSMenuItem) {
        let row = messagesTableView.clickedRow
        remove(row: row)
    }
    
    @IBAction func rightClickCopyUTF8(_ sender: NSMenuItem) {
        let row = messagesTableView.clickedRow
        copyUTF8(ofRow: row)
    }
    
    @IBAction func rightClickCopyHex(_ sender: NSMenuItem) {
        let row = messagesTableView.clickedRow
        copyHex(ofRow: row)
    }
    
    @IBAction func menuDeleteRow(_ sender: NSMenuItem) {
        let row = messagesTableView.selectedRow
        remove(row: row)
    }
    
    @IBAction func menuCopyUTF8(_ sender: NSMenuItem) {
        let row = messagesTableView.selectedRow
        copyUTF8(ofRow: row)
    }
    
    @IBAction func menuCopyHex(_ sender: NSMenuItem) {
        let row = messagesTableView.selectedRow
        copyHex(ofRow: row)
    }
    

    func setSendingStatus(status: Bool) {
        // set sending ui elements
        messageTextField.isEnabled = status
        encodingPopUpButton.isEnabled = status
        sendButton.isEnabled = status
    }
    
    func enableSending() {
        setSendingStatus(status: true)
    }
    
    func disableSending() {
        setSendingStatus(status: false)
    }
    
    func setConnectingStatus(status: Bool) {
        // set connecting ui element
        hostTextField.isEnabled = status
        portTextField.isEnabled = status
        connectButton.title = status ? "Connect" : "Disconnect"
    }
    
    func enableConnecting() {
        setConnectingStatus(status: true)
    }
    
    func disableConnecting() {
        setConnectingStatus(status: false)
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
        var image: NSImage?
        var text = ""
        
        if tableColumn == tableView.tableColumns[0] {
            let date = Date(timeIntervalSince1970: rowData.time)
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .medium
            text = formatter.string(from: date)
        } else if tableColumn == tableView.tableColumns[1] {
            text = String(rowData.fromServer ? "Incomming" : "Outgoing")
            if rowData.fromServer {
                text = "Incomming"
                image = NSImage(named: "Down")
            } else {
                text = "Outgoing"
                image = NSImage(named: "Up")
            }
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
            cell.imageView?.image = image
            return cell
        }
        return nil
    }
}


extension ViewController: StreamDelegate {
    func initNetworkCommunication(host: CFString, port: UInt32) {
        disableSending()
        disableConnecting()
        connected = false
        
        var readStream:  Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(nil, host, port, &readStream, &writeStream)
        
        self.inputStream = readStream!.takeRetainedValue()
        self.outputStream = writeStream!.takeRetainedValue()
        
        self.inputStream.delegate = self
        self.outputStream.delegate = self
        
        self.inputStream.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        self.outputStream.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        
        self.inputStream.open()
        self.outputStream.open()
    }
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode{
        case Stream.Event.hasSpaceAvailable:
            enableSending()
            connected = true
            break
        case Stream.Event.hasBytesAvailable:
            if aStream == inputStream{
                var buffer = [UInt8](repeating: 0, count: self.maxBufferSize)
                var length: Int!
                
                while (inputStream.hasBytesAvailable) {
                    length = inputStream.read(&buffer, maxLength: self.maxBufferSize)
                    if length > 0 {
                        let data: Data = Data(bytes: &buffer, count: length)
                        addMessage(message: TCPMessage.init(time: getCurrentTime(), fromServer: true, encoding: .hex, message: data))
                    }
                }
            }
            break
        case Stream.Event.errorOccurred:
            disableSending()
            enableConnecting()
            connected = false
            break
        case Stream.Event.endEncountered:
            aStream.close()
            aStream.remove(from: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
            disableSending()
            enableConnecting()
            connected = false
            break
        default: break
        }
    }
    
    func setBufferSize(maxBufferSize: Int) {
        self.maxBufferSize = maxBufferSize
    }
    
    func send(data: Data) {
        self.outputStream.write(UnsafePointer<UInt8>(Array(data)), maxLength: data.count)
    }
}
