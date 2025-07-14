package io.anyline.tiretread.flutter

import android.app.Activity
import android.content.Intent
import android.util.Log
import androidx.lifecycle.lifecycleScope
import kotlinx.coroutines.launch

import io.anyline.tiretread.sdk.AnylineTireTreadSdk
import io.anyline.tiretread.sdk.InternalAPI
import io.anyline.tiretread.sdk.NoConnectionException
import io.anyline.tiretread.sdk.Response
import io.anyline.tiretread.sdk.SdkLicenseKeyForbiddenException
import io.anyline.tiretread.sdk.SdkLicenseKeyInvalidException
import io.anyline.tiretread.sdk.init
import io.anyline.tiretread.sdk.scanner.MeasurementSystem
import io.anyline.tiretread.sdk.scanner.ScanSpeed
import io.anyline.tiretread.sdk.types.WrapperInfo
import io.anyline.tiretread.sdk.sendCommentFeedback
import io.anyline.tiretread.sdk.sendTreadDepthResultFeedback
import io.anyline.tiretread.sdk.types.TreadResultRegion
import io.anyline.tiretread.sdk.config.TireTreadConfig
import io.anyline.tiretread.sdk.config.HeatmapStyle
import io.anyline.tiretread.sdk.types.AdditionalContext
import io.anyline.tiretread.sdk.types.TirePosition
import io.anyline.tiretread.sdk.types.TireSide
import io.anyline.tiretread.sdk.getTreadDepthReportResult
import io.anyline.tiretread.sdk.getHeatmap
import io.anyline.tiretread.wrapper.encodeToString

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.serialization.json.Json
import kotlinx.serialization.encodeToString
import org.json.JSONObject

