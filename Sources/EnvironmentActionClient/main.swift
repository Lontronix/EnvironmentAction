import EnvironmentAction

// MARK: With no Argument

@EnvironmentAction<Void>
struct ExampleAction: Sendable { }

let exampleAction = ExampleAction {
    print("Hello World")
}

exampleAction()

// MARK: With Argument

struct SomeType { }

@EnvironmentAction<SomeType>
struct DeleteAction: Sendable { }


let exampleDeleteAction = DeleteAction { exampleItem in
    /// ... do something
}

exampleDeleteAction(SomeType())
