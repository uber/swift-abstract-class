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
struct ConcreteSubclassDefinition {
    /// The name of the class.
    let name: String
    /// The properties, both `var` and `let` of this class.
    let properties: [VarDefinition]
    /// The methods of this class.
    let methods: [MethodDefinition]
    /// The names of inherited types.
    let inheritedTypes: [String]
}
