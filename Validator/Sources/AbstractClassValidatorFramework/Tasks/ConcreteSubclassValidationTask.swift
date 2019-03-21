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
class ConcreteSubclassValidationTask: AbstractTask<Void> {

    /// Initializer.
    ///
    /// - parameter aggregatedConcreteSubclassDefinitions: The aggregated
    /// concrete subclass definitions where definitions include concrete
    /// property and method definitions of their inherited superclasses.
    init(aggregatedConcreteSubclassDefinitions: [AggregatedConcreteSubclassDefinition]) {
        self.aggregatedConcreteSubclassDefinitions = aggregatedConcreteSubclassDefinitions
    }

    /// Execute the task and validate the given aggregated concrete
    /// subclass definitions for inheritance usages.
    ///
    /// - throws: Any error occurred during execution.
    override func execute() throws -> Void {
        guard !aggregatedConcreteSubclassDefinitions.isEmpty else {
            return
        }

        // Check the entire inheritance chain's abstract properties and
        // methods are fulfilled by the entire chain. If GrandParent has
        // two abstract properties, Parent fulfills one and declares the
        // second one abstract still, the child only needs to fulfill
        // the second abstract property. If Parent fulfilled both, then
        // child should have been filtered out by the usage filter, since
        // Parent is not an abstract class.
        for concreteDefinition in aggregatedConcreteSubclassDefinitions {
            try validateVars(of: concreteDefinition)
            try validateMethods(of: concreteDefinition)
        }
    }

    // MARK: - Private

    private let aggregatedConcreteSubclassDefinitions: [AggregatedConcreteSubclassDefinition]

    private func validateVars(of concreteDefinition: AggregatedConcreteSubclassDefinition) throws {
        let abstractVarSignatures = Set(concreteDefinition.aggregatedVars.filter { $0.isAbstract }.map { VarSignature(definition: $0) })
        let concreteVarSignatures = Set(concreteDefinition.aggregatedVars.filter { !$0.isAbstract }.map { VarSignature(definition: $0) })

        let nonImplementedVars = abstractVarSignatures.subtracting(concreteVarSignatures)
        if !nonImplementedVars.isEmpty {
            let varSignatures = nonImplementedVars.map { "(\($0.name): \($0.returnType))" }.joined(separator: ", ")
            throw GenericError.withMessage("\(concreteDefinition.value.name) missing abstract property implementations of \(varSignatures)")
        }
    }

    private func validateMethods(of concreteDefinition: AggregatedConcreteSubclassDefinition) throws {
        let abstractMethodSignatures = Set(concreteDefinition.aggregatedMethods.filter { $0.isAbstract }.map { MethodSignature(definition: $0) })
        let concreteMethodSignatures = Set(concreteDefinition.aggregatedMethods.filter { !$0.isAbstract }.map { MethodSignature(definition: $0) })

        let nonImplementedMethods = abstractMethodSignatures.subtracting(concreteMethodSignatures)
        if !nonImplementedMethods.isEmpty {
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
            throw GenericError.withMessage("\(concreteDefinition.value.name) missing abstract method implementations of \(methodSignatures)")
        }
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
