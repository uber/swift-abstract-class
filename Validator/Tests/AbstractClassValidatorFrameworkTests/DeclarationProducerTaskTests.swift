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

class DeclarationProducerTaskTests: BaseFrameworkTests {

    func test_execute_noExclusion_fileWithMixedAbstractClasses_verifyResult() {
        let url = fixtureUrl(for: "MixedAbstractClasses.swift")
        let content = try! String(contentsOf: url)
        let task = DeclarationProducerTask(sourceUrl: url, sourceContent: content)

        let abstractClasses = try! task.execute()

        XCTAssertEqual(abstractClasses.count, 2)
        XCTAssertEqual(abstractClasses[0].name, "SAbstractVarClass")
        XCTAssertTrue(abstractClasses[0].methods.isEmpty)
        XCTAssertEqual(abstractClasses[0].vars.count, 1)
        XCTAssertEqual(abstractClasses[0].vars[0].name, "pProperty")

        XCTAssertEqual(abstractClasses[1].name, "KAbstractVarClass")
        XCTAssertEqual(abstractClasses[1].methods.count, 3)
        XCTAssertEqual(abstractClasses[1].methods[0].name, "someMethod()")

        XCTAssertEqual(abstractClasses[1].methods[1].name, "hahaMethod()")

        XCTAssertEqual(abstractClasses[1].methods[2].name, "paramMethod(_:b:)")

        XCTAssertEqual(abstractClasses[1].vars.count, 3)
        XCTAssertEqual(abstractClasses[1].vars[0].name, "someProperty")
        XCTAssertTrue(abstractClasses[1].vars[0].isAbstract)

        XCTAssertEqual(abstractClasses[1].vars[1].name, "nonAbstractProperty")
        XCTAssertFalse(abstractClasses[1].vars[1].isAbstract)

        XCTAssertEqual(abstractClasses[1].vars[2].name, "someBlahProperty")
        XCTAssertTrue(abstractClasses[1].vars[0].isAbstract)
    }

    func test_execute_noExclusion_noAbstractClass_verifyResult() {
        let url = fixtureUrl(for: "NoAbstractClass.swift")
        let content = try! String(contentsOf: url)
        let task = DeclarationProducerTask(sourceUrl: url, sourceContent: content)

        let abstractClasses = try! task.execute()

        XCTAssertTrue(abstractClasses.isEmpty)
    }

    func test_execute_noExclusion_fileWithInnerAbstractClasses_verifyResult() {
        let url = fixtureUrl(for: "NestedAbstractClasses.swift")
        let content = try! String(contentsOf: url)
        let task = DeclarationProducerTask(sourceUrl: url, sourceContent: content)

        let abstractClasses = try! task.execute()

        XCTAssertEqual(abstractClasses[0].name, "OutterAbstractClass")
        XCTAssertEqual(abstractClasses[0].methods.count, 2)
        XCTAssertFalse(abstractClasses[0].methods[0].isAbstract)
        XCTAssertEqual(abstractClasses[0].methods[0].name, "someMethod()")
        XCTAssertTrue(abstractClasses[0].methods[1].isAbstract)
        XCTAssertEqual(abstractClasses[0].methods[1].name, "paramMethod(_:b:)")
        XCTAssertEqual(abstractClasses[0].vars.count, 2)
        XCTAssertTrue(abstractClasses[0].vars[0].isAbstract)
        XCTAssertEqual(abstractClasses[0].vars[0].name, "someProperty")
        XCTAssertFalse(abstractClasses[0].vars[1].isAbstract)
        XCTAssertEqual(abstractClasses[0].vars[1].name, "nonAbstractProperty")

        XCTAssertEqual(abstractClasses[1].name, "InnerAbstractClassA")
        XCTAssertEqual(abstractClasses[1].methods.count, 1)
        XCTAssertTrue(abstractClasses[1].methods[0].isAbstract)
        XCTAssertEqual(abstractClasses[1].methods[0].name, "innerAbstractMethodA()")
        XCTAssertEqual(abstractClasses[1].vars.count, 0)

        XCTAssertEqual(abstractClasses[2].name, "InnerAbstractClassB")
        XCTAssertEqual(abstractClasses[2].methods.count, 1)
        XCTAssertTrue(abstractClasses[2].methods[0].isAbstract)
        XCTAssertEqual(abstractClasses[2].methods[0].name, "yoMethod()")
        XCTAssertEqual(abstractClasses[2].vars.count, 1)
        XCTAssertTrue(abstractClasses[2].vars[0].isAbstract)
        XCTAssertEqual(abstractClasses[2].vars[0].name, "innerAbstractVarB")
    }
}
