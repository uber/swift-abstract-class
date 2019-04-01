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

        grandParentAbstractVars = [VarDefinition(name: "gV", returnType: "GV", isAbstract: true)]
        grandParentConcreteVars = [VarDefinition(name: "gV", returnType: "GV", isAbstract: false)]

        grandParentAbstractMethods = [MethodDefinition(name: "gM1", returnType: "GM1", parameterTypes: [], isAbstract: true), MethodDefinition(name: "gM2(_:arg2:)", returnType: "GM2", parameterTypes: ["GMP1", "GMP2"], isAbstract: true)]
        grandParentConcreteMethods = [MethodDefinition(name: "gM1", returnType: "GM1", parameterTypes: [], isAbstract: false), MethodDefinition(name: "gM2(_:arg2:)", returnType: "GM2", parameterTypes: ["GMP1", "GMP2"], isAbstract: false)]

        parentAbstractVars = [VarDefinition(name: "pV1", returnType: "PV1", isAbstract: true), VarDefinition(name: "pV2", returnType: "PV2", isAbstract: true)]
        parentConcreteVars = [VarDefinition(name: "pV1", returnType: "PV1", isAbstract: false), VarDefinition(name: "pV2", returnType: "PV2", isAbstract: false)]

        parentAbstractMethods = [MethodDefinition(name: "gM", returnType: "GM", parameterTypes: [], isAbstract: true)]
        parentConcreteMethods = [MethodDefinition(name: "gM", returnType: "GM", parameterTypes: [], isAbstract: false)]

        childAbstractVars = [VarDefinition(name: "cV", returnType: "CV", isAbstract: true)]
        childConcreteVars = [VarDefinition(name: "cV", returnType: "CV", isAbstract: false)]

        childAbstractMethods = [MethodDefinition(name: "cM(arg:)", returnType: "CM", parameterTypes: ["CMP"], isAbstract: true)]
        childConcreteMethods = [MethodDefinition(name: "cM(arg:)", returnType: "CM", parameterTypes: ["CMP"], isAbstract: false)]

        parentAdditionalConcreteVars = [VarDefinition(name: "pLV", returnType: "PLV", isAbstract: false)]
        parentAdditionalConcreteMethods = [MethodDefinition(name: "pLM", returnType: "PLM", parameterTypes: [], isAbstract: false)]

        childAdditionalConcreteVars = [VarDefinition(name: "cLV1", returnType: "CLV1", isAbstract: false),
                             VarDefinition(name: "cLV2", returnType: "CLV2", isAbstract: false)]
        childAdditionalConcreteMethods = [MethodDefinition(name: "cLM", returnType: "CLM", parameterTypes: [], isAbstract: false)]

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
            XCTAssertTrue(reason.contains("(pV2: PV2)"))
            XCTAssertTrue(reason.contains("(pV1: PV1)"))
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
            XCTAssertTrue(reason.contains("(cV: CV)"))
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
            XCTAssertTrue(reason.contains("(gM1() -> GM1)"))
            XCTAssertTrue(reason.contains("(gM2(_: GMP1, arg2: GMP2) -> GM2)"))
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
            XCTAssertTrue(reason.contains("(cM(arg: CMP) -> CM)"))
            XCTAssertTrue(reason.contains(URL(fileURLWithPath: #file).path))
        default:
            XCTFail()
        }
    }
}
