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
@freestanding(expression)
public macro doubleValue(_ value: Int) -> Double = #externalMacro(module: "MacrosDemoMacros", type: "DoubleValueMacro")
