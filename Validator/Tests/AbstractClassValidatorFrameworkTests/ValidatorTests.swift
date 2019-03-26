//
//  Copyright (c) 2018. Uber Technologies
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import SourceKittenFramework
import SourceParsingFramework
import XCTest
@testable import AbstractClassValidatorFramework

class ValidatorTests: BaseFrameworkTests {

    func test_validate_noExclusions_withNoViolations_verifySuccess() {
        let sourceRoot = fixtureUrl(for: "/Integration/Valid/")

        try! Validator().validate(from: [sourceRoot.path], excludingFilesEndingWith: [], excludingFilesWithPaths: [], shouldCollectParsingInfo: false, timeout: 10, concurrencyLimit: nil)
    }

    func test_validate_exclusionPath_withViolations_verifySuccess() {
        let sourceRoot = fixtureUrl(for: "/Integration/Invalid/")

        try! Validator().validate(from: [sourceRoot.path], excludingFilesEndingWith: [], excludingFilesWithPaths: ["/Integration"], shouldCollectParsingInfo: false, timeout: 10, concurrencyLimit: nil)
    }

    func test_validate_exclusionSuffix_withViolations_verifySuccess() {
        let sourceRoot = fixtureUrl(for: "/Integration/Invalid/")

        try! Validator().validate(from: [sourceRoot.path], excludingFilesEndingWith: ["Concrete", "Instantiation"], excludingFilesWithPaths: [], shouldCollectParsingInfo: false, timeout: 10, concurrencyLimit: nil)
    }

    func test_validate_noExclusions_withExpressionCallViolations_verifyError() {
        let sourceRoot = fixtureUrl(for: "/Integration/Invalid/ExpressionCall/")

        do {
            try Validator().validate(from: [sourceRoot.path], excludingFilesEndingWith: [], excludingFilesWithPaths: [], shouldCollectParsingInfo: false, timeout: 10, concurrencyLimit: nil)
            XCTFail()
        } catch GenericError.withMessage(let message) {
            XCTAssertTrue(message.contains("ChildAbstract"))
            XCTAssertTrue(message.contains("/Fixtures/Integration/Invalid/ExpressionCall/AbstractInstantiation.swift"))
        } catch {
            XCTFail()
        }
    }

    func test_validate_noExclusions_withImplementationViolations_verifyError() {
        let sourceRoot = fixtureUrl(for: "/Integration/Invalid/Implementation/")

        do {
            try Validator().validate(from: [sourceRoot.path], excludingFilesEndingWith: [], excludingFilesWithPaths: [], shouldCollectParsingInfo: false, timeout: 10, concurrencyLimit: nil)
            XCTFail()
        } catch GenericError.withMessage(let message) {
            XCTAssertTrue(message.contains("ChildConcrete"))
            XCTAssertTrue(message.contains("(cAbstractVar: CVar)"))
        } catch {
            XCTFail()
        }
    }
}
