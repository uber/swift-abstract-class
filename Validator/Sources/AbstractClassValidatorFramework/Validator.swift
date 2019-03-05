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
import SourceParsingFramework

/// The set of errors the validator can throw.
public enum ValidatorError: Error {
    /// The error with a message.
    case withMessage(String)
}

/// The entry point to the abstract class validator.
public class Validator {

    /// Initializer.
    public init() {}

    /// Parse Swift source files by recurively scanning the given directories
    /// or source files included in the given source list files, excluding
    /// files with specified suffixes. Then validate the parsed code against
    /// the abstract class rules.
    ///
    /// - parameter sourceRootUrls: The directories or text files that contain
    /// a set of Swift source files to parse.
    /// - parameter sourcesListFormatValue: The optional `String` value of the
    /// format used by the sources list file. Use `nil` if the given
    /// `sourceRootPaths` is not a file containing a list of Swift source paths.
    /// - parameter exclusionSuffixes: The list of file name suffixes to
    /// check from. If a filename's suffix matches any in the this list,
    /// the file will not be parsed.
    /// - parameter exclusionPaths: The list of path components to check.
    /// If a file's URL path contains any elements in this list, the file
    /// will not be parsed.
    /// - parameter shouldCollectParsingInfo: `true` if dependency graph
    /// parsing information should be collected as tasks are executed. `false`
    /// otherwise. By collecting execution information, if waiting on the
    /// completion of a task sequence in the dependency parsing phase times out,
    /// the reported error contains the relevant information when the timeout
    /// occurred. The tracking does incur a minor performance cost. This value
    /// defaults to `false`.
    /// - parameter timeout: The timeout value, in seconds, to use for waiting
    /// on tasks.
    /// - parameter concurrencyLimit: The maximum number of tasks to execute
    /// concurrently. `nil` if no limit is set.
    /// - throws: `GeneratorError`.
    public final func validate(from sourceRootPaths: [String], withSourcesListFormat sourcesListFormatValue: String? = nil, excludingFilesEndingWith exclusionSuffixes: [String], excludingFilesWithPaths exclusionPaths: [String], shouldCollectParsingInfo: Bool, timeout: TimeInterval, concurrencyLimit: Int?) throws {
        let sourceRootUrls = sourceRootPaths.map { (path: String) -> URL in
            URL(path: path)
        }

        let executor = createExecutor(withName: "AbstractClassValidator.validate", shouldTrackTaskId: shouldCollectParsingInfo, concurrencyLimit: concurrencyLimit)

    }

    // MARK: - Private

    private func createExecutor(withName name: String, shouldTrackTaskId: Bool, concurrencyLimit: Int?) -> SequenceExecutor {
        #if DEBUG
            return ProcessInfo().environment["SINGLE_THREADED"] != nil ? ImmediateSerialSequenceExecutor() : ConcurrentSequenceExecutor(name: name, qos: .userInteractive, shouldTrackTaskId: shouldTrackTaskId, maxConcurrentTasks: concurrencyLimit)
        #else
            return ConcurrentSequenceExecutor(name: name, qos: .userInteractive, shouldTrackTaskId: shouldTrackTaskId, maxConcurrentTasks: concurrencyLimit)
        #endif
    }
}
