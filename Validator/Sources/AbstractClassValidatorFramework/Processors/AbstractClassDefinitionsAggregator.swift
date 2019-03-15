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

/// A processing unit that aggregates abstract class definitions'
/// abstract properties and methods with their ancestor abstract
/// class definitions.
class AbstractClassDefinitionsAggregator {

    /// Aggregate the given abstract class definitions based their
    /// class inheritance structures.
    ///
    /// - parameter abstractClassDefinitions: The definitions to
    /// aggregate.
    /// - returns: The aggregated abstract class definitions where
    /// sub-abstract class definitions include abstract property and
    /// method definitions of their inherited super-abstract classes.
    func aggregate(abstractClassDefinitions: [AbstractClassDefinition]) -> [AbstractClassDefinition] {
        // Create a map of name to definition for easy access.
        var definitionsMap = [String: ParentedAbstractClassDefinition]()
        for definition in abstractClassDefinitions {
            definitionsMap[definition.name] = ParentedAbstractClassDefinition(value: definition)
        }

        // Link individual definitions to their ancestor definitions.
        for (_, definition) in definitionsMap {
            let ancestors = definition.value.inheritedTypes.compactMap { (parentName: String) -> ParentedAbstractClassDefinition? in
                definitionsMap[parentName]
            }
            definition.ancestors.append(contentsOf: ancestors)
        }

        // Consolidate each definition with its ancestor definitions.
        return Array(definitionsMap.values).map { (definition: ParentedAbstractClassDefinition) -> AbstractClassDefinition in
            var allAbstractVars = definition.value.abstractVars
            var allAbstractMethods = definition.value.abstractMethods
            iterateAllAncestors(of: definition) { (ancestor: ParentedAbstractClassDefinition) in
                allAbstractVars.append(contentsOf: ancestor.value.abstractVars)
                allAbstractMethods.append(contentsOf: ancestor.value.abstractMethods)
            }

            return AbstractClassDefinition(name: definition.value.name, abstractVars: allAbstractVars, abstractMethods: allAbstractMethods, inheritedTypes: definition.value.inheritedTypes)
        }
    }

    // MARK: - Private

    private func iterateAllAncestors(of definition: ParentedAbstractClassDefinition, handler: (ParentedAbstractClassDefinition) -> ()) {
        var ancestors = definition.ancestors
        while !ancestors.isEmpty {
            let ancestor = ancestors.removeFirst()
            handler(ancestor)
            ancestors.append(contentsOf: ancestor.ancestors)
        }
    }
}

private class ParentedAbstractClassDefinition {
    fileprivate let value: AbstractClassDefinition
    fileprivate var ancestors = [ParentedAbstractClassDefinition]()

    init(value: AbstractClassDefinition) {
        self.value = value
    }
}
