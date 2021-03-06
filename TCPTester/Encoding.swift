//
//  Encoding.swift
//  TCPTester
//
//  Created by Noah Peeters on 5/6/17.
//  Copyright © 2017 Noah Peeters. All rights reserved.
//

import Foundation


/// Encodings used by the user to input data
///
/// - hex: Used to input raw hexadecimal data. Example input: `48 65 6c 6c 6f 20 57 6f 72 6c 64 21`
/// - utf8: Used to input utf-8 encoded stings. Example input: `Hello World!`
/// - mixed_utf8: Used to input utf-8 encoded stings with special escapes. Example input: `Hello World\21`
enum InputEncoding: String {
    case hex = "Hex"
    case utf8 = "UTF-8"
    case mixed_utf8 = "Mixed UTF-8"

    /// Decodes a string with an `InputEncoding`
    ///
    /// - Parameter input: The input string. Usually entered by the user.
    /// - Returns: The raw data output
    func decode(input: String) -> Data? {
        switch self {
        case .hex:
            return Data(hex: input.replacingOccurrences(of: " ", with: ""))
        case .utf8:
            return input.data(using: .utf8)
        case .mixed_utf8:
            return Data()
        }
    }
}

enum OutputEncoding: String {
    case hex = "Hex"
    case utf8 = "UTF-8"
    
    /// Inits the `OutputEncoding` with an `InputEncoding`. Used to output data, which were decoded with an encoding.
    ///
    /// - Parameter inputEncoding: The `InputEncoding` witch will be converted
    init(from inputEncoding: InputEncoding) {
        switch inputEncoding {
        case .hex:
            self = .hex
            break
        case .utf8:
            self = .utf8
            break
        case .mixed_utf8:
            self = .utf8
        }
    }
    
    /// Encodes data with an `OutputEncoding`
    ///
    /// - Parameter data: The input data. Usually saved somewhere or received by a server.
    /// - Returns: The encoded string.
    func encode(data: Data) -> String {
        switch self {
        case .hex:
            return data.map { String(format: "%02hhx", $0) }.joined(separator: " ")
        case .utf8:
            return String(data: data, encoding: String.Encoding.utf8) ?? "<Error>"
        }
    }
}


extension UnicodeScalar {
    var hexNibble: UInt8? {
        let value = self.value
        if 48 <= value && value <= 57 {
            return UInt8(value - 48)
        }
        else if 65 <= value && value <= 70 {
            return UInt8(value - 55)
        }
        else if 97 <= value && value <= 102 {
            return UInt8(value - 87)
        }
        return nil
    }
}

extension Data {
    init?(hex:String) {
        let scalars = hex.unicodeScalars
        var bytes = Array<UInt8>(repeating: 0, count: (scalars.count + 1) >> 1)
        for (index, scalar) in scalars.enumerated() {
            if var nibble = scalar.hexNibble {
                if index & 1 == 0 {
                    nibble <<= 4
                }
                bytes[index >> 1] |= nibble
            } else {
                return nil
            }
        }
        self = Data(bytes: bytes)
    }
}
