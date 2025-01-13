package io.anyline.tiretread.flutter

import android.content.Intent
import android.graphics.BitmapFactory
import android.net.Uri
import android.util.Log
import android.view.View

import io.anyline.tiretread.sdk.AnylineTireTreadSdk
import io.anyline.tiretread.sdk.SdkInitializeFailedException
import io.anyline.tiretread.sdk.init
import io.anyline.tiretread.sdk.scanner.MeasurementSystem
import io.anyline.tiretread.sdk.scanner.ScanSpeed
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

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            Constants.METHOD_INITIALIZE -> {
                val licenseKey: String =
                    call.argument<String?>(Constants.EXTRA_LICENSE_KEY).toString()
                setup(licenseKey, result)
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
                    measurementResultStatus = MeasurementResultStatus.UploadCompleted
                )
                getMeasurementResult(measurementResultData, result)
            }

            Constants.METHOD_GET_HEATMAP -> {
                val measurementUUID: String =
                    call.argument<String?>(Constants.EXTRA_MEASUREMENT_UUID).toString()
                val measurementResultData = MeasurementResultData(
                    measurementUUID = measurementUUID,
                    measurementResultStatus = MeasurementResultStatus.UploadCompleted
                )
                val measurementResultDetails = MeasurementResultDetails(measurementResultData)
                getHeatMapResult(measurementResultDetails, result)
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
    private fun setup(licenseKey: String, result: Result) {
        try {
            if (activityPluginBinding == null) {
                return PluginError.PluginNotAttachedToActivityError.throwToResult(result)
            }

            AnylineTireTreadSdk.init(licenseKey, activityPluginBinding!!.activity)
            return result.success(true)

        } catch (e: SdkInitializeFailedException) {
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
                    is MeasurementResultStatus.UploadAborted,
                    is MeasurementResultStatus.UploadFailed,
                    is MeasurementResultStatus.UploadCompleted -> {
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
                        PluginError.GetMeasurementResultError.throwToResult(
                            result,
                            onStatusResult.reason
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
                        PluginError.GetHeatMapResultError.throwToResult(
                            result,
                            heatMapState.message
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


    sealed class PluginError(internal val message: String?) {
        data object PluginNotAttachedToActivityError :
            PluginError("Plugin is not attached to main activity")

        data object SdkInitializationFailedError :
            PluginError("Tire Tread SDK could not be initialized")

        data object MeasurementScanAbortedError :
            PluginError("Scan Aborted")

        data object MeasurementUploadAbortedError :
            PluginError("Upload Aborted")

        data object MeasurementError :
            PluginError("Measurement Error")

        data object GetMeasurementResultError :
            PluginError("GetMeasurementResult Error")

        data object GetHeatMapResultError :
            PluginError("GetHeatMapResultError Error")

        data class GenericExceptionError(private val exceptionMessage: String?) :
            PluginError(exceptionMessage)

        fun throwToResult(result: Result, details: Any? = null) {
            result.error(this::class.simpleName!!, message, details)
        }
    }

}
