class ParentAbstract: GrandParentAbstract {

    var pConcreteVar: PVar {
        return PVar()
    }

    func pConcreteMethod() -> Blah {
        return Blah()
    }

    func pAbstractMethod(arg1: Int) -> PMethod {
        abstractMethod()
    }

    class ChildAbstract: ParentAbstract {
        var cAbstractVar: CVar {
            abstractMethod()
        }

        var cConcreteVar: ChildConcrete {
            return ChildConcrete()
        }

        func cAbstractMethod(_ a: Arg1, b: ArgB) -> CMethod {
            abstractMethod()
        }

        func cConcreteMethod() -> Int {
            return 12
        }
    }
}
