class AnOutterClass {
    var someProperty: SomeAbstractC {
        return SomeAbstractC(blah: Blah(), kaa: BB())
    }

    func someMethod(index: Int) -> String {
        class ConcreteClass2: GrandParentAbstractClass {
            var grandParentVar: GrandParentVar {
                return GrandParentVar(child: self)
            }
        }
        return "concrete"
    }
}
