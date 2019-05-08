class ConcreteClassGenericType: GenericBaseClass<String>, AProtocol {

    override var genericTypeVar: String {
        return "var"
    }

    override func returnGenericType() -> String {
        return ""
    }
}
