//
//  TCPTestData.swift
//  TCPTester
//
//  Created by Noah Peeters on 5/5/17.
//  Copyright © 2017 Noah Peeters. All rights reserved.
//

import Foundation

class TCPTestData {
    var host: String = "127.0.0.1";
    var port: String = "22";
    var messages: [TCPMessage] = [];
    
    init(host: String = "127.0.0.1", port: String = "22") {
        self.host = host
        self.port = port
    }
    
    init(fromJsonData data: Data) throws {
        guard let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String: Any],
            let host = json["host"] as? String,
            let port = json["port"] as? String,
            let messages = json["messages"] as? [[String: Any]]
            else {
                throw NSError(domain: "Cannot open file.", code: errAECorruptData, userInfo: nil)
        }
        
        self.host = host
        self.port = port
        self.messages = []
        
        for rawMessage in messages {
            if let message = TCPMessage.init(json: rawMessage) {
                self.messages.append(message)
            }
        }
    }

    
    func getJsonObject() -> [String: Any] {
        
        var jsonMessages: [[String: Any]] = []
        
        for message in messages {
            jsonMessages.append(message.getJsonObject())
        }
        
        return [
            "version": "1.0",
            "host": host,
            "port": port,
            "messages": jsonMessages
        ]
    }
    
    func getJsonData() throws -> Data {
        return try JSONSerialization.data(withJSONObject: getJsonObject(), options: JSONSerialization.WritingOptions())
    }    
}

class TCPMessage {
    var time: Double;
    var fromServer: Bool;
    var encoding: OutputEncoding;
    var message: Data;
    
    init(time: Double, fromServer: Bool, encoding: OutputEncoding, message: Data) {
        self.time = time;
        self.fromServer = fromServer
        self.encoding = encoding
        self.message = message
    }
    
    init?(json: [String: Any]) {
        guard let time = json["time"] as? Double,
            let fromServer = json["fromServer"] as? Bool,
            let encodingRawValue = json["encoding"] as? String,
            let encoding = OutputEncoding(rawValue: encodingRawValue),
            let base64message = json["message"] as? String,
            let message = Data(base64Encoded: base64message, options: .ignoreUnknownCharacters)
            else {
                return nil
        }
        
        self.message = message
        
        self.time = time
        self.fromServer = fromServer
        self.encoding = encoding
    }
    
    func getJsonObject() -> [String: Any] {
        return [
            "time": time,
            "fromServer": fromServer,
            "encoding": encoding.rawValue,
            "message": message.base64EncodedString()
        ]
    }
    
    func getEncodedMessage() -> String {
        return encoding.encode(data: message)
    }
}

