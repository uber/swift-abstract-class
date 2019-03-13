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

class AbstractClassDeclarationProducerTaskTests: BaseFrameworkTests {

    func test_execute_noExclusion_abstractClass_verifyResult() {
        let url = fixtureUrl(for: "MixedAbstractClasses.swift")
        let content = try! String(contentsOf: url)
        let task = AbstractClassDeclarationProducerTask(sourceUrl: url, sourceContent: content)

        let abstractClasses = try! task.execute()

        XCTAssertEqual(abstractClasses.count, 2)
        XCTAssertEqual(abstractClasses[0].name, "SAbstractVarClass")
        XCTAssertTrue(abstractClasses[0].abstractMethods.isEmpty)
        XCTAssertEqual(abstractClasses[0].abstractVars.count, 1)
        XCTAssertEqual(abstractClasses[0].abstractVars[0].name, "pProperty")
        XCTAssertEqual(abstractClasses[0].abstractVars[0].returnType, "Object")

        XCTAssertEqual(abstractClasses[1].name, "KAbstractVarClass")
        XCTAssertEqual(abstractClasses[1].abstractMethods.count, 2)
        XCTAssertEqual(abstractClasses[1].abstractMethods[0].name, "hahaMethod()")
        XCTAssertEqual(abstractClasses[1].abstractMethods[0].returnType, "Haha")
        XCTAssertTrue(abstractClasses[1].abstractMethods[0].parameterTypes.isEmpty)

        XCTAssertEqual(abstractClasses[1].abstractMethods[1].name, "paramMethod(_:b:)")
        XCTAssertEqual(abstractClasses[1].abstractMethods[1].returnType, "PPP")
        XCTAssertEqual(abstractClasses[1].abstractMethods[1].parameterTypes.count, 2)
        XCTAssertEqual(abstractClasses[1].abstractMethods[1].parameterTypes[0], "HJJ")
        XCTAssertEqual(abstractClasses[1].abstractMethods[1].parameterTypes[1], "Bar")

        XCTAssertEqual(abstractClasses[1].abstractVars[0].name, "someProperty")
        XCTAssertEqual(abstractClasses[1].abstractVars[0].returnType, "Int")
        XCTAssertEqual(abstractClasses[1].abstractVars[1].name, "someBlahProperty")
        XCTAssertEqual(abstractClasses[1].abstractVars[1].returnType, "Blah")
    }

    func test_execute_noExclusion_noAbstractClass_verifyResult() {
        let url = fixtureUrl(for: "NoAbstractClass.swift")
        let content = try! String(contentsOf: url)
        let task = AbstractClassDeclarationProducerTask(sourceUrl: url, sourceContent: content)

        let abstractClasses = try! task.execute()

        XCTAssertTrue(abstractClasses.isEmpty)
    }
}
