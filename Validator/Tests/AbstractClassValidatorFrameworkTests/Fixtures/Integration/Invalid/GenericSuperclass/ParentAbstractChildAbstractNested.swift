class ParentAbstract<T>: GrandParentAbstract {

    var pConcreteVar: PVar {
        return PVar()
    }

    func pConcreteMethod() -> Blah {
        return Blah()
    }

    func pAbstractMethod(arg1: T) -> T {
        abstractMethod()
    }

    class ChildAbstract<T, P>: ParentAbstract<P> {
        var cAbstractVar: CVar {
            abstractMethod()
        }

        var cConcreteVar: ChildConcrete {
            return ChildConcrete()
        }

        func cAbstractMethod(_ a: T, b: T) -> T {
            abstractMethod()
        }

        func cConcreteMethod() -> Int {
            return 12
        }
    }
}
