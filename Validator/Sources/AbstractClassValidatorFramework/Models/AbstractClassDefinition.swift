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
struct AbstractClassDefinition: Equatable {
    /// The name of the abstract class.
    let name: String
    /// The abstract vars.
    let abstractVars: [AbstractVarDefinition]
    /// The abstract methods.
    let abstractMethods: [AbstractMethodDefinition]
    /// The names of inherited types.
    let inheritedTypes: [String]
}

/// A data model representing the definition of an abstract method.
struct AbstractMethodDefinition: Equatable {
    /// The name of the abstract method.
    let name: String
    /// The return type of the abstract method.
    let returnType: String
    /// The parameter types of the abstract method.
    let parameterTypes: [String]
    // Parameter names do not need to stored here, since the method
    // name encapsulates that already. The parameter label names do
    // no contribute to the uniqueness of methods.
}

/// A data model representing the definition of an abstract computed
/// property.
struct AbstractVarDefinition: Equatable {
    /// The name of the abstract method.
    let name: String
    /// The return type of the abstract method.
    let returnType: String
}
