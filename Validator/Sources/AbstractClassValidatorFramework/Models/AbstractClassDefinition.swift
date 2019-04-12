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

/// The name of the base abstract method declaration.
let abstractMethodType = "abstractMethod"

/// A data model representing the definition of an abstract class.
struct AbstractClassDefinition: Hashable {
    /// The name of the abstract class.
    let name: String
    /// The properties, both `var` and `let` of this class.
    let vars: [VarDefinition]
    /// The method definitions.
    let methods: [MethodDefinition]
    /// The names of inherited types.
    let inheritedTypes: [String]
}

/// A data model representing the definition of a method.
struct MethodDefinition: Hashable {
    /// The name of the method.
    let name: String
    /// The return type of the method.
    let returnType: String?
    /// The parameter types of the method.
    let parameterTypes: [String]
    /// Indicates if this method is an abstract method.
    let isAbstract: Bool
    /// Indicates if this property has the override attribute.
    let isOverride: Bool
    // Parameter names do not need to be stored here, since the method
    // name encapsulates that already. The parameter label names do
    // no contribute to the uniqueness of methods.
}

/// A data model representing the definition of a computed
/// property.
struct VarDefinition: Hashable {
    /// The name of the property.
    let name: String
    /// The return type of the property.
    let returnType: String
    /// Indicates if this property is an abstract method.
    let isAbstract: Bool
    /// Indicates if this property has the override attribute.
    let isOverride: Bool
}

/// A data model representing the definition of an abstract class that
/// has been aggregated with its ancestor abstract classes.
struct AggregatedAbstractClassDefinition: Hashable {
    /// The definition itself.
    let value: AbstractClassDefinition
    /// The aggregated properties, both `var` and `let` of this class
    /// and all the properties of this class's ancestors.
    let aggregatedVars: [VarDefinition]
    /// The aggregated method definitions, including all the method
    /// definitions of this class's ancestors.
    let aggregatedMethods: [MethodDefinition]
}
