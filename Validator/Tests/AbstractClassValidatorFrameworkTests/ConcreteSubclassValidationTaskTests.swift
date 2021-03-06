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

import SourceParsingFramework
import XCTest
@testable import AbstractClassValidatorFramework

class ConcreteSubclassValidationTaskTests: BaseFrameworkTests {

    private var grandParentAbstractVars: [VarDefinition]!
    private var grandParentConcreteVars: [VarDefinition]!

    private var grandParentAbstractMethods: [MethodDefinition]!
    private var grandParentConcreteMethods: [MethodDefinition]!

    private var parentAbstractVars: [VarDefinition]!
    private var parentConcreteVars: [VarDefinition]!

    private var parentAbstractMethods: [MethodDefinition]!
    private var parentConcreteMethods: [MethodDefinition]!

    private var childAbstractVars: [VarDefinition]!
    private var childConcreteVars: [VarDefinition]!

    private var childAbstractMethods: [MethodDefinition]!
    private var childConcreteMethods: [MethodDefinition]!

    private var parentAdditionalConcreteVars: [VarDefinition]!
    private var parentAdditionalConcreteMethods: [MethodDefinition]!

    private var childAdditionalConcreteVars: [VarDefinition]!
    private var childAdditionalConcreteMethods: [MethodDefinition]!

    private var parentConcreteClass: ConcreteSubclassDefinition!
    private var childConcreteClass: ConcreteSubclassDefinition!

