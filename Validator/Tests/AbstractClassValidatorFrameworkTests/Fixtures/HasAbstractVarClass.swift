class RandomClassA {
    func randomMethod() {
        
    }
}

class SomeAbstractVarClass: AbstractClass {
    var someProperty: Int {
        abstractMethod()
    }

    var nonAbstractProperty: String {
        return "haha"
    }

    func someMethod() -> String {
        return ""
    }

    var anotherNonAbstractProperty: Object {
        return someMethodObj()
    }

    var someBlahProperty: Blah {
        abstractMethod()
    }
}
