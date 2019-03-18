class MiddleAbstractClass: GrandParentAbstractClass {
    var someProperty: SomeAbstractC {
        return SomeAbstractC(blah: Blah(), kaa: BB())
    }

    func someMethod() -> String {
        abstractMethod()
    }
}
