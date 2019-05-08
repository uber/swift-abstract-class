class ChildConcrete: ChildAbstract<String, Int>, BlahProtocol {

    override var gpAbstractVar: GPVar {
        return GPVar()
    }

    override func pAbstractMethod(arg1: Int) -> Int {
        return PMethod(arg: arg1)
    }

    override func cAbstractMethod(_ a: String, b: String) -> String {
        return CMethod(a: a, b: b)
    }
}
