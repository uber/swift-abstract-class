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

/// Extension of SourceKitten `Structure` to provide easy access to a set
/// of common abstract class AST properties.
extension Structure {

    /// All the computed properties of this structure. This does not include
    /// recursive structures.
    var computedVars: [VarDefinition] {
        var definitions = [VarDefinition]()

        var substructures = self.substructures
        while !substructures.isEmpty {
            let sub = substructures.removeFirst()

            // Swift compiler ensures overriding computed properties must
            // have explicit types, and cannot be stored properties. If
            // the substructure does not have a return type, then it's not
            // a computed property. Therefore it cannot be abstract or an
            // override of an abstract property. So we do not have to parse.
            if let subType = sub.type, subType == .varInstance, let returnType = sub.returnType {
                // If next substructure is an expression call to `abstractMethod`,
                // then the current substructure is an abstract var.
                let isAbstract: Bool
                if let nextSub = substructures.first, nextSub.isExpressionCall && nextSub.name == abstractMethodType {
                    isAbstract = true
                    // Remove the next substructure since it is the expression
                    // call to `abstractMethod`.
                    _ = substructures.removeFirst()
                } else {
                    isAbstract = false
                }

                // Properties must have return types.
                definitions.append(VarDefinition(name: sub.name, returnType: returnType, isAbstract: isAbstract))
            }
        }

        return definitions
    }

    /// All the instance methods of this structure. This does not
    /// include recursive structures.
    var methods: [MethodDefinition] {
        return filterSubstructure(by: SwiftDeclarationKind.functionMethodInstance.rawValue, recursively: false)
            .map { (methodStructure: Structure) -> MethodDefinition in
                // If method structure contains an expression call sub-structure
                // with the name `abstractMethod`, then this method is an abstract
                // method.
                let isAbstract = methodStructure.substructures.contains { (substructure: Structure) -> Bool in
                    return substructure.isExpressionCall && substructure.name == abstractMethodType
                }
                return MethodDefinition(name: methodStructure.name, returnType: methodStructure.returnType, parameterTypes: methodStructure.parameterTypes, isAbstract: isAbstract)
        }
    }

    /// The parameter types of this method structure.
    var parameterTypes: [String] {
        return substructures.compactMap { (structure: Structure) -> String? in
            if let type = structure.type, type == .varParameter {
                return structure.returnType
            }
            return nil
        }
    }
}
