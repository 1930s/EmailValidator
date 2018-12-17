//
//  EmailValidatorSwiftUITests.swift
//  EmailValidatorSwiftUITests
//
//  Created by Hyuk Hur on 2018-11-25.
//  Copyright © 2018 Hyuk Hur. All rights reserved.
//

import XCTest

class EmailValidatorSwiftUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInputEmailAddress() {
        let app = XCUIApplication()
        let tf = app.tables.cells.textFields["Email Address"]
        let cb = tf.buttons["Clear text"]

        tf.tap()
        XCTAssertFalse(cb.exists)
        tf.typeText("email")
        XCTAssertTrue(cb.waitForExistence(timeout: 1))
        XCTAssertTrue(cb.isHittable)
        cb.tap()
        XCTAssertFalse(cb.exists)
        tf.typeText("email")
        XCTAssertTrue(cb.waitForExistence(timeout: 1))
        XCTAssertTrue(cb.isHittable)
        tf.typeText("@email.com")
        XCTAssertFalse(cb.exists)
        app.keyboards.buttons["Join:"].tap()
    }

    func testDeleteString() {
        let app = XCUIApplication()
        let tf = app.tables.cells.textFields["Email Address"]
        let cb = tf.buttons["Clear text"]

        tf.tap()
        tf.typeText("email@email.com.")
        XCTAssertTrue(cb.waitForExistence(timeout: 1))
        XCTAssertTrue(cb.isHittable)
        tf.typeText(XCUIKeyboardKey.delete.rawValue)
        XCTAssertFalse(cb.exists)
        app.keyboards.buttons["Join:"].tap()
    }

    func _testEmptyStringShowClearButton() {
        let app = XCUIApplication()
        let tf = app.tables.cells.textFields["Email Address"]
        let cb = tf.buttons["Clear text"]

        XCTAssertFalse(cb.exists)
        tf.tap()
        XCTAssertFalse(cb.exists)
        tf.typeText("email@email.com")
        XCTAssertFalse(cb.exists)
        tf.typeText(XCUIKeyboardKey.delete.rawValue)
        XCTAssertTrue(cb.exists)
        app.keyboards.buttons["Join:"].tap()
    }
}
