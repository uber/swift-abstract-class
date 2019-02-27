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
import Utility

/// The validate command provides the core functionality of Abstract
/// Class Validator. It parses Swift source files specified by the
/// given input, excluding files with specified suffixes. It then checks
/// a set of abstract class rules to ensure they are not violated.
class ValidateCommand: AbstractCommand {

    /// Initializer.
    ///
    /// - parameter parser: The argument parser to use.
    init(parser: ArgumentParser) {
        super.init(name: "validate", overview: "Validate abstract class rules for Swift source files in a directory or listed in a single text file.", parser: parser)
    }

    /// Setup the arguments using the given parser.
    ///
    /// - parameter parser: The argument parser to use.
    override func setupArguments(with parser: ArgumentParser) {
        super.setupArguments(with: parser)

        sourceRootPaths = parser.add(positional: "sourceRootPaths", kind: [String].self, strategy: ArrayParsingStrategy.upToNextOption, usage: "Paths to the root folders of Swift source files, or text files containing paths of Swift source files with specified format.", completion: .filename)
        sourcesListFormat = parser.add(option: "--sources-list-format", kind: String.self, usage: "The format of the Swift sources list file. See SourcesListFileFormat for supported format details", completion: .filename)
        excludeSuffixes = parser.add(option: "--exclude-suffixes", kind: [String].self, usage: "Filename suffix(es) without extensions to exclude from parsing.", completion: .filename)
        excludePaths = parser.add(option: "--exclude-paths", kind: [String].self, usage: "Paths components to exclude from parsing.")
        shouldCollectParsingInfo = parser.add(option: "--collect-parsing-info", shortName: "-cpi", kind: Bool.self, usage: "Whether or not to collect information for parsing execution timeout errors.")
        timeout = parser.add(option: "--timeout", kind: Int.self, usage: "The timeout value, in seconds, to use for waiting on parsing and validating tasks.")
        concurrencyLimit = parser.add(option: "--concurrency-limit", kind: Int.self, usage: "The maximum number of tasks to execute concurrently.")
    }

    /// Execute the command.
    ///
    /// - parameter arguments: The command line arguments to execute the
    /// command with.
    override func execute(with arguments: ArgumentParser.Result) {
        super.execute(with: arguments)

        if let sourceRootPaths = arguments.get(sourceRootPaths) {
            let sourcesListFormat = arguments.get(self.sourcesListFormat) ?? nil
            let excludeSuffixes = arguments.get(self.excludeSuffixes) ?? []
            let excludePaths = arguments.get(self.excludePaths) ?? []
            let shouldCollectParsingInfo = arguments.get(self.shouldCollectParsingInfo) ?? false
            let timeout = arguments.get(self.timeout, withDefault: defaultTimeout)
            let concurrencyLimit = arguments.get(self.concurrencyLimit) ?? nil
        } else {
            fatalError("Missing source files root directories.")
        }
    }

    // MARK: - Private

    private var sourceRootPaths: PositionalArgument<[String]>!
    private var sourcesListFormat: OptionArgument<String>!
    private var excludeSuffixes: OptionArgument<[String]>!
    private var excludePaths: OptionArgument<[String]>!
    private var shouldCollectParsingInfo: OptionArgument<Bool>!
    private var timeout: OptionArgument<Int>!
    private var concurrencyLimit: OptionArgument<Int>!
}
