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
//  WITHOUT WARRANTIES OR COITIONS OF ANY KI, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

/// A protocol declaring the conforming class as an abstract class.
/// This means the conforming class cannot be directly instantiated,
/// and it may contain abstract methods that subclasses must provide
/// implementations for.
public protocol AbstractClass: AnyObject {

    /// Using this definition declares the enclosing method as an abstract
    /// method, where subclasses of the enclosing class must override and
    /// provide a concrete implementation for.
    ///
    /// - note: Actual abstract classes that conform to the protocol
    /// `AbstractClass` should not actually implement this method.
    /// Instead a default implementation is provided via a protocol
    /// extension of the `AbstractClass` protocol.
    func abstractMethod(_ functionName: String) -> Never
}

/// Extension providing the default implementation of `abstractMethod`.
public extension AbstractClass {

    /// Using this definition declares the enclosing method as an abstract
    /// method, where subclasses of the enclosing class must override and
    /// provide a concrete implementation for.
    public func abstractMethod(_ functionName: String = #function) -> Never {
        fatalError("Abstract method \(functionName) is not implemented.")
    }
}
