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

import Foundation
import SourceKittenFramework
import SourceParsingFramework

/// Checks the rule that abstract classes cannot be directly instantiated.
class ExpressionCallChecker: AbstractClassChecker {

    /// Initializer.
    ///
    /// - parameter abstractClassDefinitions: The definitions of abstract
    /// classes to check for.
    init(abstractClassDefinitions: [AbstractClassDefinition]) {
        self.abstractClassDefinitions = abstractClassDefinitions
    }

    /// Check the given AST structure for any abstract rule violations.
    ///
    /// - parameter structure: The AST structure to check.
    /// - parameter sourceUrl: The URL where the structure is parsed from.
    /// - throws: If any violations of the rule is found.
    func check(structure: Structure, fromSourceUrl sourceUrl: URL) throws {
        guard !abstractClassDefinitions.isEmpty else {
            return
        }

        let abstractClassNames = Set<String>(abstractClassDefinitions.map { (definition: AbstractClassDefinition) -> String in
            definition.name
        })

        // Remove explicit `init` annotations.
        let expressionCallTypes = structure.uniqueExpressionCallNames.compactMap { (call: String) -> String? in
            if call.hasSuffix(".init") {
                return call.components(separatedBy: ".").first
            } else {
                return call
            }
        }

        for type in expressionCallTypes {
            if abstractClassNames.contains(type) {
                throw GenericError.withMessage("Abstract class \(type) should not be directly instantiated in file \(sourceUrl.path)")
            }
        }
    }

    // MARK: - Private

    private let abstractClassDefinitions: [AbstractClassDefinition]
}
