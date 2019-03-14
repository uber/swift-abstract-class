class RandomClassA {
    func randomMethod() {
        
    }
}

class SAbstractVarClass: AbstractClass {

    var pProperty: Object {
        abstractMethod()
    }
}

class KAbstractVarClass: AbstractClass {
    var someProperty: Int {
        abstractMethod()
    }

    var nonAbstractProperty: String {
        return "haha"
    }

    func someMethod() -> String {
        return ""
    }

    func hahaMethod() -> Haha {
        abstractMethod()
    }

    func paramMethod(_ a: HJJ, b: Bar) -> PPP {
        abstractMethod()
    }

    var someBlahProperty: Blah {
        abstractMethod()
    }
}
