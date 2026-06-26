package io.anyline.tiretread.flutter

import android.content.Context
import android.os.Handler
import android.os.Looper
import io.anyline.tiretread.sdk.AnylineTireTreadSdk
import io.anyline.tiretread.sdk.InternalAPI
import io.anyline.tiretread.sdk.api.AnylineTireTread
import io.anyline.tiretread.sdk.api.AnylineTireTreadScanner
import io.anyline.tiretread.sdk.api.Bridge
import io.anyline.tiretread.sdk.api.ErrorCode
import io.anyline.tiretread.sdk.api.FailedOutcome
import io.anyline.tiretread.sdk.api.InitOptions
import io.anyline.tiretread.sdk.api.ScanOutcome
import io.anyline.tiretread.sdk.api.SdkError
import io.anyline.tiretread.sdk.api.SdkResult
import io.anyline.tiretread.sdk.types.MeasurementInfo
import io.anyline.tiretread.sdk.types.TreadResultRegion
import io.anyline.tiretread.sdk.types.WrapperInfo
import org.json.JSONObject

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.serialization.json.Json
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.booleanOrNull
import kotlinx.serialization.json.doubleOrNull
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive

class AnylineTireTreadPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private var applicationContext: Context? = null
    private var activityPluginBinding: ActivityPluginBinding? = null
    private var pendingScanResult: Result? = null

    // The Tire Sidewall (TSW) scanner is exposed over its own channel. A Flutter
    // package declares a single pluginClass per platform, so this plugin owns
    // the sidewall handler and forwards the FlutterPlugin/ActivityAware lifecycle.
    private val sidewallPlugin = AnylineTireSidewallPlugin()

    // SDK v15 invokes its callbacks on a background dispatcher (Dispatchers.IO).
    // MethodChannel results must be delivered on the platform (main) thread, so
    // every SDK callback is marshalled through this handler. Lazy so the class
    // can still be instantiated in JVM unit tests without a prepared Looper.
    private val mainHandler by lazy { Handler(Looper.getMainLooper()) }

    private fun onMain(block: () -> Unit) {
        if (Looper.myLooper() == Looper.getMainLooper()) {
            block()
        } else {
            mainHandler.post(block)
        }
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "anyline_tire_tread_plugin")
        channel.setMethodCallHandler(this)
        sidewallPlugin.onAttachedToEngine(flutterPluginBinding)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            Constants.METHOD_INITIALIZE -> {
                val licenseKey = call.argument<String>(Constants.EXTRA_LICENSE_KEY) ?: ""
                val pluginVersion = call.argument<String>(Constants.EXTRA_PLUGIN_VERSION) ?: ""
                val customTag = call.argument<String>(Constants.EXTRA_CUSTOM_TAG)
                initializeSdk(licenseKey, pluginVersion, customTag, result)
            }
            Constants.METHOD_GET_SDK_VERSION -> {
                result.success(AnylineTireTread.sdkVersion)
            }
            Constants.METHOD_SCAN -> {
                val configJson = call.argument<String>(Constants.EXTRA_CONFIG_JSON)
                val optionsJson = call.argument<String>(Constants.EXTRA_SCAN_OPTIONS_JSON)
                scan(configJson, optionsJson, result)
            }
            Constants.METHOD_IS_DEVICE_SUPPORTED -> {
                isDeviceSupported(result)
            }
            Constants.METHOD_GET_RESULT -> {
                val uuid = call.argument<String>(Constants.EXTRA_MEASUREMENT_UUID) ?: ""
                val timeout = call.argument<Int>(Constants.EXTRA_TIMEOUT_SECONDS)
                getResult(uuid, timeout, result)
            }
            Constants.METHOD_GET_HEATMAP -> {
                val uuid = call.argument<String>(Constants.EXTRA_MEASUREMENT_UUID) ?: ""
                val timeout = call.argument<Int>(Constants.EXTRA_TIMEOUT_SECONDS)
                getHeatmap(uuid, timeout, result)
            }
            Constants.METHOD_SEND_FEEDBACK_COMMENT -> {
                val uuid = call.argument<String>(Constants.EXTRA_MEASUREMENT_UUID) ?: ""
                val comment = call.argument<String>(Constants.EXTRA_FEEDBACK_COMMENT) ?: ""
                sendCommentFeedback(uuid, comment, result)
            }
            Constants.METHOD_SEND_TREAD_DEPTH_RESULT_FEEDBACK -> {
                val uuid = call.argument<String>(Constants.EXTRA_MEASUREMENT_UUID) ?: ""
                val regionsJson = call.argument<String>(Constants.EXTRA_TREAD_DEPTH_RESULT_FEEDBACK) ?: "[]"
                sendTreadDepthResultFeedback(uuid, parseFeedbackRegions(regionsJson), result)
            }
            Constants.METHOD_SEND_TIRE_ID_FEEDBACK -> {
                val uuid = call.argument<String>(Constants.EXTRA_MEASUREMENT_UUID) ?: ""
                val tireId = call.argument<String>(Constants.EXTRA_TIRE_ID) ?: ""
                sendTireIdFeedback(uuid, tireId, result)
            }
            Constants.METHOD_SET_EXPERIMENTAL_FLAGS -> {
                setExperimentalFlags(call, result)
            }
            Constants.METHOD_CLEAR_EXPERIMENTAL_FLAGS -> {
                clearExperimentalFlags(result)
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        applicationContext = null
        sidewallPlugin.onDetachedFromEngine(binding)
    }

    // ActivityAware

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityPluginBinding = binding
        sidewallPlugin.onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activityPluginBinding = null
        sidewallPlugin.onDetachedFromActivityForConfigChanges()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityPluginBinding = binding
        sidewallPlugin.onReattachedToActivityForConfigChanges(binding)
    }

    override fun onDetachedFromActivity() {
        activityPluginBinding = null
        sidewallPlugin.onDetachedFromActivity()
    }

    /// Prefer the current Activity; fall back to the application context
    /// (matches the React Native wrapper's `currentActivity ?: context`).
    private fun hostContext(): Context? =
        activityPluginBinding?.activity ?: applicationContext

    // SDK methods

    private fun initializeSdk(
        licenseKey: String, pluginVersion: String, customTag: String?, result: Result
    ) {
        val context = hostContext()
        if (context == null) {
            result.error(ErrorCode.INVALID_ARGUMENT.name, "Plugin is not attached to a context", null)
            return
        }

        AnylineTireTread.initialize(
            context = context,
            licenseKey = licenseKey,
            options = InitOptions(
                customTag = customTag?.trim().takeUnless { it.isNullOrEmpty() },
                wrapperInfo = WrapperInfo.Flutter(pluginVersion)
            )
        ) { sdkResult ->
            onMain {
                when (sdkResult) {
                    is SdkResult.Ok -> result.success(true)
                    is SdkResult.Err -> result.error(
                        sdkResult.error.code.name,
                        sdkResult.error.message,
                        sdkResult.error.debug?.toString()
                    )
                }
            }
        }
    }

    private fun scan(configJson: String?, optionsJson: String?, result: Result) {
        val context = hostContext()
        if (context == null) {
            val outcome = FailedOutcome(
                measurementUUID = null,
                error = SdkError(
                    code = ErrorCode.INVALID_ARGUMENT,
                    message = "Plugin is not attached to a context"
                )
            )
            result.success(sanitizedOutcome(outcome))
            return
        }

        if (pendingScanResult != null) {
            val outcome = FailedOutcome(
                measurementUUID = null,
                error = SdkError(
                    code = ErrorCode.ALREADY_RUNNING,
                    message = "A scan is already in progress"
                )
            )
            result.success(sanitizedOutcome(outcome))
            return
        }

        pendingScanResult = result

        AnylineTireTreadScanner().scan(
            from = context,
            configJson = configJson,
            optionsJson = optionsJson,
        ) { outcome ->
            onMain {
                val pending = pendingScanResult ?: return@onMain
                pendingScanResult = null
                pending.success(sanitizedOutcome(outcome))
            }
        }
    }

    private fun isDeviceSupported(result: Result) {
        val context = hostContext()
        if (context == null) {
            result.error(
                ErrorCode.INVALID_ARGUMENT.name,
                "Plugin is not attached to a context",
                null
            )
            return
        }
        AnylineTireTread.isDeviceSupported(context) { sdkResult ->
            onMain {
                when (sdkResult) {
                    is SdkResult.Ok -> result.success(sdkResult.result)
                    is SdkResult.Err -> result.error(
                        sdkResult.error.code.name,
                        sdkResult.error.message,
                        sdkResult.error.debug?.toString()
                    )
                }
            }
        }
    }

    private fun getResult(uuid: String, timeoutSeconds: Int?, result: Result) {
        AnylineTireTread.getResult(
            measurementUUID = uuid,
            timeoutSeconds = timeoutSeconds ?: 60,
        ) { sdkResult ->
            onMain {
                when (sdkResult) {
                    is SdkResult.Ok -> result.success(Json.encodeToString(sdkResult.result))
                    is SdkResult.Err -> result.error(
                        sdkResult.error.code.name,
                        sdkResult.error.message,
                        sdkResult.error.debug?.toString()
                    )
                }
            }
        }
    }

    private fun getHeatmap(uuid: String, timeoutSeconds: Int?, result: Result) {
        AnylineTireTread.getHeatmap(
            measurementUUID = uuid,
            timeoutSeconds = timeoutSeconds ?: 60,
        ) { sdkResult ->
            onMain {
                when (sdkResult) {
                    is SdkResult.Ok -> result.success(sdkResult.result.url)
                    is SdkResult.Err -> result.error(
                        sdkResult.error.code.name,
                        sdkResult.error.message,
                        sdkResult.error.debug?.toString()
                    )
                }
            }
        }
    }

    private fun sendCommentFeedback(uuid: String, comment: String, result: Result) {
        AnylineTireTread.sendCommentFeedback(
            measurementUUID = uuid,
            comment = comment
        ) { sdkResult ->
            onMain {
                when (sdkResult) {
                    is SdkResult.Ok -> result.success(measurementInfoJson(sdkResult.result))
                    is SdkResult.Err -> result.error(
                        sdkResult.error.code.name,
                        sdkResult.error.message,
                        null
                    )
                }
            }
        }
    }

    private fun sendTreadDepthResultFeedback(
        uuid: String, regions: List<TreadResultRegion>, result: Result
    ) {
        AnylineTireTread.sendTreadDepthResultFeedback(
            measurementUUID = uuid,
            treadResultRegions = regions
        ) { sdkResult ->
            onMain {
                when (sdkResult) {
                    is SdkResult.Ok -> result.success(measurementInfoJson(sdkResult.result))
                    is SdkResult.Err -> result.error(
                        sdkResult.error.code.name,
                        sdkResult.error.message,
                        null
                    )
                }
            }
        }
    }

    private fun sendTireIdFeedback(uuid: String, tireId: String, result: Result) {
        AnylineTireTread.sendTireIdFeedback(
            measurementUUID = uuid,
            tireId = tireId
        ) { sdkResult ->
            onMain {
                when (sdkResult) {
                    is SdkResult.Ok -> result.success(measurementInfoJson(sdkResult.result))
                    is SdkResult.Err -> result.error(
                        sdkResult.error.code.name,
                        sdkResult.error.message,
                        null
                    )
                }
            }
        }
    }

    @OptIn(InternalAPI::class)
    private fun setExperimentalFlags(call: MethodCall, result: Result) {
        val flags: List<String>? = call.argument(Constants.EXTRA_EXPERIMENTAL_FLAGS)
        if (flags != null) {
            AnylineTireTreadSdk.setExperimentalFlags(newFlags = flags)
            result.success(true)
        } else {
            result.error(ErrorCode.INVALID_ARGUMENT.name, "Experimental flags are null", null)
        }
    }

    @OptIn(InternalAPI::class)
    private fun clearExperimentalFlags(result: Result) {
        AnylineTireTreadSdk.clearExperimentalFlags()
        result.success(true)
    }

    /// Builds feedback regions from `available` + `value_mm` only, via
    /// `TreadResultRegion.initMm` — mirroring the RN wrapper and the iOS
    /// implementation. Deserializing the full region JSON would let the
    /// `value_inch_32nds` setter re-quantize `value_mm` and lose precision.
    private fun parseFeedbackRegions(regionsJson: String): List<TreadResultRegion> =
        Json.parseToJsonElement(regionsJson).jsonArray.map { element ->
            val region = element.jsonObject
            TreadResultRegion.initMm(
                isAvailable = region["available"]?.jsonPrimitive?.booleanOrNull ?: false,
                value = region["value_mm"]?.jsonPrimitive?.doubleOrNull ?: 0.0
            )
        }

    private fun sanitizedOutcome(outcome: ScanOutcome): Map<String, Any?> {
        val raw = Bridge.outcome(outcome)
        return raw.filterKeys { it in OUTCOME_KEYS }
    }

    /// Serializes a [MeasurementInfo] to the JSON shape the Dart
    /// `MeasurementInfo.fromJson` expects, built from its typed properties.
    private fun measurementInfoJson(info: MeasurementInfo): String {
        val json = JSONObject()
        json.put("measurementUUID", info.measurementUUID)
        json.put("status", info.status.name)
        info.additionalContext?.let { context ->
            val contextJson = JSONObject()
            context.correlationId?.let { contextJson.put("correlationId", it) }
            context.tirePosition?.let { position ->
                contextJson.put(
                    "tirePosition",
                    JSONObject()
                        .put("axle", position.axle)
                        .put("positionOnAxle", position.positionOnAxle)
                        .put("side", position.side.name)
                )
            }
            if (contextJson.length() > 0) {
                json.put("additionalContext", contextJson)
            }
        }
        return json.toString()
    }

    companion object {
        private val OUTCOME_KEYS = setOf("kind", "measurementUUID", "error")
    }
}
