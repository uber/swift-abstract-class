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

/// A processing unit that aggregates concrete subclass definitions'
/// abstract properties and methods with their ancestor concrete subclass
/// definitions.
class ConcreteSubclassDefinitionsAggregator {

    /// Aggregate the given concrete subclass with their ancestor
    /// abstract class definitions based the inheritance structures.
    ///
    /// - SeeAlso: `AbstractClassDefinitionsAggregator`.
    /// - parameter leafConcreteSubclassDefinitions: The concrete
    /// subclass definitions at the leaf-level of class inheritance
    /// chains to aggregate.
    /// - parameter aggregatedAncestorAbstractClassDefinitions: The
    /// definitions of ancestor classes of the concrete subclasses.
    /// These definitions should already have their properties and
    /// methods aggregated.
    /// - returns: The aggregated concrete subclass definitions where
    /// definitions include concrete property and method definitions
    /// of their inherited superclasses.
    func aggregate(leafConcreteSubclassDefinitions: [ConcreteSubclassDefinition], aggregatedAncestorAbstractClassDefinitions: [AggregatedAbstractClassDefinition]) -> [AggregatedConcreteSubclassDefinition] {
        // Create a map of name to definition for easy access.
        var abstractClassDefinitionsMap = [String: AggregatedAbstractClassDefinition]()
        for definition in aggregatedAncestorAbstractClassDefinitions {
            abstractClassDefinitionsMap[definition.value.name] = definition
        }

        let parentedConcreteDefinitions = leafConcreteSubclassDefinitions.map { ParentedConcreteSubclassDefinition(value: $0) }

        // Link individual definitions to their ancestor definitions.
        for definition in parentedConcreteDefinitions {
            let ancestors = definition.value.inheritedTypes.compactMap { (parentName: String) -> AggregatedAbstractClassDefinition? in
                abstractClassDefinitionsMap[parentName]
            }
            definition.ancestors.append(contentsOf: ancestors)
        }

        // Consolidate each definition with its ancestor definitions.
        return parentedConcreteDefinitions.map { (definition: ParentedConcreteSubclassDefinition) -> AggregatedConcreteSubclassDefinition in
            var allVars = Set<VarDefinition>(definition.value.vars)
            var allMethods = Set<MethodDefinition>(definition.value.methods)
            for ancestor in definition.ancestors {
                for varDefinition in ancestor.aggregatedVars {
                    allVars.insert(varDefinition)
                }
                for methodDefinition in ancestor.aggregatedMethods {
                    allMethods.insert(methodDefinition)
                }
            }
            return AggregatedConcreteSubclassDefinition(value: definition.value, aggregatedVars: Array(allVars), aggregatedMethods: Array(allMethods))
        }
    }
}

private class ParentedConcreteSubclassDefinition {
    fileprivate let value: ConcreteSubclassDefinition
    fileprivate var ancestors = [AggregatedAbstractClassDefinition]()

    fileprivate init(value: ConcreteSubclassDefinition) {
        self.value = value
    }
}
