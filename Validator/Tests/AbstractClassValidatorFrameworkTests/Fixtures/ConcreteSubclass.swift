class ConcreteClass1: ParentAbstractClass, AProtocol {
    var someProperty: SomeAbstractC {
        return SomeAbstractC(blah: Blah(), kaa: BB())
    }

    override var grandParentVar: GrandParentVar {
        return GrandParentVar(child: self)
    }

    override func parentMethod(index: Int) -> String {
        return "concrete"
    }
}

class ConcreteClass2: GrandParentAbstractClass {
    override var grandParentVar: GrandParentVar {
        return GrandParentVar(child: self)
    }
}
