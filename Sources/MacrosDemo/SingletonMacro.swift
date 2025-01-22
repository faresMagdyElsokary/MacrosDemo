/// Macro to generate a singleton instance for a struct or class.
///
/// When applied, this macro adds a `shared` static property that holds the single instance
/// of the target struct or class.

@attached(peer)
public macro Singleton() = #externalMacro(module: "MacrosDemoMacros", type: "SingletonMacro")
