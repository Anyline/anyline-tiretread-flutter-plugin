package io.anyline.tiretread.flutter

import android.content.Intent
import android.util.Log

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
import io.anyline.tiretread.wrapper.MeasurementResultData
import io.anyline.tiretread.wrapper.MeasurementResultDetails
import io.anyline.tiretread.wrapper.MeasurementResultStatus
import io.anyline.tiretread.wrapper.ScanTireTreadActivity
import io.anyline.tiretread.wrapper.TreadDepthResultStatus
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

/** AnylineTireTreadPlugin */
class AnylineTireTreadPlugin : FlutterPlugin, MethodCallHandler, ActivityAware,
    EventChannel.StreamHandler,
    PluginRegistry.ActivityResultListener {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel

    private var activityPluginBinding: ActivityPluginBinding? = null
    private var eventSink: EventChannel.EventSink? = null

    private val TAG = AnylineTireTreadPlugin::class.qualifiedName

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "anyline_tire_tread_plugin")
        channel.setMethodCallHandler(this)

        eventChannel =
            EventChannel(flutterPluginBinding.binaryMessenger, "anyline_tire_tread_plugin/events")
        eventChannel.setStreamHandler(this)
    }

    @OptIn(InternalAPI::class)
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            Constants.METHOD_INITIALIZE -> {
                val licenseKey: String =
                    call.argument<String?>(Constants.EXTRA_LICENSE_KEY).toString()
                val pluginVersion: String =
                    call.argument<String?>(Constants.EXTRA_PLUGIN_VERSION).toString()
                setup(licenseKey, pluginVersion, result)
            }

            Constants.METHOD_GET_SDK_VERSION -> {
                result.success(AnylineTireTreadSdk.sdkVersion)
            }

            Constants.METHOD_SCAN -> {
                (call.arguments as Map<String, Any>).also { scanArguments ->
                    scan(
                        configFileContent = scanArguments["configFileContent"]?.toString(),
                        scanSpeed = scanArguments["scanSpeed"]?.let { ScanSpeed.valueOf(it.toString()) },
                        measurementSystem = scanArguments["measurementSystem"]?.let {
                            MeasurementSystem.valueOf(
                                it.toString()
                            )
                        },
                        tireWidth = (scanArguments["tireWidth"] as Int?),
                        showGuidance = (scanArguments["showGuidance"] as Boolean?),
                        result
                    )
                }
            }

            Constants.METHOD_GET_RESULT -> {
                val measurementUUID: String =
                    call.argument<String?>(Constants.EXTRA_MEASUREMENT_UUID).toString()
                val measurementResultData = MeasurementResultData(
                    measurementUUID = measurementUUID,
                    measurementResultStatus = MeasurementResultStatus.ScanProcessCompleted
                )
                getMeasurementResult(measurementResultData, result)
            }

            Constants.METHOD_GET_HEATMAP -> {
                val measurementUUID: String =
                    call.argument<String?>(Constants.EXTRA_MEASUREMENT_UUID).toString()
                val measurementResultData = MeasurementResultData(
                    measurementUUID = measurementUUID,
                    measurementResultStatus = MeasurementResultStatus.ScanProcessCompleted
                )
                val measurementResultDetails = MeasurementResultDetails(measurementResultData)
                getHeatMapResult(measurementResultDetails, result)
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
                    result.error("INVALID_ARGUMENT", "Experimental flags are null", null)
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
        eventSink = null
    }

    /// EventChannel.StreamHandler

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    /// ActivityAware

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityPluginBinding = binding
        binding.addActivityResultListener(this)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        return true
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

    /**
     * This must be called before doing anything else with the AnylineTireTreadSdk.
     *
     * It only needs to be called once during your application life-cycle.
     */
    @OptIn(InternalAPI::class)
    private fun setup(licenseKey: String, pluginVersion: String, result: Result) {
        try {
            if (activityPluginBinding == null) {
                return PluginError.PluginNotAttachedToActivityError.throwToResult(result)
            }

            activityPluginBinding?.activity?.let {
                AnylineTireTreadSdk.init(
                    licenseKey = licenseKey,
                    context = it,
                    customTag = "",
                    wrapperInfo = WrapperInfo.Flutter(pluginVersion)
                )
                return result.success(true)
            }


        } catch (e: SdkLicenseKeyForbiddenException) {
            return PluginError.SdkInitializationFailedError.throwToResult(
                result,
                e.localizedMessage
            )
        } catch (e: NoConnectionException) {
            return PluginError.SdkInitializationFailedError.throwToResult(
                result,
                e.localizedMessage
            )
        } catch (e: SdkLicenseKeyInvalidException) {
            return PluginError.SdkInitializationFailedError.throwToResult(
                result,
                e.localizedMessage
            )
        } catch (e: Exception) {
            return PluginError.GenericExceptionError(e.message)
                .throwToResult(result, e.localizedMessage)
        }
    }

    private fun scan(
        configFileContent: String? = null,
        scanSpeed: ScanSpeed? = null,
        measurementSystem: MeasurementSystem? = null,
        tireWidth: Int? = null,
        showGuidance: Boolean? = null,
        result: Result
    ) {
        if (activityPluginBinding == null) {
            return PluginError.PluginNotAttachedToActivityError.throwToResult(result)
        }

        ScanTireTreadActivity.buildIntent(
            activityPluginBinding!!.activity,
            ScanTireTreadActivity.ScanTireTreadActivityParameters(
                configContent = configFileContent,
                scanSpeed = scanSpeed,
                measurementSystem = measurementSystem,
                tireWidth = tireWidth,
                showGuidance = showGuidance,
                scopeStrategy = ScanTireTreadActivity.ScopeStrategy.CaptureAndUploadOnly
            ),
            measurementResultUpdateInterface = { measurementResultData: MeasurementResultData,
                                                 measurementResultStatus: MeasurementResultStatus, _ ->
                if (eventSink == null) {
                    return@buildIntent
                }

                when (measurementResultStatus) {
                    is MeasurementResultStatus.ScanAborted,
                    is MeasurementResultStatus.ScanProcessCompleted,
                    is MeasurementResultStatus.ExceptionCaught -> {
                        eventSink!!.success(measurementResultData.toString())
                    }

                    is MeasurementResultStatus.ScanStarted,
                    is MeasurementResultStatus.ScanStopped,
                    is MeasurementResultStatus.ImageUploaded,
                    is MeasurementResultStatus.TreadDepthResultQueried -> {
                        //these status are not currently being delivered to plugin
                    }

                }
            }).also { intent ->
            intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
            activityPluginBinding!!.activity.startActivity(intent)
        }
        return result.success(null)
    }

    private fun getMeasurementResult(
        measurementResultData: MeasurementResultData,
        result: Result
    ) {
        CoroutineScope(Dispatchers.IO).launch {
            measurementResultData.getTreadDepthReportResult { onStatusResult ->
                when (onStatusResult) {
                    TreadDepthResultStatus.NotYetAvailable -> {}
                    is TreadDepthResultStatus.Succeed -> {
                        result.success(onStatusResult.treadDepthResult.encodeToString())
                    }

                    is TreadDepthResultStatus.Failed -> {
                        PluginError.GetMeasurementResultError(onStatusResult.errorCode ?: "", onStatusResult.reason).throwToResult(
                            result,
                            mutableMapOf(
                                "code" to onStatusResult.errorCode,
                                "message" to onStatusResult.reason
                            ),
                        )
                    }
                }
            }
        }
    }


    private fun getHeatMapResult(
        measurementResultDetails: MeasurementResultDetails,
        result: Result
    ) {
        CoroutineScope(Dispatchers.IO).launch {
            measurementResultDetails.getHeatMap()


            measurementResultDetails.heatMapResultValue.collect { heatMapState ->
                when (heatMapState) {
                    is MeasurementResultDetails.HeatMapState.Failed -> {
                        PluginError.GetHeatMapResultError(heatMapState.code, heatMapState.message).throwToResult(
                            result,
                            mutableMapOf(
                                "code" to heatMapState.code,
                                "message" to heatMapState.message
                            )

                        )
                    }

                    is MeasurementResultDetails.HeatMapState.Ready -> {
                        result.success(heatMapState.heatmap.url)
                    }

                    is MeasurementResultDetails.HeatMapState.DownloadingHeatMap,
                    is MeasurementResultDetails.HeatMapState.GettingHeatMapUrl,
                    is MeasurementResultDetails.HeatMapState.HeatMapUrlReady,
                    is MeasurementResultDetails.HeatMapState.Unknown -> {
                        Log.d(TAG, "getHeatMapResult: $heatMapState")
                    }
                }
            }
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
                        PluginError.GenericExceptionError(response.errorMessage)
                            .throwToResult(result, response.errorMessage)
                    }

                    is Response.Exception -> {
                        PluginError.GenericExceptionError(response.exception.message)
                            .throwToResult(result, response.exception.localizedMessage)
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
                        PluginError.GenericExceptionError(response.errorMessage)
                            .throwToResult(result, response.errorMessage)
                    }

                    is Response.Exception -> {
                        PluginError.GenericExceptionError(response.exception.message)
                            .throwToResult(result, response.exception.localizedMessage)
                    }
                }
            }
        }
    }
}


sealed class PluginError(private val errorCode: String = "", private val errorMessage: String?) {
    data object PluginNotAttachedToActivityError :
        PluginError(Constants.ERROR_CODE_PLUGIN_NOT_ATTACHED_TO_ACTIVITY, "Plugin is not attached to main activity")

    data object SdkInitializationFailedError :
        PluginError(Constants.ERROR_CODE_SDK_INITIALIZATION_FAILED, "Tire Tread SDK could not be initialized")

    data class GetMeasurementResultError(val code: String, val message: String?) :
        PluginError(code, message)

    data class GetHeatMapResultError(val code: String, val message: String?) :
        PluginError(code, message)

    data class GenericExceptionError(private val exceptionMessage: String?) :
        PluginError(Constants.ERROR_CODE_GENERIC_EXCEPTION, exceptionMessage)

    fun throwToResult(result: Result, details: Any? = null) {
        result.error(errorCode, errorMessage, details)
    }
}

