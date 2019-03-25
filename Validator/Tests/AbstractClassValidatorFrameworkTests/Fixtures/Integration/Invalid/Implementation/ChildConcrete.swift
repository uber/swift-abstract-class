class ChildConcrete: ChildAbstract {

    override var gpAbstractVar: GPVar {
        return GPVar()
    }

    override func pAbstractMethod(arg1: Int) -> PMethod {
        return PMethod(arg: arg1)
    }

    override func cAbstractMethod(_ a: Arg1, b: ArgB) -> CMethod {
        return CMethod(a: a, b: b)
    }
}
