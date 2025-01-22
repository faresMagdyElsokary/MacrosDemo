/// A macro to generate a Swift struct with specified properties.
///
/// This macro validates input arguments, ensures the struct name starts with an uppercase letter,
/// and dynamically creates the struct and its properties.
///
/// - Parameters:
///   - node: The macro expansion syntax containing the struct name and fields.
///   - context: The macro expansion context.

@freestanding(declaration)
public macro generateStruct(_ name: String, fields: [String: String]) = #externalMacro(module: "MacrosDemoMacros", type: "StructGeneratorMacro")
