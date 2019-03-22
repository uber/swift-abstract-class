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
        let abstractClassDefinitions = try parseAbstractClassDefinitions(from: sourceRootUrls, withSourcesListFormat: sourcesListFormatValue, excludingFilesEndingWith: exclusionSuffixes, excludingFilesWithPaths: exclusionPaths, using: executor, waitUpTo: timeout)

        try validateExpressionCalls(from: sourceRootUrls, withSourcesListFormat: sourcesListFormatValue, excludingFilesEndingWith: exclusionSuffixes, excludingFilesWithPaths: exclusionPaths, against: abstractClassDefinitions, using: executor, waitUpTo: timeout)
    }

    // MARK: - Private

    // MARK: - Task Execution

    private func createExecutor(withName name: String, shouldTrackTaskId: Bool, concurrencyLimit: Int?) -> SequenceExecutor {
        #if DEBUG
            return ProcessInfo().environment["SINGLE_THREADED"] != nil ? ImmediateSerialSequenceExecutor() : ConcurrentSequenceExecutor(name: name, qos: .userInteractive, shouldTrackTaskId: shouldTrackTaskId, maxConcurrentTasks: concurrencyLimit)
        #else
            return ConcurrentSequenceExecutor(name: name, qos: .userInteractive, shouldTrackTaskId: shouldTrackTaskId, maxConcurrentTasks: concurrencyLimit)
        #endif
    }

    private func executeAndCollectTaskHandles<ResultType>(with rootUrls: [URL], sourcesListFormatValue: String?, execution: (URL) -> SequenceExecutionHandle<ResultType>) throws -> [(SequenceExecutionHandle<ResultType>, URL)] {
        var urlHandles = [(SequenceExecutionHandle<ResultType>, URL)]()

        // Enumerate all files and execute parsing sequences concurrently.
        let enumerator = FileEnumerator()
        for url in rootUrls {
            try enumerator.enumerate(from: url, withSourcesListFormat: sourcesListFormatValue) { (fileUrl: URL) in
                let taskHandle = execution(fileUrl)
                urlHandles.append((taskHandle, fileUrl))
            }
        }

        return urlHandles
    }

    // MARK: - Abstract Class Definitions

    private func parseAbstractClassDefinitions(from sourceRootUrls: [URL], withSourcesListFormat sourcesListFormatValue: String?, excludingFilesEndingWith exclusionSuffixes: [String], excludingFilesWithPaths exclusionPaths: [String], using executor: SequenceExecutor, waitUpTo timeout: TimeInterval) throws -> [AbstractClassDefinition] {
        // Parse all URLs.
        let urlTaskHandles = try executeAndCollectTaskHandles(with: sourceRootUrls, sourcesListFormatValue: sourcesListFormatValue) { (fileUrl: URL) -> SequenceExecutionHandle<[AbstractClassDefinition]> in
            let filterTask = DeclarationFilterTask(url: fileUrl, exclusionSuffixes: exclusionSuffixes, exclusionPaths: exclusionPaths)

            return executor.executeSequence(from: filterTask) { (currentTask: Task, currentResult: Any) -> SequenceExecution<[AbstractClassDefinition]> in
                if currentTask is DeclarationFilterTask, let filterResult = currentResult as? FilterResult {
                    switch filterResult {
                    case .shouldProcess(let url, let content):
                        return .continueSequence(DeclarationProducerTask(sourceUrl: url, sourceContent: content))
                    case .skip:
                        return .endOfSequence([AbstractClassDefinition]())
                    }
                } else if currentTask is DeclarationProducerTask, let definitions = currentResult as? [AbstractClassDefinition] {
                    return .endOfSequence(definitions)
                } else {
                    fatalError("Unhandled task \(currentTask) with result \(currentResult)")
                }
            }
        }

        // Wait for parsing results.
        var definitions = [AbstractClassDefinition]()
        for urlHandle in urlTaskHandles {
            do {
                let result = try urlHandle.0.await(withTimeout: timeout)
                definitions.append(contentsOf: result)
            } catch SequenceExecutionError.awaitTimeout(let taskId) {
                throw GenericError.withMessage("Processing \(urlHandle.1.path) timed out while executing task with Id \(taskId)")
            } catch {
                throw error
            }
        }

        return definitions
    }

    // MARK: - Expression Call Validation

    private func validateExpressionCalls(from sourceRootUrls: [URL], withSourcesListFormat sourcesListFormatValue: String?, excludingFilesEndingWith exclusionSuffixes: [String], excludingFilesWithPaths exclusionPaths: [String], against abstractClassDefinitions: [AbstractClassDefinition], using executor: SequenceExecutor, waitUpTo timeout: TimeInterval) throws {
        let urlTaskHandles = try executeAndCollectTaskHandles(with: sourceRootUrls, sourcesListFormatValue: sourcesListFormatValue) { (fileUrl: URL) -> SequenceExecutionHandle<ValidationResult> in
            let filterTask = ExpressionCallUsageFilterTask(url: fileUrl, exclusionSuffixes: exclusionSuffixes, exclusionPaths: exclusionPaths, abstractClassDefinitions: abstractClassDefinitions)

            return executor.executeSequence(from: filterTask) { (currentTask: Task, currentResult: Any) -> SequenceExecution<ValidationResult> in
                if currentTask is ExpressionCallUsageFilterTask, let filterResult = currentResult as? FilterResult {
                    switch filterResult {
                    case .shouldProcess(let url, let content):
                        return .continueSequence(ExpressionCallValidationTask(sourceUrl: url, sourceContent: content, abstractClassDefinitions: abstractClassDefinitions))
                    case .skip:
                        return .endOfSequence(.success)
                    }
                } else if currentTask is ExpressionCallValidationTask, let validationResult = currentResult as? ValidationResult {
                    return .endOfSequence(validationResult)
                } else {
                    fatalError("Unhandled task \(currentTask) with result \(currentResult)")
                }
            }
        }

        for urlHandle in urlTaskHandles {
            do {
                let result = try urlHandle.0.await(withTimeout: timeout)
                switch result {
                case .success:
                    break
                case .failureWithReason(let reason):
                    throw GenericError.withMessage(reason)
                }
            } catch SequenceExecutionError.awaitTimeout(let taskId) {
                throw GenericError.withMessage("Processing \(urlHandle.1.path) timed out while executing task with Id \(taskId)")
            } catch {
                throw error
            }
        }
    }
}
