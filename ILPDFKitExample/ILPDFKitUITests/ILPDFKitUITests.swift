//
//  ILPDFKitUITests.swift
//  ILPDFKitUITests
//
//  Created by Derek Blair on 2017-04-14.
//  Copyright © 2017 Derek Blair. All rights reserved.
//

import XCTest


class ILPDFKitUITests: XCTestCase {

    var app : XCUIApplication!

    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app = XCUIApplication()
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBasicFormAppearance() {
        let field = app.textFields["PersonalInformation[0].Surname[0]"]
        let fieldExists = NSPredicate(format: "exists == true")
        expectation(for: fieldExists, evaluatedWith: field, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
    }
    
}