/** AnylineTireTreadPlugin */
class AnylineTireTreadPlugin : FlutterPlugin, MethodCallHandler, ActivityAware,
    PluginRegistry.ActivityResultListener {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel

    private var activityPluginBinding: ActivityPluginBinding? = null
    private var pendingScanResult: Result? = null

    private val TAG = AnylineTireTreadPlugin::class.qualifiedName
    private val SCAN_REQUEST_CODE = 1001

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "anyline_tire_tread_plugin")
        channel.setMethodCallHandler(this)

        eventChannel =
            EventChannel(flutterPluginBinding.binaryMessenger, "anyline_tire_tread_plugin/events")
        eventChannel.setStreamHandler(TTEventHandler.shared)
    }

    @OptIn(InternalAPI::class)
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            Constants.METHOD_INITIALIZE -> {
                val licenseKey: String =
                    call.argument<String?>(Constants.EXTRA_LICENSE_KEY).toString()
                val pluginVersion: String =
                    call.argument<String?>(Constants.EXTRA_PLUGIN_VERSION).toString()
                initializeSdk(licenseKey, pluginVersion, result)
            }

            Constants.METHOD_GET_SDK_VERSION -> {
                result.success(AnylineTireTreadSdk.sdkVersion)
            }

            Constants.METHOD_SCAN -> {
                (call.arguments as Map<String, Any>).also { tireTreadConfigMap ->
                    scan(tireTreadConfigMap, result)
                }
            }

            Constants.METHOD_GET_RESULT -> {
                val measurementUUID: String =
                    call.argument<String?>(Constants.EXTRA_MEASUREMENT_UUID).toString()
                getMeasurementResult(measurementUUID, result)
            }

            Constants.METHOD_GET_HEATMAP -> {
                val measurementUUID: String =
                    call.argument<String?>(Constants.EXTRA_MEASUREMENT_UUID).toString()
                getHeatMapResult(measurementUUID, result)
            }

            Constants.METHOD_SEND_FEEDBACK_COMMENT -> {
                val measurementUUID: String =
                    call.argument<String?>(Constants.EXTRA_MEASUREMENT_UUID).toString()
                val comment: String =
                    call.argument<String?>(Constants.EXTRA_FEEDBACK_COMMENT).toString()
                sendCommentFeedback(measurementUUID, comment, result)
            }

            Constants.METHOD_SEND_TREAD_DEPTH_RESULT_FEEDBACK -> {
                val measurementUUID: String =
                    call.argument<String?>(Constants.EXTRA_MEASUREMENT_UUID).toString()
                val data: List<TreadResultRegion> =
                    Json.decodeFromString<List<TreadResultRegion>>(call.argument<String?>(Constants.EXTRA_TREAD_DEPTH_RESULT_FEEDBACK).toString())
                sendTreadDepthResultFeedback(measurementUUID, data, result)
            }

            Constants.METHOD_SET_EXPERIMENTAL_FLAGS -> {
                val experimentalFlags: List<String>? = call.argument(Constants.EXTRA_EXPERIMENTAL_FLAGS)
                if (experimentalFlags != null) {
                    AnylineTireTreadSdk.setExperimentalFlags(newFlags = experimentalFlags)
                    result.success(true)
                } else {
                    result.error("INVALID_ARGUMENT", Constants.ERROR_MESSAGE_EXPERIMENTAL_FLAGS_NULL, null)
                }
            }

            Constants.METHOD_CLEAR_EXPERIMENTAL_FLAGS -> {
                AnylineTireTreadSdk.clearExperimentalFlags()
                result.success(true)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    /// ActivityAware

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityPluginBinding = binding
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        this.onDetachedFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        this.onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        activityPluginBinding?.removeActivityResultListener(this)
        activityPluginBinding = null
    }
    
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == SCAN_REQUEST_CODE) {
            pendingScanResult?.let { result ->
                pendingScanResult = null
                
                when (resultCode) {
                    Activity.RESULT_OK -> result.success(null)
                    Activity.RESULT_CANCELED -> {
                        val errorMessage = data?.getStringExtra(ScanTireTreadActivity.RESULT_ERROR_MESSAGE) ?: Constants.ERROR_MESSAGE_SCAN_CANCELLED
                        result.error("SCAN_ERROR", errorMessage, null)
                    }
                }
            }
            return true
        }
        return false
    }

    /**
     * This must be called before doing anything else with the AnylineTireTreadSdk.
     *
     * It only needs to be called once during your application life-cycle.
     */
    @OptIn(InternalAPI::class)
    private fun initializeSdk(licenseKey: String, pluginVersion: String, result: Result) {
        try {
            if (activityPluginBinding == null) {
                return result.error(Constants.ERROR_CODE_PLUGIN_NOT_ATTACHED_TO_ACTIVITY, Constants.ERROR_MESSAGE_PLUGIN_NOT_ATTACHED_TO_ACTIVITY, null)
            }

            activityPluginBinding?.activity?.let { activity ->
                AnylineTireTreadSdk.init(
                    licenseKey = licenseKey,
                    context = activity,
                    customTag = "",
                    wrapperInfo = WrapperInfo.Flutter(pluginVersion)
                )
                result.success(true)
            } ?: result.error(Constants.ERROR_CODE_PLUGIN_NOT_ATTACHED_TO_ACTIVITY, Constants.ERROR_MESSAGE_PLUGIN_NOT_ATTACHED_TO_ACTIVITY, null)

        } catch (e: Exception) {
            val (code, message, details) = when (e) {
                is SdkLicenseKeyForbiddenException -> Triple(
                    Constants.ERROR_CODE_SDK_INITIALIZATION_FAILED,
                    Constants.ERROR_MESSAGE_SDK_INITIALIZATION_FAILED,
                    e.localizedMessage ?: Constants.ERROR_MESSAGE_LICENSE_KEY_FORBIDDEN
                )
                is SdkLicenseKeyInvalidException -> Triple(
                    Constants.ERROR_CODE_SDK_INITIALIZATION_FAILED,
                    Constants.ERROR_MESSAGE_SDK_INITIALIZATION_FAILED,
                    e.localizedMessage ?: Constants.ERROR_MESSAGE_INVALID_LICENSE_KEY
                )
                is NoConnectionException -> Triple(
                    Constants.ERROR_CODE_SDK_INITIALIZATION_FAILED,
                    Constants.ERROR_MESSAGE_SDK_INITIALIZATION_FAILED,
                    e.localizedMessage ?: Constants.ERROR_MESSAGE_NO_CONNECTION
                )
                else -> Triple(
                    Constants.ERROR_CODE_GENERIC_EXCEPTION,
                    e.message,
                    e.localizedMessage
                )
            }
            result.error(code, message, details)
        }
    }

    private fun scan(tireTreadConfigMap: Map<String, Any>, result: Result) {
        if (activityPluginBinding == null) {
            return result.error(Constants.ERROR_CODE_PLUGIN_NOT_ATTACHED_TO_ACTIVITY, Constants.ERROR_MESSAGE_PLUGIN_NOT_ATTACHED_TO_ACTIVITY, null)
        }

        try {
            pendingScanResult = result
            
            val intent = Intent(activityPluginBinding!!.activity, ScanTireTreadActivity::class.java).apply {
                putExtra(ScanTireTreadActivity.EXTRA_TIRE_TREAD_CONFIG, JSONObject(tireTreadConfigMap).toString())
            }
            
            activityPluginBinding!!.activity.startActivityForResult(intent, SCAN_REQUEST_CODE)
            
        } catch (e: Exception) {
            result.error(Constants.ERROR_CODE_GENERIC_EXCEPTION, e.message, e.localizedMessage)
        }
    }

    private fun getMeasurementResult(
        measurementUUID: String,
        result: Result
    ) {
        CoroutineScope(Dispatchers.IO).launch {
            AnylineTireTreadSdk.getTreadDepthReportResult(
                measurementUUID,
                onResponse = { response ->
                    when (response) {
                        is Response.Success -> {
                            result.success(response.data.encodeToString())
                        }
                        is Response.Error -> {
                            result.error(
                                response.errorCode ?: Constants.ERROR_CODE_GENERIC_EXCEPTION, 
                                response.errorMessage ?: Constants.ERROR_MESSAGE_UNKNOWN_ERROR,
                                null
                            )
                        }
                        is Response.Exception -> {
                            result.error(
                                Constants.ERROR_CODE_GENERIC_EXCEPTION,
                                response.exception.message,
                                response.exception.localizedMessage
                            )
                        }
                    }
                }
            )
        }
    }


    private fun getHeatMapResult(
        measurementUUID: String,
        result: Result
    ) {
        CoroutineScope(Dispatchers.IO).launch {
            AnylineTireTreadSdk.getHeatmap(
                measurementUUID,
                onResponse = { response ->
                    when (response) {
                        is Response.Success -> {
                            result.success(response.data.url)
                        }
                        is Response.Error -> {
                            result.error(
                                response.errorCode ?: Constants.ERROR_CODE_GENERIC_EXCEPTION, 
                                response.errorMessage ?: Constants.ERROR_MESSAGE_UNKNOWN_ERROR,
                                null
                            )
                        }
                        is Response.Exception -> {
                            result.error(
                                Constants.ERROR_CODE_GENERIC_EXCEPTION,
                                response.exception.message,
                                response.exception.localizedMessage
                            )
                        }
                    }
                }
            )
        }
    }

    private fun sendCommentFeedback(
        measurementUUID: String,
        comment: String,
        result: Result
    ) {
        CoroutineScope(Dispatchers.IO).launch {
            AnylineTireTreadSdk.sendCommentFeedback(uuid = measurementUUID, comment = comment) { response ->
                when (response) {
                    is Response.Success -> {
                        result.success(response.data.measurementUuid)
                    }

                    is Response.Error -> {
                        result.error(
                            Constants.ERROR_CODE_GENERIC_EXCEPTION,
                            response.errorMessage ?: Constants.ERROR_MESSAGE_UNKNOWN_ERROR,
                            response.errorMessage
                        )
                    }

                    is Response.Exception -> {
                        result.error(
                            Constants.ERROR_CODE_GENERIC_EXCEPTION,
                            response.exception.message,
                            response.exception.localizedMessage
                        )
                    }
                }
            }
        }
    }

    private fun sendTreadDepthResultFeedback(
        measurementUUID: String, treadResultRegions: List<TreadResultRegion>, result: Result
    ) {
        CoroutineScope(Dispatchers.IO).launch {
            AnylineTireTreadSdk.sendTreadDepthResultFeedback(resultUuid = measurementUUID, treadResultRegions = treadResultRegions) { response ->
                when (response) {
                    is Response.Success -> {
                        result.success(response.data.measurementUuid)
                    }

                    is Response.Error -> {
                        result.error(
                            Constants.ERROR_CODE_GENERIC_EXCEPTION,
                            response.errorMessage ?: Constants.ERROR_MESSAGE_UNKNOWN_ERROR,
                            response.errorMessage
                        )
                    }

                    is Response.Exception -> {
                        result.error(
                            Constants.ERROR_CODE_GENERIC_EXCEPTION,
                            response.exception.message,
                            response.exception.localizedMessage
                        )
                    }
                }
            }
        }
    }
}

