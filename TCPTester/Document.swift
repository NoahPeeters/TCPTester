//
//  Document.swift
//  TCPTester
//
//  Created by Noah Peeters on 5/5/17.
//  Copyright © 2017 Noah Peeters. All rights reserved.
//

import Foundation
import Cocoa

class Document: NSDocument {
    var tcpTestData: TCPTestData
    
    override init() {
        tcpTestData = TCPTestData()
        super.init()
    }

    override class func autosavesInPlace() -> Bool {
        return true
    }
    
    override var windowNibName: String? {
        return "New TCPTest"
    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: "Document Window Controller") as! NSWindowController
        self.addWindowController(windowController)
        
        let vc = windowController.contentViewController as! ViewController
        vc.hostTextField.stringValue = tcpTestData.host
        vc.portTextField.stringValue = tcpTestData.port
        vc.messages = tcpTestData.messages
        vc.messagesTableView.reloadData()
    }

    override func data(ofType typeName: String) throws -> Data {
        if let vc = self.windowControllers[0].contentViewController as? ViewController {
            tcpTestData.host = vc.hostTextField.stringValue
            tcpTestData.port = vc.portTextField.stringValue
            tcpTestData.messages = vc.messages
        }
        
        return try tcpTestData.getJsonData()
    }

    override func read(from data: Data, ofType typeName: String) throws {
        try tcpTestData = TCPTestData.init(fromJsonData: data)
    }
}
