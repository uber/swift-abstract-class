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

class ConcreteSubclassProducerTaskTests: BaseFrameworkTests {

    func test_execute_hasAbstractSubclass_verifyNoDefinitions() {
        let url = fixtureUrl(for: "MiddleAbstractClass.swift")
        let content = try! String(contentsOf: url)
        let abstractClassDefinitions = [AbstractClassDefinition(name: "GrandParentAbstractClass", vars: [VarDefinition(name: "grandParentVar", returnType: "GrandParentVar", isAbstract: true)], methods: [], inheritedTypes: ["AbstractClass"])]

        let task = ConcreteSubclassProducerTask(sourceUrl: url, sourceContent: content, abstractClassDefinitions: abstractClassDefinitions)

        let concreteDefinitions = try! task.execute()

        XCTAssertTrue(concreteDefinitions.isEmpty)
    }

    func test_execute_hasConcreteSubclasses_verifyDefinitions() {
        let url = fixtureUrl(for: "ConcreteSubclass.swift")
        let content = try! String(contentsOf: url)
        let abstractClassDefinitions = [
            AbstractClassDefinition(name: "GrandParentAbstractClass", vars: [VarDefinition(name: "grandParentVar", returnType: "GrandParentVar", isAbstract: true)], methods: [], inheritedTypes: ["AbstractClass"]),
            AbstractClassDefinition(name: "ParentAbstractClass", vars: [], methods: [MethodDefinition(name: "parentMethod(index:)", returnType: "String", parameterTypes: ["Int"], isAbstract: true)], inheritedTypes: ["GrandParentAbstractClass"])
        ]

        let task = ConcreteSubclassProducerTask(sourceUrl: url, sourceContent: content, abstractClassDefinitions: abstractClassDefinitions)

        let concreteDefinitions = try! task.execute()

        XCTAssertEqual(concreteDefinitions.count, 2)

        XCTAssertEqual(concreteDefinitions[0].name, "ConcreteClass1")
        XCTAssertEqual(concreteDefinitions[0].vars, [VarDefinition(name: "someProperty", returnType: "SomeAbstractC", isAbstract: false),
                                                           VarDefinition(name: "grandParentVar", returnType: "GrandParentVar", isAbstract: false)])
        XCTAssertEqual(concreteDefinitions[0].methods, [MethodDefinition(name: "parentMethod(index:)", returnType: "String", parameterTypes: ["Int"], isAbstract: false)])
        XCTAssertEqual(concreteDefinitions[0].inheritedTypes, ["ParentAbstractClass", "AProtocol"])

        XCTAssertEqual(concreteDefinitions[1].name, "ConcreteClass2")
        XCTAssertEqual(concreteDefinitions[1].vars, [VarDefinition(name: "grandParentVar", returnType: "GrandParentVar", isAbstract: false)])
        XCTAssertEqual(concreteDefinitions[1].inheritedTypes, ["GrandParentAbstractClass"])
    }

    func test_execute_hasInnerConcreteSubclass_verifyDefinition() {
        let url = fixtureUrl(for: "InnerConcreteSubclass.swift")
        let content = try! String(contentsOf: url)
        let abstractClassDefinitions = [
            AbstractClassDefinition(name: "GrandParentAbstractClass", vars: [VarDefinition(name: "grandParentVar", returnType: "GrandParentVar", isAbstract: true)], methods: [], inheritedTypes: ["AbstractClass"]),
            AbstractClassDefinition(name: "ParentAbstractClass", vars: [], methods: [MethodDefinition(name: "parentMethod(index:)", returnType: "String", parameterTypes: ["Int"], isAbstract: true)], inheritedTypes: ["GrandParentAbstractClass"])
        ]

        let task = ConcreteSubclassProducerTask(sourceUrl: url, sourceContent: content, abstractClassDefinitions: abstractClassDefinitions)

        let concreteDefinitions = try! task.execute()

        XCTAssertEqual(concreteDefinitions.count, 1)

        XCTAssertEqual(concreteDefinitions[0].name, "ConcreteClass2")
        XCTAssertEqual(concreteDefinitions[0].vars, [VarDefinition(name: "grandParentVar", returnType: "GrandParentVar", isAbstract: false)])
        XCTAssertEqual(concreteDefinitions[0].inheritedTypes, ["GrandParentAbstractClass"])
    }
}
