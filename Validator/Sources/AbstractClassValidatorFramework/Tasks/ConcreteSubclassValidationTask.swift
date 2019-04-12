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
        // Cannot validate based on return type of the properties, since
        // the return types may be generic types. Using name and override
        // attribute is sufficient.
        let abstractVarNames = Set(concreteDefinition.aggregatedVars.filter { $0.isAbstract }.map { $0.name })
        let concreteOverrideVarNames = Set(concreteDefinition.aggregatedVars.filter { !$0.isAbstract && $0.isOverride }.map { $0.name })

        let nonImplementedVarNames = abstractVarNames.subtracting(concreteOverrideVarNames)
        if !nonImplementedVarNames.isEmpty {
            let varNames = nonImplementedVarNames.joined(separator: ", ")
            return .failureWithReason("Class \(concreteDefinition.value.name) is missing abstract property implementations of \(varNames) in \(concreteDefinition.value.filePath)")
        }

        return .success
    }

    private func validateMethods(of concreteDefinition: AggregatedConcreteSubclassDefinition) -> ValidationResult {
        // Cannot validate based on return type or parameter types, since
        // the these types may be generic types. Using name and override
        // attribute is sufficient.
        let abstractMethodNames = Set(concreteDefinition.aggregatedMethods.filter { $0.isAbstract }.map { $0.name })
        let concreteOverrideMethodNames = Set(concreteDefinition.aggregatedMethods.filter { !$0.isAbstract && $0.isOverride }.map { $0.name })

        let nonImplementedMethodNames = abstractMethodNames.subtracting(concreteOverrideMethodNames)
        if !nonImplementedMethodNames.isEmpty {
            let methodNames = nonImplementedMethodNames.joined(separator: ", ")
            return .failureWithReason("Class \(concreteDefinition.value.name) is missing abstract method implementations of \(methodNames) in \(concreteDefinition.value.filePath)")
        }

        return .success
    }
}
