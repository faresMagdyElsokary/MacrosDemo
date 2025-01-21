/// This macro converts an integer literal to a Double value.
///
/// Usage:
///
/// ```swift
/// let myDouble = #doubleValue(10)
/// ```
///
/// This macro will expand to:
///
/// ```swift
/// let myDouble = Double(10)
/// ```
@freestanding(declaration)
public macro generateStruct(_ name: String, fields: [String: String]) = #externalMacro(module: "MacrosDemoMacros", type: "StructGeneratorMacro")
