//
//  EmailValidatorSwiftTests.swift
//  EmailValidatorSwiftTests
//
//  Created by Hyuk Hur on 2018-11-25.
//  Copyright © 2018 Hyuk Hur. All rights reserved.
//

import XCTest
@testable import EmailValidatorSwift

class EmailValidatorSwiftTests: XCTestCase {

    let emailValidators: [EmailPattern] = [EmailRegularExpressionPattern(), EmailUrlPattern()]
    let largeEmails = [
        "alex@gmail.com","alex@gmail.com","alex@gmail.com","alex@gmail.com","alex@gmail.com","alex@gmail.com","alex@gmail.com","alex@gmail.com","alex@gmail.com",
        "alexalexalexalexalexalexalexalexalexalexalexalexalexalexalexalexalexalexalexalexalexalexalexalexalexalexalexalexalexalexalexalexalexalex@gmailalex.com",
        "alex@gmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmail.com",
        "alex@gmail.comcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcom",
"alexalexalexalexalexalexalexalexalexalexalexalexalexalexalexalexalexalexalexalexalexalexalexalexalexalexalexalexalexalexalexalexalexalex@gmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmail.comcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmailgmail.comcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcomcom",
        ]
    /**
     Email format validation
     * Example: "alex@gmail" is not a valid email
     * The user interface should indicate whether or not the email address is valid
     * Where appropriate the interface should indicate what is wrong with the address
     */
    func testFullEmail() {
        emailValidators.forEach { emailValidator in
            XCTAssertTrue(emailValidator.isValid("alex@gmail.com"))
            XCTAssertTrue(emailValidator.isValid("alex.lim@gmail.com"))
            XCTAssertTrue(emailValidator.isValid("alex.lim@gmail.ca"))
            XCTAssertTrue(emailValidator.isValid("alex.lim@gmail.co.jp"))

            XCTAssertFalse(emailValidator.isValid("alex.lim@gmail.com."))
            XCTAssertFalse(emailValidator.isValid("alex.lim@gmail...com"))
            XCTAssertFalse(emailValidator.isValid("alex.lim@gma il.com"))

            XCTAssertFalse(emailValidator.isValid("alex@gmail"))
            XCTAssertFalse(emailValidator.isValid("alex@.com"))
            XCTAssertFalse(emailValidator.isValid("alex@gmailcom"))
            XCTAssertFalse(emailValidator.isValid("gmail.com"))
            XCTAssertFalse(emailValidator.isValid("alexgmail.com"))
            XCTAssertFalse(emailValidator.isValid("http://alex@gmail.com"))
            XCTAssertFalse(emailValidator.isValid("alex:passwd@gmail.com"))
            XCTAssertFalse(emailValidator.isValid("alex@gmail.com/path"))
            XCTAssertFalse(emailValidator.isValid("alex@gmail.com/?query"))
            XCTAssertFalse(emailValidator.isValid("alex@gmail.com?query"))
            XCTAssertFalse(emailValidator.isValid("alex@gmail.com/$fragment"))
            XCTAssertFalse(emailValidator.isValid("alex@gmail.com$fragment"))
        }
    }

    func _testExtreamEmail() {
        emailValidators.forEach { emailValidator in
            let over63DomainName = "alex.lim@1234567890123456789012345678901234567890123456789012345678901234.com"
            XCTAssertFalse(emailValidator.isValid(over63DomainName))
            let over64userName = "123456789012345678901234567890123456789012345678901234567890123@gmail.com"
            XCTAssertFalse(emailValidator.isValid(over64userName))
            let over256Address = "1234567890123456789012345678901234567890123456789012345678901234" +
                "1234567890123456789012345678901234567890123456789012345678901234" +
                "1234567890123456789012345678901234567890123456789012345678901234" +
                "1234567890123456789012345678901234567890123456789012345678901234" +
            "@gmail.com"
            XCTAssertFalse(emailValidator.isValid(over256Address))
        }
    }

    func _testFullEmailUndefined() {
        XCTAssertFalse(emailValidators[0].isValid("alex?query@gmail.com"))
        XCTAssertFalse(emailValidators[0].isValid("alex#fragment@gmail.com"))
        XCTAssertFalse(emailValidators[0].isValid("alex/path@gmail.com"))
        XCTAssertFalse(emailValidators[0].isValid("alex@sub.gmail.com"))
        XCTAssertFalse(emailValidators[0].isValid("alex.lim@gmail.co.tv.jp"))
    }

    func testLengthOfURI() {
        largeEmails.dropLast().map(emailValidators.first!.isValid).forEach {
            XCTAssertTrue($0)
        }
//        [largeEmails.last!].forEach({
//            emailValidators.first!.isValid($0){ XCTAssertFalse($0) }
//        })
    }

    func testPerformanceRegEx() {
        self.measure {
            largeEmails.dropLast().map(emailValidators.first!.isValid).forEach({
                XCTAssertTrue($0)
            })
        }
    }

    func testPerformanceURL() {
        self.measure {
            largeEmails.map(emailValidators.last!.isValid).forEach({
                XCTAssertTrue($0)
            })
        }
    }


