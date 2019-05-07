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

class ExpressionCallValidationTaskTests: BaseFrameworkTests {

    private var abstractClassDefinition: AbstractClassDefinition!

    override func setUp() {
        super.setUp()

        let abstractVarDefinition = VarDefinition(name: "abVar", isAbstract: true, isOverride: false)
        abstractClassDefinition = AbstractClassDefinition(name: "SomeAbstractC", vars: [abstractVarDefinition], methods: [], inheritedTypes: [])
    }

    func test_execute_noUsage_verifyResult() {
        let url = fixtureUrl(for: "NoAbstractClass.swift")
        let content = try! String(contentsOf: url)
        let task = ExpressionCallValidationTask(sourceUrl: url, sourceContent: content, abstractClassDefinitions: [abstractClassDefinition])

        let result = try! task.execute()
        switch result {
        case .success:
            break
        default:
            XCTFail()
        }
    }

    func test_execute_hasSubclassUsage_noViolations() {
        let url = fixtureUrl(for: "UsageSubclass.swift")
        let content = try! String(contentsOf: url)
        let task = ExpressionCallValidationTask(sourceUrl: url, sourceContent: content, abstractClassDefinitions: [abstractClassDefinition])

        let result = try! task.execute()
        switch result {
        case .success:
            break
        default:
            XCTFail()
        }
    }

    func test_execute_hasTypeUsage_noViolations() {
        let url = fixtureUrl(for: "UsageType.swift")
        let content = try! String(contentsOf: url)
        let task = ExpressionCallValidationTask(sourceUrl: url, sourceContent: content, abstractClassDefinitions: [abstractClassDefinition])

        let result = try! task.execute()
        switch result {
        case .success:
            break
        default:
            XCTFail()
        }
    }

    func test_execute_hasIViolations() {
        let url = fixtureUrl(for: "ViolateInstantiation.swift")
        let content = try! String(contentsOf: url)
        let task = ExpressionCallValidationTask(sourceUrl: url, sourceContent: content, abstractClassDefinitions: [abstractClassDefinition])

        let result = try! task.execute()
        switch result {
        case .failureWithReason(let reason):
            XCTAssertTrue(reason.contains(abstractClassDefinition.name))
            XCTAssertTrue(reason.contains(url.path))
        default:
            XCTFail()
        }
    }
}
