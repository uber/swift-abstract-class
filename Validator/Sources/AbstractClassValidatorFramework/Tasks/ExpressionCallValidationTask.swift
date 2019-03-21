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

/// A task that validates a file containing expression call abstract
/// class usages to ensure abstract class types are not directly
/// instantiated.
class ExpressionCallValidationTask: AbstractTask<ValidationResult> {

    /// Initializer.
    ///
    /// - parameter sourceUrl: The source URL.
    /// - parameter sourceContent: The source content to be parsed into AST.
    /// - parameter abstractClassDefinitions: The definitions of all
    /// abstract classes.
    init(sourceUrl: URL, sourceContent: String, abstractClassDefinitions: [AbstractClassDefinition]) {
        self.sourceUrl = sourceUrl
        self.sourceContent = sourceContent
        self.abstractClassDefinitions = abstractClassDefinitions
        super.init(id: TaskIds.expressionCallValidationTask.rawValue)
    }

    /// Execute the task and validate the given file's expression call
    /// usages.
    ///
    /// - returns: The validation result.
    /// - throws: Any error occurred during execution.
    override func execute() throws -> ValidationResult {
        guard !abstractClassDefinitions.isEmpty else {
            return .success
        }

        let abstractClassNames = Set<String>(abstractClassDefinitions.map { (definition: AbstractClassDefinition) -> String in
            definition.name
        })

        let file = File(contents: sourceContent)
        guard let structure = try? Structure(file: file) else {
            throw GenericError.withMessage("Failed to parse AST for source at \(sourceUrl)")
        }

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
                return .failureWithReason("Abstract class \(type) should not be directly instantiated in file \(sourceUrl.path)")
            }
        }

        return .success
    }

    // MARK: - Private

    private let sourceUrl: URL
    private let sourceContent: String
    private let abstractClassDefinitions: [AbstractClassDefinition]
}