    func testLegalCharactors() {
        emailValidators.forEach { emailValidator in
            XCTAssertTrue(emailValidator.legalCharacter(string: "@"))
            XCTAssertTrue(emailValidator.legalCharacter(string: "."))
            XCTAssertTrue(emailValidator.legalCharacter(string: "e"))
            XCTAssertTrue(emailValidator.legalCharacter(string: "email"))

            XCTAssertFalse(emailValidator.legalCharacter(string: "\t"))
            XCTAssertFalse(emailValidator.legalCharacter(string: "\n"))
            XCTAssertFalse(emailValidator.legalCharacter(string: " "))
            XCTAssertFalse(emailValidator.legalCharacter(string: ":"))
            XCTAssertFalse(emailValidator.legalCharacter(string: "//"))
        }
    }
}

class EmailDeliverabilitySwiftTests: XCTestCase {
    let delivers: [EmailDeliverable] = [EmailKickboxDeliver(), EmailURLRequestDeliver()]

    /**
     Email deliverability validation
     * Users often typo an address, for example wrong domain name (gmail.con vs gmail.com), or just mis type it
     * Use an existing API to confirm the email address can be delivered to, we recommend getting a free account at kickbox.io, and using their API
     * Where appropriate the interface should indicate what is wrong
     */
    func testDeliverability() {
        delivers.forEach { deliver in
            let deliverableExpectations = [expectation(description: "no-reply+deliverable@accounts.google.com"),
                                           expectation(description: "no-reply+deliverable@accounts.google.ca"),
                                           expectation(description: "no-reply+deliverable@accounts.google.ca"),
                                           expectation(description: "no-reply+rejected-email@accounts.google.con"),
                                           expectation(description: "no-reply+rejected-email@accounts.gooogl.co.kr")]
            deliver.deliver("no-reply+deliverable@accounts.google.com") {
                XCTAssertTrue($0)
                XCTAssertTrue("no-reply+deliverable@accounts.google.com".contains($1))
                deliverableExpectations[0].fulfill()
            }
            deliver.deliver("no-reply+deliverable@accounts.google.ca") {
                XCTAssertTrue($0)
                XCTAssertTrue("no-reply+deliverable@accounts.google.ca".contains($1))
                deliverableExpectations[1].fulfill()
            }
            deliver.deliver("no-reply+deliverable@accounts.google.co.jp") {
                XCTAssertTrue($0)
                XCTAssertTrue("no-reply+deliverable@accounts.google.co.jp".contains($1))
                deliverableExpectations[2].fulfill()
            }
            deliver.deliver("no-reply+rejected-email@accounts.google.con") {
                XCTAssertFalse($0)
                XCTAssertTrue("no-reply+rejected-email@accounts.google.con".contains($1))
                deliverableExpectations[3].fulfill()
            }
            deliver.deliver("no-reply+rejected-email@accounts.gooogl.co.kr") {
                XCTAssertFalse($0)
                XCTAssertTrue("no-reply+rejected-email@accounts.gooogl.co.kr".contains($1))
                deliverableExpectations[4].fulfill()
            }
            waitForExpectations(timeout: 5)
        }
    }

    class MockDeliver: EmailDeliverable {
        var deliverable: Bool = false
        func deliver(_ email: String, completion: @escaping (Bool, String) -> Void) {
            completion(deliverable, email)
        }
    }

    var mock = MockDeliver()
    lazy var cache: EmailCachedDeliver = EmailCachedDeliver(deliver: self.mock)