    override func setUp() {
        super.setUp()

        grandParentAbstractVars = [VarDefinition(name: "gV", isAbstract: true, isOverride: false)]
        grandParentConcreteVars = [VarDefinition(name: "gV", isAbstract: false, isOverride: true)]

        grandParentAbstractMethods = [MethodDefinition(name: "gM1", isAbstract: true, isOverride: false), MethodDefinition(name: "gM2(_:arg2:)", isAbstract: true, isOverride: false)]
        grandParentConcreteMethods = [MethodDefinition(name: "gM1", isAbstract: false, isOverride: true), MethodDefinition(name: "gM2(_:arg2:)", isAbstract: false, isOverride: true)]

        parentAbstractVars = [VarDefinition(name: "pV1", isAbstract: true, isOverride: false), VarDefinition(name: "pV2", isAbstract: true, isOverride: false)]
        parentConcreteVars = [VarDefinition(name: "pV1", isAbstract: false, isOverride: true), VarDefinition(name: "pV2", isAbstract: false, isOverride: true)]

        parentAbstractMethods = [MethodDefinition(name: "gM", isAbstract: true, isOverride: false)]
        parentConcreteMethods = [MethodDefinition(name: "gM", isAbstract: false, isOverride: true)]

        childAbstractVars = [VarDefinition(name: "cV", isAbstract: true, isOverride: false)]
        childConcreteVars = [VarDefinition(name: "cV", isAbstract: false, isOverride: true)]

        childAbstractMethods = [MethodDefinition(name: "cM(arg:)", isAbstract: true, isOverride: false)]
        childConcreteMethods = [MethodDefinition(name: "cM(arg:)", isAbstract: false, isOverride: true)]

        parentAdditionalConcreteVars = [VarDefinition(name: "pLV", isAbstract: false, isOverride: true)]
        parentAdditionalConcreteMethods = [MethodDefinition(name: "pLM", isAbstract: false, isOverride: true)]

        childAdditionalConcreteVars = [VarDefinition(name: "cLV1", isAbstract: false, isOverride: true),
                             VarDefinition(name: "cLV2", isAbstract: false, isOverride: true)]
        childAdditionalConcreteMethods = [MethodDefinition(name: "cLM", isAbstract: false, isOverride: true)]

        parentConcreteClass = ConcreteSubclassDefinition(name: "ParentLeaf", vars: parentAdditionalConcreteVars, methods: parentAdditionalConcreteMethods, inheritedTypes: ["GrandParent", "Parent"], filePath: URL(fileURLWithPath: #file).path)
        childConcreteClass = ConcreteSubclassDefinition(name: "ChildLeaf", vars: childAdditionalConcreteVars, methods: childAdditionalConcreteMethods, inheritedTypes: ["GrandParent", "Parent", "Child"], filePath: URL(fileURLWithPath: #file).path)
    }

    func test_execute_hasValidDefinitions_verifyNoError() {
        // Splitting these expressions since Swift compiler thinks it's too complex.
        let childVars1 = grandParentAbstractVars + grandParentConcreteVars
        let childVars2 = parentAbstractVars + parentConcreteVars + parentAdditionalConcreteVars
        let childVars3 = childAbstractVars + childConcreteVars + childAdditionalConcreteVars
        let childMethods1 = grandParentAbstractMethods + grandParentConcreteMethods
        let childMethods2 = parentAbstractMethods + parentConcreteMethods + parentAdditionalConcreteMethods
        let childMethods3 = childAbstractMethods + childConcreteMethods + childAdditionalConcreteMethods
        let aggregatedChildClass = AggregatedConcreteSubclassDefinition(value: childConcreteClass, aggregatedVars: childVars1 + childVars2 + childVars3, aggregatedMethods: childMethods1 + childMethods2 + childMethods3)

        let task = ConcreteSubclassValidationTask(aggregatedConcreteSubclassDefinition: aggregatedChildClass)

        let result = try! task.execute()
        switch result {
        case .success:
            break
        default:
            XCTFail()
        }
    }

    func test_execute_missingMiddleVarDefinitions_verifyError() {
        // Splitting these expressions since Swift compiler thinks it's too complex.
        let parentVars1 = grandParentAbstractVars + grandParentConcreteVars
        let parentVars2 = parentAbstractVars + parentAdditionalConcreteVars
        let parentMethods1 = grandParentAbstractMethods + grandParentConcreteMethods
        let parentMethods2 = parentAbstractMethods + parentConcreteMethods + parentAdditionalConcreteMethods
        let aggregatedParentClass = AggregatedConcreteSubclassDefinition(value: parentConcreteClass, aggregatedVars: parentVars1 + parentVars2, aggregatedMethods: parentMethods1 + parentMethods2)

        let task = ConcreteSubclassValidationTask(aggregatedConcreteSubclassDefinition: aggregatedParentClass)

        let result = try! task.execute()
        switch result {
        case .failureWithReason(let reason):
            XCTAssertTrue(reason.contains(aggregatedParentClass.value.name))
            XCTAssertTrue(reason.contains("pV2"))
            XCTAssertTrue(reason.contains("pV1"))
            XCTAssertTrue(reason.contains(URL(fileURLWithPath: #file).path))
        default:
            XCTFail()
        }
    }

    func test_execute_missingLeafVarDefinitions_verifyError() {
        // Splitting these expressions since Swift compiler thinks it's too complex.
        let childVars1 = grandParentAbstractVars + grandParentConcreteVars
        let childVars2 = parentAbstractVars + parentConcreteVars + parentAdditionalConcreteVars
        let childVars3 = childAbstractVars + childAdditionalConcreteVars
        let childMethods1 = grandParentAbstractMethods + grandParentConcreteMethods
        let childMethods2 = parentAbstractMethods + parentConcreteMethods + parentAdditionalConcreteMethods
        let childMethods3 = childAbstractMethods + childConcreteMethods + childAdditionalConcreteMethods
        let aggregatedChildClass = AggregatedConcreteSubclassDefinition(value: childConcreteClass, aggregatedVars: childVars1 + childVars2 + childVars3, aggregatedMethods: childMethods1 + childMethods2 + childMethods3)

        let task = ConcreteSubclassValidationTask(aggregatedConcreteSubclassDefinition: aggregatedChildClass)

        let result = try! task.execute()
        switch result {
        case .failureWithReason(let reason):
            XCTAssertTrue(reason.contains(aggregatedChildClass.value.name))
            XCTAssertTrue(reason.contains("cV"))
            XCTAssertTrue(reason.contains(URL(fileURLWithPath: #file).path))
        default:
            XCTFail()
        }
    }

    func test_execute_missingMiddleMethodDefinitions_verifyError() {
        // Splitting these expressions since Swift compiler thinks it's too complex.
        let parentVars1 = grandParentAbstractVars + grandParentConcreteVars
        let parentVars2 = parentAbstractVars + parentConcreteVars + parentAdditionalConcreteVars
        let parentMethods1 = grandParentAbstractMethods!
        let parentMethods2 = parentAbstractMethods + parentConcreteMethods + parentAdditionalConcreteMethods
        let aggregatedParentClass = AggregatedConcreteSubclassDefinition(value: parentConcreteClass, aggregatedVars: parentVars1 + parentVars2, aggregatedMethods: parentMethods1 + parentMethods2)

        let task = ConcreteSubclassValidationTask(aggregatedConcreteSubclassDefinition: aggregatedParentClass)

        let result = try! task.execute()
        switch result {
        case .failureWithReason(let reason):
            XCTAssertTrue(reason.contains(aggregatedParentClass.value.name))
            XCTAssertTrue(reason.contains("gM1"))
            XCTAssertTrue(reason.contains("gM2(_:arg2:)"))
            XCTAssertTrue(reason.contains(URL(fileURLWithPath: #file).path))
        default:
            XCTFail()
        }
    }

    func test_execute_missingLeafMethodDefinitions_verifyError() {
        // Splitting these expressions since Swift compiler thinks it's too complex.
        let childVars1 = grandParentAbstractVars + grandParentConcreteVars
        let childVars2 = parentAbstractVars + parentConcreteVars + parentAdditionalConcreteVars
        let childVars3 = childAbstractVars + childConcreteVars + childAdditionalConcreteVars
        let childMethods1 = grandParentAbstractMethods + grandParentConcreteMethods
        let childMethods2 = parentAbstractMethods + parentConcreteMethods + parentAdditionalConcreteMethods
        let childMethods3 = childAbstractMethods + childAdditionalConcreteMethods
        let aggregatedChildClass = AggregatedConcreteSubclassDefinition(value: childConcreteClass, aggregatedVars: childVars1 + childVars2 + childVars3, aggregatedMethods: childMethods1 + childMethods2 + childMethods3)

        let task = ConcreteSubclassValidationTask(aggregatedConcreteSubclassDefinition: aggregatedChildClass)

        let result = try! task.execute()
        switch result {
        case .failureWithReason(let reason):
            XCTAssertTrue(reason.contains(aggregatedChildClass.value.name))
            XCTAssertTrue(reason.contains("cM(arg:)"))
            XCTAssertTrue(reason.contains(URL(fileURLWithPath: #file).path))
        default:
            XCTFail()
        }
    }
}
