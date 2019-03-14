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

    /// Execute the task and return the AST structure data model.
    ///
    /// - returns: The `AST` data model.
    /// - throws: Any error occurred during execution.
    override func execute() throws -> [AbstractClassDefinition] {
        let file = File(contents: sourceContent)
        do {
            let structure = try Structure(file: file)
            return structure.substructures.compactMap { (declaration: Structure) -> AbstractClassDefinition? in
                if let type = declaration.type, type == .class {
                    let abstractVars = declaration.abstractVars
                    let abstractMethods = declaration.abstractMethods
                    if !abstractVars.isEmpty || !abstractMethods.isEmpty {
                        return AbstractClassDefinition(name: declaration.name, abstractVars: abstractVars, abstractMethods: abstractMethods)
                    }
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

private extension Structure {

    var abstractVars: [AbstractVarDefinition] {
        var definitions = [AbstractVarDefinition]()

        var substructures = self.substructures
        while !substructures.isEmpty {
            let sub = substructures.removeFirst()
            substructures.append(contentsOf: sub.substructures)

            if let subType = sub.type, subType == .varInstance {
                // If next substructure is an expression call to `abstractMethod`,
                // then the current substructure is an abstract var.
                if let nextSub = substructures.first, nextSub.isExpressionCall && nextSub.name == abstractMethodType {
                    _ = substructures.removeFirst()
                    definitions.append(AbstractVarDefinition(name: sub.name, returnType: sub.returnType))
                }
            }
        }

        return definitions
    }

    var abstractMethods: [AbstractMethodDefinition] {
        var definitions = [AbstractMethodDefinition]()

        for sub in self.substructures {
            if let subType = sub.type, subType == .functionMethodInstance {
                // If method structure contains an expression call sub-structure
                // with the name `abstractMethod`, then this method is an abstract
                // method.
                let isAbstract = sub.substructures.contains { (s: Structure) -> Bool in
                    return s.isExpressionCall && s.name == abstractMethodType
                }
                if isAbstract {
                    let parameterTypes = sub.substructures.compactMap { (s: Structure) -> String? in
                        if let type = s.type, type == .varParameter {
                            return s.returnType
                        }
                        return nil
                    }
                    definitions.append(AbstractMethodDefinition(name: sub.name, returnType: sub.returnType, parameterTypes: parameterTypes))
                }
            }
        }

        return definitions
    }
}
