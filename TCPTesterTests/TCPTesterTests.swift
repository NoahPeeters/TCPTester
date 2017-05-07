//
//  TCPTesterTests.swift
//  TCPTesterTests
//
//  Created by Noah Peeters on 5/5/17.
//  Copyright © 2017 Noah Peeters. All rights reserved.
//

import XCTest
@testable import TCPTester

class TCPTesterTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let data = Data(bytes: [0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x20, 0x57, 0x6f, 0x72, 0x6c, 0x64, 0x21])
        
        let encoding = OutputEncoding.utf8
        
        XCTAssertEqual(encoding.encode(data: data), "Hello World!")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            
            for _ in 0...100 {
                let data = Data(bytes: [0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x20, 0x57, 0x6f, 0x72, 0x6c, 0x64, 0x21])
                
                let encoding = OutputEncoding.utf8
                
                XCTAssertEqual(encoding.encode(data: data), "Hello World!")
            }
        }
    }
    
}
