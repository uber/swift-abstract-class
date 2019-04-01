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

import Concurrency
import Foundation
import SourceKittenFramework
import SourceParsingFramework

/// A task that validates concrete subclasses of abstract classes must
/// provide implementations for all abstract properties and methods
/// declared in its class hierarchy.
class ConcreteSubclassValidationTask: AbstractTask<ValidationResult> {

    /// Initializer.
    ///
    /// - parameter aggregatedConcreteSubclassDefinition: The aggregated
    /// concrete subclass definition where each definition includes
    /// concrete property and method definitions of its inherited
    /// superclasses.
    init(aggregatedConcreteSubclassDefinition: AggregatedConcreteSubclassDefinition) {
        self.aggregatedConcreteSubclassDefinition = aggregatedConcreteSubclassDefinition
        super.init(id: TaskIds.concreteSubclassValidationTask.rawValue)
    }

    /// Execute the task and validate the given aggregated concrete
    /// subclass definitions for inheritance usages.
    ///
    /// - returns: The validation result.
    /// - throws: Any error occurred during execution.
    override func execute() throws -> ValidationResult {
        // Check the entire inheritance chain's abstract properties and
        // methods are fulfilled by the entire chain. If GrandParent has
        // two abstract properties, Parent fulfills one and declares the
        // second one abstract still, the child only needs to fulfill
        // the second abstract property. If Parent fulfilled both, then
        // child should have been filtered out by the usage filter, since
        // Parent is not an abstract class.
        let result = validateVars(of: aggregatedConcreteSubclassDefinition)
        switch result {
        case .success:
            break
        case .failureWithReason(_):
            return result
        }

        return validateMethods(of: aggregatedConcreteSubclassDefinition)
    }

    // MARK: - Private

    private let aggregatedConcreteSubclassDefinition: AggregatedConcreteSubclassDefinition

    private func validateVars(of concreteDefinition: AggregatedConcreteSubclassDefinition) -> ValidationResult {
        let abstractVarSignatures = Set(concreteDefinition.aggregatedVars.filter { $0.isAbstract }.map { VarSignature(definition: $0) })
        let concreteVarSignatures = Set(concreteDefinition.aggregatedVars.filter { !$0.isAbstract }.map { VarSignature(definition: $0) })

        let nonImplementedVars = abstractVarSignatures.subtracting(concreteVarSignatures)
        if !nonImplementedVars.isEmpty {
            let varSignatures = nonImplementedVars.map { "(\($0.name): \($0.returnType))" }.joined(separator: ", ")
            return .failureWithReason("Class \(concreteDefinition.value.name) is missing abstract property implementations of \(varSignatures) in \(concreteDefinition.value.filePath)")
        }

        return .success
    }

    private func validateMethods(of concreteDefinition: AggregatedConcreteSubclassDefinition) -> ValidationResult {
        let abstractMethodSignatures = Set(concreteDefinition.aggregatedMethods.filter { $0.isAbstract }.map { MethodSignature(definition: $0) })
        let concreteMethodSignatures = Set(concreteDefinition.aggregatedMethods.filter { !$0.isAbstract }.map { MethodSignature(definition: $0) })

        let nonImplementedMethods = abstractMethodSignatures.subtracting(concreteMethodSignatures)
        guard !nonImplementedMethods.isEmpty else {
            return .success
        }

        let methodSignatures = nonImplementedMethods
            .map { (signature: MethodSignature) -> String in
                let signatureComponents = signature.name.components(separatedBy: ":")
                let signatureNameAndParams: String
                if signatureComponents.count > 1 {
                    var parameters = signature.parameterTypes
                    var signatureWithParams = [String]()
                    for component in signatureComponents {
                        signatureWithParams.append(component)
                        if !parameters.isEmpty {
                            let parameter = parameters.removeFirst()
                            signatureWithParams.append(": \(parameter)")
                            if !parameters.isEmpty {
                                signatureWithParams.append(", ")
                            }
                        }
                    }
                    signatureNameAndParams = "\(signatureWithParams.joined())"
                } else {
                    signatureNameAndParams = "\(signature.name)()"
                }

                if let returnType = signature.returnType {
                    return "(\(signatureNameAndParams) -> \(returnType))"
                } else {
                    return "(\(signatureNameAndParams))"
                }
            }
            .joined(separator: ", ")

        return .failureWithReason("Class \(concreteDefinition.value.name) is missing abstract method implementations of \(methodSignatures) in \(concreteDefinition.value.filePath)")
    }
}

fileprivate struct VarSignature: Hashable {
    fileprivate let name: String
    fileprivate let returnType: String

    fileprivate init(definition: VarDefinition) {
        name = definition.name
        returnType = definition.returnType
    }
}

fileprivate struct MethodSignature: Hashable {
    fileprivate let name: String
    fileprivate let returnType: String?
    fileprivate let parameterTypes: [String]

    fileprivate init(definition: MethodDefinition) {
        name = definition.name
        returnType = definition.returnType
        parameterTypes = definition.parameterTypes
    }
}
