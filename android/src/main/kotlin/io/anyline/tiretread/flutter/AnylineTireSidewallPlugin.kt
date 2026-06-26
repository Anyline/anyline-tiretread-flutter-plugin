package io.anyline.tiretread.flutter

import android.app.Activity
import android.content.Context
import android.os.Handler
import android.os.Looper
import io.anyline.tiretread.sdk.api.AnylineTireSidewallScanner
import io.anyline.tiretread.sdk.api.ErrorCode
import io.anyline.tiretread.sdk.api.SdkError
import io.anyline.tiretread.sdk.api.TswScanResult
import io.anyline.tiretread.sdk.api.TswSupportStatus
import io.anyline.tiretread.sdk.tsw.ui.configs.TswScannerConfig
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.contentOrNull
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive

/**
 * Bridges the Tire Sidewall (TSW) scanner to Flutter over the dedicated
 * `anyline_tire_sidewall_plugin` channel.
 *
 * Registered and driven by [AnylineTireTreadPlugin], which forwards the
 * FlutterPlugin and ActivityAware lifecycle to this handler (a Flutter package
 * declares a single `pluginClass` per platform, so the second channel is set
 * up from the first plugin).
 */
class AnylineTireSidewallPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private var applicationContext: Context? = null
    private var activityPluginBinding: ActivityPluginBinding? = null
    private var pendingScanResult: Result? = null

    // The SDK delivers the scan result on a background dispatcher
    // (Dispatchers.Default); MethodChannel replies must be on the main thread.
    private val mainHandler by lazy { Handler(Looper.getMainLooper()) }
    private val mainScope = CoroutineScope(Dispatchers.Main + SupervisorJob())

    private fun onMain(block: () -> Unit) {
        if (Looper.myLooper() == Looper.getMainLooper()) {
            block()
        } else {
            mainHandler.post(block)
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, SidewallConstants.CHANNEL)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        applicationContext = null
        mainScope.cancel()
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            SidewallConstants.METHOD_SCAN -> {
                val clientId = call.argument<String>(SidewallConstants.EXTRA_CLIENT_ID) ?: ""
                val configJson = call.argument<String>(SidewallConstants.EXTRA_CONFIG_JSON)
                scan(clientId, configJson, result)
            }
            SidewallConstants.METHOD_IS_SUPPORTED -> isSupported(result)
            SidewallConstants.METHOD_RESOLVE_PLAY_SERVICES -> resolvePlayServices(result)
            else -> result.notImplemented()
        }
    }

    // ActivityAware

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityPluginBinding = binding
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activityPluginBinding = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityPluginBinding = binding
    }

    override fun onDetachedFromActivity() {
        activityPluginBinding = null
    }

    private fun hostContext(): Context? =
        activityPluginBinding?.activity ?: applicationContext

    // SDK methods

    private fun scan(clientId: String, configJson: String?, result: Result) {
        val context = hostContext()
        if (context == null) {
            result.success(
                failedOutcome(ErrorCode.INVALID_ARGUMENT, "Plugin is not attached to a context"),
            )
            return
        }
        if (pendingScanResult != null) {
            result.success(
                failedOutcome(ErrorCode.ALREADY_RUNNING, "A sidewall scan is already in progress"),
            )
            return
        }

        pendingScanResult = result
        AnylineTireSidewallScanner().scan(
            from = context,
            clientId = clientId,
            config = buildConfig(configJson),
        ) { scanResult ->
            onMain {
                val pending = pendingScanResult ?: return@onMain
                pendingScanResult = null
                pending.success(serialize(scanResult))
            }
        }
    }

    private fun isSupported(result: Result) {
        mainScope.launch {
            val status = runCatching { AnylineTireSidewallScanner.isSupported() }
                .getOrElse { t ->
                    TswSupportStatus.Unavailable(
                        error = SdkError(
                            code = ErrorCode.INTERNAL_ERROR,
                            message = t.message ?: "Failed to check device support",
                        ),
                        userResolvable = false,
                    )
                }
            result.success(serialize(status))
        }
    }

    private fun resolvePlayServices(result: Result) {
        val activity: Activity? = activityPluginBinding?.activity
        if (activity != null) {
            AnylineTireSidewallScanner.resolvePlayServices(activity)
        }
        // No-op when no Activity is available (or already resolvable elsewhere).
        result.success(null)
    }

    // Serialization

    private fun serialize(result: TswScanResult): Map<String, Any?> = when (result) {
        is TswScanResult.Completed -> mapOf(
            "kind" to "completed",
            "resultJson" to result.resultJson,
            // ByteArray is Flutter-codec-safe → surfaces as Uint8List in Dart.
            "imageBytes" to result.imageBytes,
            "environmentLighting" to result.scanMetadata.environmentLighting?.name,
        )
        is TswScanResult.Failed -> mapOf(
            "kind" to "failed",
            "error" to result.error.toMap(),
        )
        TswScanResult.Aborted -> mapOf("kind" to "aborted")
    }

    private fun serialize(status: TswSupportStatus): Map<String, Any?> = when (status) {
        is TswSupportStatus.Unavailable -> mapOf(
            "supported" to false,
            "userResolvable" to status.userResolvable,
            "error" to status.error.toMap(),
        )
        else -> mapOf("supported" to true)
    }

    private fun failedOutcome(code: ErrorCode, message: String): Map<String, Any?> = mapOf(
        "kind" to "failed",
        "error" to SdkError(code = code, message = message).toMap(),
    )

    private fun buildConfig(configJson: String?): TswScannerConfig {
        val config = TswScannerConfig()
        if (configJson.isNullOrBlank()) return config

        val root = runCatching { Json.parseToJsonElement(configJson).jsonObject }
            .getOrNull() ?: return config

        (root["correlationId"]?.jsonPrimitive?.contentOrNull)?.let { config.correlationId = it }

        (root["texts"] as? JsonObject)?.let { texts ->
            fun str(key: String): String? = texts[key]?.jsonPrimitive?.contentOrNull
            str("initializing")?.let { config.texts.textInitializing = it }
            str("alignTire")?.let { config.texts.textAlignTire = it }
            str("moveCloser")?.let { config.texts.textMoveCloser = it }
            str("moveAway")?.let { config.texts.textMoveAway = it }
            str("faceTire")?.let { config.texts.textFaceTire = it }
            str("ready")?.let { config.texts.textReady = it }
            str("holdSteady")?.let { config.texts.textHoldSteady = it }
            str("focusing")?.let { config.texts.textFocusing = it }
            str("calibratingWhiteBalance")?.let { config.texts.textCalibratingWhiteBalance = it }
            str("calibratingExposure")?.let { config.texts.textCalibratingExposure = it }
            str("tooDark")?.let { config.texts.textTooDark = it }
        }
        return config
    }
}
