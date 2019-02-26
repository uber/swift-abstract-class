# Abstract Class Validator

## Building and developing

### Compiling from source:

First resolve the dependencies:

```
$ swift package update
```

You can then build from the command-line:

```
$ swift build
```

Or create an Xcode project and build using the IDE:

```
$ swift package generate-xcodeproj
```
Note: For now, the xcconfig is being used to pass in the DEBUG define.

### Debugging

Abstract Class Validator is intended to be heavily multi-threaded. This makes stepping through the code rather complicated. To simplify the debugging process, set the `SINGLE_THREADED` enviroment variable for your `Run` configuration in the Scheme Editor to `1` or `YES`.

## Releasing

```
make archieve_validator
```
