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

/// A task that parses a Swift source content and produces concrete subclass
/// of abstract class data models.
class ConcreteSubclassProducerTask: AbstractTask<[ConcreteSubclassDefinition]> {

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
        super.init(id: TaskIds.concreteSubclassProducerTask.rawValue)
    }

    /// Execute the task and return the concrete subclass data models.
    ///
    /// - returns: The concrete subclass data models.
    /// - throws: Any error occurred during execution.
    override func execute() throws -> [ConcreteSubclassDefinition] {
        guard !abstractClassDefinitions.isEmpty else {
            return []
        }

        let file = File(contents: sourceContent)
        do {
            let structure = try Structure(file: file)

            let abstractClassNames = Set<String>(abstractClassDefinitions.map { (definition: AbstractClassDefinition) -> String in
                definition.name
            })

            return structure
                .filterSubstructure(by: SwiftDeclarationKind.class.rawValue, recursively: true)
                .compactMap { (classStructure: Structure) -> ConcreteSubclassDefinition? in
                    // If the class inherits from an abstract class, make
                    // sure it is a concrete class.
                    let inheritedTypes = classStructure.inheritedTypeNames
                    if inheritedTypes.isAnyElement(in: abstractClassNames) {
                        let hasAbstractVars = classStructure.computedVars.contains { $0.isAbstract }
                        guard !hasAbstractVars else {
                            return nil
                        }
                        let hasAbstractMethods = classStructure.methods.contains { $0.isAbstract }
                        guard !hasAbstractMethods else {
                            return nil
                        }
                        return ConcreteSubclassDefinition(name: classStructure.name, vars: classStructure.varDefinitions, methods: classStructure.methodDefinitions, inheritedTypes: inheritedTypes, filePath: sourceUrl.path)
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
    private let abstractClassDefinitions: [AbstractClassDefinition]
}

private extension Structure {

    var varDefinitions: [VarDefinition] {
        return filterSubstructure(by: SwiftDeclarationKind.varInstance.rawValue, recursively: false)
            .map { (varStructure) -> VarDefinition in
                VarDefinition(name: varStructure.name, isAbstract: false, isOverride: varStructure.isOverride)
            }
    }

    var methodDefinitions: [MethodDefinition] {
        return filterSubstructure(by: SwiftDeclarationKind.functionMethodInstance.rawValue, recursively: false)
            .map { (methodStructure) -> MethodDefinition in
                MethodDefinition(name: methodStructure.name, isAbstract: false, isOverride: methodStructure.isOverride)
            }
    }
}
