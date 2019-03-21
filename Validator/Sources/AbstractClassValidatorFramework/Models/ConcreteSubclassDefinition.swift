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

/// A reference based model representing a concrete subclass of an abstract
/// class. In other words, the leaf node in an abstract class hierarchy.
struct ConcreteSubclassDefinition: Hashable {
    /// The name of the class.
    let name: String
    /// The properties, both `var` and `let` of this class.
    let vars: [VarDefinition]
    /// The methods of this class.
    let methods: [MethodDefinition]
    /// The names of inherited types.
    let inheritedTypes: [String]
}

/// A data model representing the definition of a concrete subclass of an
/// abstract class that has been aggregated with its ancestor abstract
/// classes.
struct AggregatedConcreteSubclassDefinition: Hashable {
    /// The definition itself.
    let value: ConcreteSubclassDefinition
    /// The aggregated properties, both `var` and `let` of this class
    /// and all the properties of this class's ancestors.
    let aggregatedVars: [VarDefinition]
    /// The aggregated method definitions, including all the method
    /// definitions of this class's ancestors.
    let aggregatedMethods: [MethodDefinition]
}
