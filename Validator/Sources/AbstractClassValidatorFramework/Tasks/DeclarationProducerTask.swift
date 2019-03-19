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

/// A task that parses a Swift source content and produces abstract class
/// declaration data models.
class DeclarationProducerTask: AbstractTask<[AbstractClassDefinition]> {

    /// Initializer.
    ///
    /// - parameter sourceUrl: The source URL.
    /// - parameter sourceContent: The source content to be parsed into AST.
    init(sourceUrl: URL, sourceContent: String) {
        self.sourceUrl = sourceUrl
        self.sourceContent = sourceContent
        super.init(id: TaskIds.declarationsProducerTask.rawValue)
    }

    /// Execute the task and return the abstract class data models.
    ///
    /// - returns: The abstract class data models.
    /// - throws: Any error occurred during execution.
    override func execute() throws -> [AbstractClassDefinition] {
        let file = File(contents: sourceContent)
        do {
            let structure = try Structure(file: file)
            return structure
                .filterSubstructure(by: SwiftDeclarationKind.class.rawValue, recursively: true)
                .compactMap { (declaration: Structure) -> AbstractClassDefinition? in
                    let vars = declaration.vars
                    let hasAbstractVars = vars.contains { $0.isAbstract }
                    let methods = declaration.methods
                    let hasAbstractMethods = methods.contains { $0.isAbstract }
                    if hasAbstractVars || hasAbstractMethods {
                        return AbstractClassDefinition(name: declaration.name, vars: vars, methods: methods, inheritedTypes: declaration.inheritedTypes)
                    }
                    return nil
                }
        } catch {
            throw GenericError.withMessage("Failed to parse AST for source at \(sourceUrl)")
        }
    }

    // MARK: - Private

    private let sourceUrl: URL
    private let sourceContent: String
}
