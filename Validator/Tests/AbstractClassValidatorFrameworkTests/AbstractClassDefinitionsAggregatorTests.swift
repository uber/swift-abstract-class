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

class AbstractClassDefinitionsAggregatorTests: BaseFrameworkTests {

    func test_aggregate_withAncestors_verifyAggregatedResults() {
        let grandParentVars = [VarDefinition(name: "gV", isAbstract: true, isOverride: false)]
        let grandParentMethods = [MethodDefinition(name: "gM1", isAbstract: true, isOverride: false), MethodDefinition(name: "gM2", isAbstract: true, isOverride: false)]

        let parentVars = [VarDefinition(name: "pV1", isAbstract: true, isOverride: false), VarDefinition(name: "pV2", isAbstract: true, isOverride: false)]
        let parentMethods = [MethodDefinition(name: "gM", isAbstract: true, isOverride: false)]

        let childVars = [VarDefinition(name: "cV", isAbstract: true, isOverride: false)]
        let childMethods = [MethodDefinition(name: "cM", isAbstract: true, isOverride: false)]

        let definitions = [
            AbstractClassDefinition(name: "GrandParent", vars: grandParentVars, methods: grandParentMethods, inheritedTypes: []),
            AbstractClassDefinition(name: "Parent", vars: parentVars, methods: parentMethods, inheritedTypes: ["GrandParent"]),
            AbstractClassDefinition(name: "Child", vars: childVars, methods: childMethods, inheritedTypes: ["Parent"]),
        ]

        let aggregator = AbstractClassDefinitionsAggregator()

        let results = aggregator.aggregate(abstractClassDefinitions: definitions)

        for definition in results {
            switch definition.value.name {
            case "Child":
                let allVars = grandParentVars + parentVars + childVars
                for v in allVars {
                    XCTAssertTrue(definition.aggregatedVars.contains(v))
                }
                let allMethods = grandParentMethods + parentMethods + childMethods
                for m in allMethods {
                    XCTAssertTrue(definition.aggregatedMethods.contains(m))
                }
            case "Parent":
                let allVars = grandParentVars + parentVars
                for v in allVars {
                    XCTAssertTrue(definition.aggregatedVars.contains(v))
                }
                let allMethods = grandParentMethods + parentMethods
                for m in allMethods {
                    XCTAssertTrue(definition.aggregatedMethods.contains(m))
                }
            case "GrandParent":
                for v in grandParentVars {
                    XCTAssertTrue(definition.aggregatedVars.contains(v))
                }
                for m in grandParentMethods {
                    XCTAssertTrue(definition.aggregatedMethods.contains(m))
                }
            default:
                XCTFail()
            }
        }
    }
}
