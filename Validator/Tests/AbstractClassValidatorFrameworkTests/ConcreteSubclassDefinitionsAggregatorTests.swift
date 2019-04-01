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

class ConcreteSubclassDefinitionsAggregatorTests: BaseFrameworkTests {

    func test_aggregate_withAncestors_verifyAggregatedResults() {
        let grandParentVars = [VarDefinition(name: "gV", returnType: "GV", isAbstract: true)]
        let grandParentMethods = [MethodDefinition(name: "gM1", returnType: "GM1", parameterTypes: [], isAbstract: true), MethodDefinition(name: "gM2", returnType: "GM2", parameterTypes: ["GMP1", "GMP2"], isAbstract: true)]

        let parentVars = [VarDefinition(name: "pV1", returnType: "PV1", isAbstract: true), VarDefinition(name: "pV2", returnType: "PV2", isAbstract: true)]
        let parentMethods = [MethodDefinition(name: "gM", returnType: "GM", parameterTypes: [], isAbstract: true)]

        let childVars = [VarDefinition(name: "cV", returnType: "CV", isAbstract: true)]
        let childMethods = [MethodDefinition(name: "cM", returnType: "CM", parameterTypes: ["CMP"], isAbstract: true)]

        let grandParentAbstractClass = AbstractClassDefinition(name: "GrandParent", vars: grandParentVars, methods: grandParentMethods, inheritedTypes: [])
        let parentAbstractClass = AbstractClassDefinition(name: "Parent", vars: parentVars, methods: parentMethods, inheritedTypes: ["GrandParent"])
        let childAbstractClass = AbstractClassDefinition(name: "Child", vars: childVars, methods: childMethods, inheritedTypes: ["Parent"])
        let aggregatedAbstractClassDefinitions = [
            AggregatedAbstractClassDefinition(value: grandParentAbstractClass, aggregatedVars: grandParentVars, aggregatedMethods: grandParentMethods),
            AggregatedAbstractClassDefinition(value: parentAbstractClass, aggregatedVars: grandParentVars + parentVars, aggregatedMethods: grandParentMethods + parentMethods),
            AggregatedAbstractClassDefinition(value: childAbstractClass, aggregatedVars: grandParentVars + parentVars + childVars, aggregatedMethods: grandParentMethods + parentMethods + childMethods),
            ]

        let parentLeafVars = [VarDefinition(name: "pLV", returnType: "PLV", isAbstract: false)]
        let parentLeafMethods = [MethodDefinition(name: "pLM", returnType: "PLM", parameterTypes: [], isAbstract: false)]

        let childLeafVars = [VarDefinition(name: "cLV1", returnType: "CLV1", isAbstract: false),
                             VarDefinition(name: "cLV2", returnType: "CLV2", isAbstract: false)]
        let childLeafMethods = [MethodDefinition(name: "cLM", returnType: "CLM", parameterTypes: [], isAbstract: false)]

        let leafConcreteSubclassDefinitions = [
            ConcreteSubclassDefinition(name: "ParentLeaf", vars: parentLeafVars, methods: parentLeafMethods, inheritedTypes: ["GrandParent", "Parent"], filePath: URL(fileURLWithPath: #file).path),
            ConcreteSubclassDefinition(name: "ChildLeaf", vars: childLeafVars, methods: childLeafMethods, inheritedTypes: ["GrandParent", "Parent", "Child"], filePath: URL(fileURLWithPath: #file).path)
        ]

        let aggregator = ConcreteSubclassDefinitionsAggregator()

        let results = aggregator.aggregate(leafConcreteSubclassDefinitions: leafConcreteSubclassDefinitions, aggregatedAncestorAbstractClassDefinitions: aggregatedAbstractClassDefinitions)

        for definition in results {
            switch definition.value.name {
            case "ChildLeaf":
                let allVars = grandParentVars + parentVars + childVars + childLeafVars
                for v in allVars {
                    XCTAssertTrue(definition.aggregatedVars.contains(v))
                }
                let allMethods = grandParentMethods + parentMethods + childMethods + childLeafMethods
                for m in allMethods {
                    XCTAssertTrue(definition.aggregatedMethods.contains(m))
                }
            case "ParentLeaf":
                let allVars = grandParentVars + parentVars + parentLeafVars
                for v in allVars {
                    XCTAssertTrue(definition.aggregatedVars.contains(v))
                }
                let allMethods = grandParentMethods + parentMethods + parentLeafMethods
                for m in allMethods {
                    XCTAssertTrue(definition.aggregatedMethods.contains(m))
                }
            default:
                XCTFail()
            }
        }
    }
}