    func testCacheMissWithUndeliverable() {
        self.mock.deliverable = false

        let key = "email"
        XCTAssertFalse(cache.isHit(cacheKey: key))
        let exp = expectation(description: "testCacheMissWithUndeliverable")

        cache.deliver(key) { (success, _) in
            XCTAssertFalse(success)
            XCTAssertTrue(self.cache.isHit(cacheKey: key))

            DispatchQueue.main.async {
                self.mock.deliverable = true
                self.cache.deliver(key) { (success, _) in
                    XCTAssertFalse(success)
                    XCTAssertTrue(self.cache.isHit(cacheKey: key))
                    exp.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 0.3)
    }


    func testCacheMissWithDeliverable() {
        self.mock.deliverable = true
        let key = "email"
        XCTAssertFalse(cache.isHit(cacheKey: key))
        let exp = expectation(description: "testCacheMissWithDeliverable")

        cache.deliver(key) { (success, _) in
            XCTAssertTrue(success)
            XCTAssertTrue(self.cache.isHit(cacheKey: key))

            DispatchQueue.main.async {
                self.mock.deliverable = false
                self.cache.deliver(key) { (success, _) in
                    XCTAssertTrue(success)
                    XCTAssertTrue(self.cache.isHit(cacheKey: key))
                    exp.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 0.3)
    }

    func testCacheExpire() {
        self.mock.deliverable = false
        self.cache.expireCount = 2

        let key = "email"
        XCTAssertFalse(cache.isHit(cacheKey: key))
        let exp = expectation(description: "testCacheExpire")

        cache.deliver(key) { (success, _) in
            XCTAssertFalse(success)
            XCTAssertTrue(self.cache.isHit(cacheKey: key))

            self.mock.deliverable = true
            DispatchQueue.main.async {
                self.cache.deliver(key) { (success, _) in
                    XCTAssertFalse(success)
                    XCTAssertFalse(self.cache.isHit(cacheKey: key))

                    DispatchQueue.main.async {
                        self.cache.deliver(key) { (success, _) in
                            XCTAssertTrue(success)
                            XCTAssertTrue(self.cache.isHit(cacheKey: key))
                            exp.fulfill()
                        }
                    }
                }
            }
        }
        waitForExpectations(timeout: 0.3)
    }

    func testCacheHitWithDeliverable() {
        self.mock.deliverable = true
        let key = "email"
        let exp = expectation(description: "testCacheHitWithDeliverable")

        cache.deliver(key) { _,_ in }
        XCTAssertTrue(self.cache.isHit(cacheKey: key))
        cache.deliver(key) { success,_ in
            XCTAssertTrue(success)
            XCTAssertTrue(self.cache.isHit(cacheKey: key))
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.3)
    }

    func testClearCache() {
        self.mock.deliverable = false
        let key = "email"
        let exp = expectation(description: "testClearCache")

        XCTAssertFalse(self.cache.isHit(cacheKey: key))
        cache.deliver(key) { _,_ in }
        XCTAssertTrue(self.cache.isHit(cacheKey: key))
        cache.clear(cacheKey: key)
        XCTAssertFalse(self.cache.isHit(cacheKey: key))
        cache.deliver(key) { success,_ in
            XCTAssertFalse(success)
            XCTAssertTrue(self.cache.isHit(cacheKey: key))

            self.cache.clearAll()
            XCTAssertFalse(self.cache.isHit(cacheKey: key))

            exp.fulfill()
        }
        waitForExpectations(timeout: 0.3)
    }

}

class EmailAutocompleteSwiftTests: XCTestCase {
    let suggestor = EmailPresetSuggestor(preset: ["gmail.com", "yahoo.com", "ymail.com", "yahoo.co.uk", "gmail.co.uk", "yahoo.ca", "gmail.ca", "github.com"])

    /**
     Autocomplete domain names
     * Typing email addresses is a pain, wouldn't it be nice if we didn't have to type the whole thing in?
     * We have observed that most email addresses end in popular domain names such as gmail.com, yahoo.com
     * Your autocomplete should suggest likely domain names and complete addresses
     * For example if the user types "alex@" we'd expect suggestions based on most popular domains, say "alex@gmail.com", "alex@yahoo.com", ...
     * If the user refines and types "alex@g" we'd expect suggestions based on popular domains beginning with g eg "alex@gmail.com", "alex@gmail.co.uk", ...
     */
    func testAutocompleteDomainNames() {
        XCTAssertTrue(suggestor.suggest("test@").contains(where: {
            return ["gmail.com", "yahoo.com"].contains($0)
        }))
        XCTAssertTrue(suggestor.suggest("test@g").contains(where: {
            return ["gmail.com", "gmail.co.uk", "github.com"].contains($0)
        }))
        XCTAssertTrue(suggestor.suggest("test@gi").contains(where: {
            return ["github.com"].contains($0)
        }))
        XCTAssertTrue(suggestor.suggest("test@y").contains(where: {
            return ["yahoo.com", "yahoo.ca"].contains($0)
        }))
        XCTAssertTrue(suggestor.suggest("test@yfejkwfjefl.com").isEmpty)
    }

    func testAutocompleteDomainNamesNotDuplicated() {
        XCTAssertTrue(suggestor.suggest("email@gmail.com").isEmpty)
        XCTAssertTrue(suggestor.suggest("gmail.com").isEmpty)
        XCTAssertTrue(suggestor.suggest("@gmail.com").isEmpty)
        XCTAssertTrue(suggestor.suggest("").isEmpty)
        XCTAssertTrue(suggestor.suggest("@").isEmpty)
        XCTAssertTrue(suggestor.suggest("username").isEmpty)
    }
}


class EmailValidatorIntegrationTests: XCTestCase {
    let validator = EmailValidator.regExAndKickbox
    func testSatisfyCondition() {
        let validatorExpectation = expectation(description: "no-reply+deliverable@accounts.google.com")
        validator.satisfy("no-reply+deliverable@accounts.google.com") {
            XCTAssertTrue($0)
            validatorExpectation.fulfill()
        }
        wait(for: [validatorExpectation], timeout: 0.3)
    }
    func testNoSatisfyCondition() {
        let validatorExpectation = expectation(description: "no-reply+rejected-email@accounts.google.con")
        validator.satisfy("no-reply+rejected-email@accounts.google.con") {
            XCTAssertFalse($0)
            validatorExpectation.fulfill()
        }
        wait(for: [validatorExpectation], timeout: 0.3)
    }
}
