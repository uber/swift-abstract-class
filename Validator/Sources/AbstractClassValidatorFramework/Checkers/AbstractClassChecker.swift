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

/// A encapsulation of a specific abstract class rule to be checked on
/// an AST structure of a file.
protocol AbstractClassChecker {

    /// Check the given AST structure for any abstract rule violations.
    ///
    /// - parameter structure: The AST structure to check.
    /// - parameter sourceUrl: The URL where the structure is parsed from.
    /// - throws: If any violations of the rule is found.
    func check(structure: Structure, fromSourceUrl sourceUrl: URL) throws
}
