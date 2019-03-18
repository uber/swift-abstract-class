class ConcreteClass1: ParentAbstractClass, AProtocol {
    var someProperty: SomeAbstractC {
        return SomeAbstractC(blah: Blah(), kaa: BB())
    }

    var grandParentVar: GrandParentVar {
        return GrandParentVar(child: self)
    }

    func parentMethod(index: Int) -> String {
        return "concrete"
    }
}

class ConcreteClass2: GrandParentAbstractClass {
    var grandParentVar: GrandParentVar {
        return GrandParentVar(child: self)
    }
}
