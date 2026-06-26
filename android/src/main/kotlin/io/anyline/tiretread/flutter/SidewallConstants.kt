package io.anyline.tiretread.flutter

/// Method and argument keys for the `anyline_tire_sidewall_plugin` channel.
/// Kept separate from [Constants] because the Tire Sidewall (TSW) scanner is a
/// distinct product exposed over its own method channel.
object SidewallConstants {
    const val CHANNEL = "anyline_tire_sidewall_plugin"

    const val METHOD_SCAN = "METHOD_SIDEWALL_SCAN"
    const val METHOD_IS_SUPPORTED = "METHOD_SIDEWALL_IS_SUPPORTED"
    const val METHOD_RESOLVE_PLAY_SERVICES = "METHOD_SIDEWALL_RESOLVE_PLAY_SERVICES"

    const val EXTRA_CLIENT_ID = "EXTRA_CLIENT_ID"
    const val EXTRA_CONFIG_JSON = "EXTRA_CONFIG_JSON"
}
