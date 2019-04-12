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

import XCTest
@testable import AbstractClassValidatorFramework

class SubclassUsageFilterTaskTests: BaseFrameworkTests {

    func test_execute_noExclusion_noAbstractClass_verifyResult() {
        let url = fixtureUrl(for: "NoAbstractClass.swift")
        let task = SubclassUsageFilterTask(url: url, exclusionSuffixes: [], exclusionPaths: [], abstractClassDefinitions: [])

        let result = try! task.execute()

        switch result {
        case .shouldProcess(_, _):
            XCTFail()
        case .skip:
            break
        }
    }

    func test_execute_suffixExclusion_hasAbstractClass_verifyResult() {
        let url = fixtureUrl(for: "ConcreteSubclass.swift")
        let task = SubclassUsageFilterTask(url: url, exclusionSuffixes: ["Subclass"], exclusionPaths: [], abstractClassDefinitions: [AbstractClassDefinition(name: "ParentAbstractClass", vars: [], methods: [], inheritedTypes: [])])

        let result = try! task.execute()

        switch result {
        case .shouldProcess(_, _):
            XCTFail()
        case .skip:
            break
        }
    }

    func test_execute_pathExclusion_hasAbstractClass_verifyResult() {
        let url = fixtureUrl(for: "ConcreteSubclass.swift")
        let task = SubclassUsageFilterTask(url: url, exclusionSuffixes: [], exclusionPaths: ["Fixtures/"], abstractClassDefinitions: [AbstractClassDefinition(name: "ParentAbstractClass", vars: [], methods: [], inheritedTypes: [])])

        let result = try! task.execute()

        switch result {
        case .shouldProcess(_, _):
            XCTFail()
        case .skip:
            break
        }
    }

    func test_execute_noExclusion_simpleSubclass_verifyResult() {
        let url = fixtureUrl(for: "ConcreteSubclass.swift")
        let task = SubclassUsageFilterTask(url: url, exclusionSuffixes: [], exclusionPaths: [], abstractClassDefinitions: [AbstractClassDefinition(name: "ParentAbstractClass", vars: [], methods: [], inheritedTypes: [])])

        let result = try! task.execute()

        switch result {
        case .shouldProcess(let processUrl, let content):
            XCTAssertEqual(processUrl, url)
            XCTAssertEqual(content, try! String(contentsOf: url))
        case .skip:
            XCTFail()
        }
    }

    func test_execute_noExclusion_genericSubclass_verifyResult() {
        let url = fixtureUrl(for: "GenericSuperConcreteSubclass.swift")
        let task = SubclassUsageFilterTask(url: url, exclusionSuffixes: [], exclusionPaths: [], abstractClassDefinitions: [AbstractClassDefinition(name: "GenericBaseClass", vars: [], methods: [], inheritedTypes: [])])

        let result = try! task.execute()

        switch result {
        case .shouldProcess(let processUrl, let content):
            XCTAssertEqual(processUrl, url)
            XCTAssertEqual(content, try! String(contentsOf: url))
        case .skip:
            XCTFail()
        }
    }
}
