
public protocol ViewConfigurableProtocol {}

@attached(extension, conformances: ViewConfigurableProtocol, names: arbitrary)
public macro ViewConfigurable() = #externalMacro(module: "ViewConfigurableMacros", type: "ViewConfigurableMacro")
