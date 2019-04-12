class ConcreteClassGenericType: AProtocol, GenericBaseClass<String> {

    override var genericTypeVar: String {
        return "var"
    }

    override func returnGenericType() -> String {
        return ""
    }
}
