class RandomClassA {
    func randomMethod() {
        
    }
}

class OutterAbstractClass: AbstractClass {
    var someProperty: Int {
        abstractMethod()
    }

    var nonAbstractProperty: String {
        class InnerAbstractClassA: AbstractClass {
            func innerAbstractMethodA() {
                abstractMethod()
            }
        }
        return "haha"
    }

    func someMethod() -> String {
        class InnerAbstractClassB: AbstractClass {
            var innerAbstractVarB: Int {
                abstractMethod()
            }
            func yoMethod() -> Yo {
                abstractMethod()
            }
        }
        return ""
    }

    func paramMethod(_ a: HJJ, b: Bar) -> PPP {
        abstractMethod()
    }
}
