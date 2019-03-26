class GrandParentAbstract: AbstractClass {
    var gpAbstractVar: GPVar {
        abstractMethod()
    }

    let gpLet = "haha"

    var gpConcreteVar: Int {
        return 21
    }

    func gpConcreteMethod() -> String {
        return "blah"
    }

    func gpAbstractMethod() -> GPMethod {
        abstractMethod()
    }
}
