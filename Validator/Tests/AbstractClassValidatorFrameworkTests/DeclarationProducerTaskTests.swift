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
        XCTAssertEqual(abstractClasses[0].abstractMethods.count, 1)
        XCTAssertTrue(abstractClasses[0].abstractMethods[0].isAbstract)
        XCTAssertEqual(abstractClasses[0].abstractMethods[0].name, "paramMethod(_:b:)")
        XCTAssertEqual(abstractClasses[0].abstractMethods[0].returnType, "PPP")
        XCTAssertEqual(abstractClasses[0].abstractMethods[0].parameterTypes.count, 2)
        XCTAssertEqual(abstractClasses[0].abstractMethods[0].parameterTypes[0], "HJJ")
        XCTAssertEqual(abstractClasses[0].abstractMethods[0].parameterTypes[1], "Bar")
        XCTAssertEqual(abstractClasses[0].abstractVars.count, 1)
        XCTAssertTrue(abstractClasses[0].abstractVars[0].isAbstract)
        XCTAssertEqual(abstractClasses[0].abstractVars[0].name, "someProperty")
        XCTAssertEqual(abstractClasses[0].abstractVars[0].returnType, "Int")

        XCTAssertEqual(abstractClasses[1].name, "InnerAbstractClassA")
        XCTAssertEqual(abstractClasses[1].abstractMethods.count, 1)
        XCTAssertTrue(abstractClasses[1].abstractMethods[0].isAbstract)
        XCTAssertEqual(abstractClasses[1].abstractMethods[0].name, "innerAbstractMethodA()")
        XCTAssertNil(abstractClasses[1].abstractMethods[0].returnType)
        XCTAssertEqual(abstractClasses[1].abstractVars.count, 0)

        XCTAssertEqual(abstractClasses[2].name, "InnerAbstractClassB")
        XCTAssertEqual(abstractClasses[2].abstractMethods.count, 1)
        XCTAssertTrue(abstractClasses[2].abstractMethods[0].isAbstract)
        XCTAssertEqual(abstractClasses[2].abstractMethods[0].name, "yoMethod()")
        XCTAssertEqual(abstractClasses[2].abstractMethods[0].parameterTypes.count, 0)
        XCTAssertEqual(abstractClasses[2].abstractMethods[0].returnType, "Yo")
        XCTAssertEqual(abstractClasses[2].abstractVars.count, 1)
        XCTAssertTrue(abstractClasses[2].abstractVars[0].isAbstract)
        XCTAssertEqual(abstractClasses[2].abstractVars[0].name, "innerAbstractVarB")
        XCTAssertEqual(abstractClasses[2].abstractVars[0].returnType, "Int")
    }
}
