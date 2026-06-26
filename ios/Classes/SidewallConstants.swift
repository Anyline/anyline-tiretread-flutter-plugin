import Foundation

/// Method and argument keys for the `anyline_tire_sidewall_plugin` channel.
/// Kept separate from `Constants` because the Tire Sidewall (TSW) scanner is a
/// distinct product exposed over its own method channel.
struct SidewallConstants {
    static let CHANNEL = "anyline_tire_sidewall_plugin"

    static let METHOD_SCAN = "METHOD_SIDEWALL_SCAN"
    static let METHOD_IS_SUPPORTED = "METHOD_SIDEWALL_IS_SUPPORTED"
    static let METHOD_RESOLVE_PLAY_SERVICES = "METHOD_SIDEWALL_RESOLVE_PLAY_SERVICES"

    static let EXTRA_CLIENT_ID = "EXTRA_CLIENT_ID"
    static let EXTRA_CONFIG_JSON = "EXTRA_CONFIG_JSON"
}
