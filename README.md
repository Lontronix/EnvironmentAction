# Environment Action

 A macro which is intended to be used on structs to produce action specfic types 
 that can be injected into the SwiftUI Environment.

 For example,

 ```swift
 @EnvironmentAction<Void>
 struct ExampleAction: Sendable { }
 ```

 Generates
 ```swift
 struct ExampleAction: Sendable {
    public typealias OnExampleAction = (@MainActor () -> Void)

    private let onExampleAction: OnExampleAction

    init( _ onExampleAction: @escaping OnExampleAction) {
        self.onExampleAction = onExampleAction
    }

    @MainActor
    func callAsFunction() {
        self.onExampleAction()
    }

    static let `default`: ExampleAction = .init {
        print("'ExampleAction' is not implemented!")
    }
 }
 ```

 and

 ```swift
 struct SomeType { }

 @EnvironmentAction<SomeType>
 struct DeleteAction: Sendable { }
 ```

 generates

 ```swift
 struct ExampleAction: Sendable {
    public typealias OnExample = (@MainActor (SomeType) -> Void)

    private let onExample: OnExample

    init( _ onExample: @escaping OnExample) {
        self.onExample = onExample
    }

    @MainActor
    func callAsFunction(_ arg: SomeType) {
        self.onExample(arg)
    }

    static let `default`: ExampleAction = .init {
        print("'ExampleAction' is not implemented!")
    }
 }
```

## Installation

This macro is installed like any other Swift Package, just add this to the dependencies section of your Package.swift file:


```swift
.package(url: "https://github.com/lontronix/EnvironmentAction", branch: "main")
```
