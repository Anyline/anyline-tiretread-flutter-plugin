package io.anyline.tiretread.wrapper

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.ActivityInfo
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.activity.OnBackPressedCallback
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.updateLayoutParams
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.lifecycleScope
import io.anyline.tiretread.flutter.AnylineTireTreadPlugin
import io.anyline.tiretread.flutter.databinding.ActivityScanTireTreadBinding
import io.anyline.tiretread.sdk.scanner.DistanceStatus
import io.anyline.tiretread.sdk.scanner.MeasurementSystem
import io.anyline.tiretread.sdk.scanner.OnDistanceChanged
import io.anyline.tiretread.sdk.scanner.OnImageUploaded
import io.anyline.tiretread.sdk.scanner.OnScanStarted
import io.anyline.tiretread.sdk.scanner.OnScanStopped
import io.anyline.tiretread.sdk.scanner.ScanEvent
import io.anyline.tiretread.sdk.scanner.TireTreadScanViewConfig
import io.anyline.tiretread.sdk.scanner.TireTreadScanner
import io.anyline.tiretread.sdk.scanner.ScanSpeed
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.serialization.Serializable
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

class ScanTireTreadActivity : AppCompatActivity() {

    private lateinit var binding: ActivityScanTireTreadBinding
    private val scanTireTreadViewModel: ScanTireTreadViewModel by lazy {
        ViewModelProvider(this)[ScanTireTreadViewModel::class.java]
    }

    private val cameraPermissionLauncher = registerForActivityResult(ActivityResultContracts.RequestPermission()) { isGranted: Boolean ->
        if (isGranted) {
            scanTireTreadViewModel.cameraPermissionStateLiveData.postValue(ScanTireTreadViewModel.CameraPermissionState.Granted)
        } else {
            scanTireTreadViewModel.cameraPermissionStateLiveData.postValue(ScanTireTreadViewModel.CameraPermissionState.Denied)
        }
    }

    private var useDefaultUi = false
    var measurementSystem = MeasurementSystem.Metric

    private var customDataContent: String? = null
    private var scopeStrategy: ScopeStrategy = ScopeStrategy.WaitForProcessing
    private var measurementResultData: MeasurementResultData? = null

    private var doubleBackToExitPressedOnce = false
    private val TAG = ScanTireTreadActivity::class.qualifiedName


    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE)
        super.onCreate(savedInstanceState)

        onBackPressedDispatcher.addCallback(this, object : OnBackPressedCallback(true) {
            override fun handleOnBackPressed() {
                scanTireTreadViewModel.measurementScanStateLiveData.value?.let {
                    val confirmationToAbortRequired = it.confirmationToAbortRequired()
                    when (confirmationToAbortRequired) {
                        is ScanTireTreadViewModel.MeasurementScanState.ConfirmationToAbortRequired.Yes -> {
                            if (doubleBackToExitPressedOnce) {
                                finishWithResult(RESULT_CANCELED, null, confirmationToAbortRequired.abortMessage)
                                return@let
                            }
                            doubleBackToExitPressedOnce = true
                            Toast.makeText(
                                this@ScanTireTreadActivity,
                                "${confirmationToAbortRequired.confirmationMessage} Press again to abort.",
                                Toast.LENGTH_SHORT
                            ).show()
                            Handler(Looper.getMainLooper()).postDelayed(
                                { doubleBackToExitPressedOnce = false }, 2000
                            )
                        }

                        is ScanTireTreadViewModel.MeasurementScanState.ConfirmationToAbortRequired.No -> {
                            finishWithResult(RESULT_CANCELED, null, CANCEL_MESSAGE_ABORTED)
                        }
                    }
                } ?: run { finish() }
            }
        })

        scanTireTreadViewModel.cameraPermissionStateLiveData.observe(this) { cameraPermissionState ->
            when (cameraPermissionState) {
                ScanTireTreadViewModel.CameraPermissionState.NotRequested -> {
                    cameraPermissionLauncher.launch(Manifest.permission.CAMERA)
                }

                ScanTireTreadViewModel.CameraPermissionState.Granted -> {
                    inflateLayout()
                }

                ScanTireTreadViewModel.CameraPermissionState.Denied -> {
                    finishWithResult(RESULT_CANCELED, null, CANCEL_MESSAGE_CAMERA_PERMISSION_DENIED)
                }
            }
        }
    }

    private fun inflateLayout() {
        binding = ActivityScanTireTreadBinding.inflate(layoutInflater)
        binding.root.also { rootView ->
            setContentView(rootView)
            applyInsetsToView(rootView)
        }

        supportActionBar?.setDisplayHomeAsUpEnabled(true)

        observeMeasurementScanState()
    }

    private fun applyInsetsToView(view: View) {
        ViewCompat.setOnApplyWindowInsetsListener(view) { v, windowInsets ->
            val insets = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars())
            v.updateLayoutParams<ViewGroup.MarginLayoutParams> {
                topMargin = insets.top
                leftMargin = insets.left
                bottomMargin = insets.bottom
                rightMargin = insets.right
            }
            WindowInsetsCompat.CONSUMED
        }
    }

    private fun observeMeasurementScanState() {
        scanTireTreadViewModel.measurementScanStateLiveData.observe(this) { measurementScanState ->
            with(binding) {
                when (measurementScanState.measurementResultStatus) {
                    null -> {
                        if (intent.getBooleanExtra(INTENT_EXTRA_IN_UPDATE_INTERFACE, false)) {
                            measurementResultUpdateInterface?.let {
                                scanTireTreadViewModel.measurementResultUpdateInterface = it
                            }
                            //once set listener to viewModel, release static measurementResultUpdateInterface reference
                            measurementResultUpdateInterface = null
                        }

                        val activityParameters: ScanTireTreadActivityParameters =
                            intent.getStringExtra(INTENT_EXTRA_IN_SCAN_TTD_ACTIVITY_PARAMETERS)?.let {
                                ScanTireTreadActivityParameters.fromString(it)
                            } ?: run { ScanTireTreadActivityParameters() }

                        customDataContent = activityParameters.customData
                        scopeStrategy = activityParameters.scopeStrategy

                        var optionalTireWidth: Int? = null
                        binding.tireTreadScanView.apply {
                            val scanConfig = activityParameters.configContent?.let {
                                Json.decodeFromString<TireTreadScanViewConfig>(it)
                            } ?: run { TireTreadScanViewConfig() }

                            activityParameters.scanSpeed?.let {
                                scanConfig.scanSpeed = it
                            }

                            activityParameters.measurementSystem?.let {
                                scanConfig.measurementSystem = it
                            }

                            activityParameters.tireWidth?.let {
                                optionalTireWidth = it
                            }

                            activityParameters.showGuidance?.let {
                                scanConfig.defaultUiConfig.countdownConfig.visible = it
                                scanConfig.defaultUiConfig.scanDirectionConfig.visible = it
                                scanConfig.defaultUiConfig.tireOverlayConfig.visible = it
                            }
                            useDefaultUi = scanConfig.useDefaultUi

                            measurementSystem = scanConfig.measurementSystem

                            measurementResultData = null

                            this.init(
                                tireTreadScanViewConfig = scanConfig,
                                tireWidth = optionalTireWidth,
                                onScanAborted = ::onScanAborted,
                                onScanProcessCompleted = ::onScanProcessCompleted,
                                tireTreadScanViewCallback = ::handleEvent
                            ) { measurementUUID, exception ->
                                onMeasurementResultDataStatusUpdate(MeasurementResultStatus.ExceptionCaught(exception.message))
                                finishWithResult(RESULT_CANCELED, measurementResultData, exception.message)
                            }
                        }

                        processingLayout.visibility = View.GONE
                        tireTreadScanView.visibility = View.VISIBLE
                    }

                    is MeasurementResultStatus.ImageUploaded -> {
                        if (!useDefaultUi) {
                            processingProgressBar.isIndeterminate = false
                            processingProgressBar.max = measurementScanState.measurementResultStatus.total
                            processingProgressBar.progress = measurementScanState.measurementResultStatus.uploaded
                            processingLayout.visibility = View.VISIBLE
                            tireTreadScanView.visibility = View.GONE
                            processingTextView.text = measurementScanState.measurementResultStatus.statusDescription
                        }
                    }

                    is MeasurementResultStatus.ScanProcessCompleted,
                    is MeasurementResultStatus.TreadDepthResultQueried -> {
                        processingProgressBar.isIndeterminate = true
                        processingLayout.visibility = View.VISIBLE
                        tireTreadScanView.visibility = View.GONE
                        processingTextView.text = measurementScanState.measurementResultStatus.statusDescription
                    }

                    else -> {
                        processingLayout.visibility = View.GONE
                        tireTreadScanView.visibility = View.VISIBLE
                        processingTextView.text = ""
                    }
                }
            }
        }
    }

    override fun onStop() {
        if (TireTreadScanner.isInitialized) {
            if (scanTireTreadViewModel.measurementScanStateLiveData.value?.stopScanningOnFinishRequired() == true) {
                TireTreadScanner.instance.stopScanning()
            }
        }
        super.onStop()
    }

    private fun finishWithResult(
        result: Int,
        measurementResultData: MeasurementResultData?,
        cancelMessage: String? = null
    ) {

        val resultIntent = Intent()
        resultIntent.putExtra(INTENT_EXTRA_OUT_MEASUREMENT_RESULT_DATA, measurementResultData?.toString())
        resultIntent.putExtra(INTENT_EXTRA_OUT_CUSTOM_DATA, customDataContent)
        resultIntent.putExtra(INTENT_EXTRA_OUT_CANCEL_MESSAGE, cancelMessage)
        setResult(result, resultIntent)
        finish()
    }

    /**
     * Handles the event when a scan is aborted.
     *
     * @param measurementUUID The unique identifier for the measurement that was aborted.
     */
    private fun onScanAborted(measurementUUID: String?) {
        Log.d(TAG, "onScanAborted: $measurementUUID")
        MeasurementResultStatus.ScanAborted.also { scanAbortedStatus ->
            onMeasurementResultDataStatusUpdate(scanAbortedStatus)
            finishWithResult(RESULT_CANCELED, measurementResultData, scanAbortedStatus.statusDescription)
        }
    }

    /**
     * Handles the event when the scan process is completed.
     *
     * @param measurementUUID The unique identifier for the completed measurement.
     */
    private fun onScanProcessCompleted(measurementUUID: String) {
        Log.d(TAG, "onScanProcessCompleted: $measurementUUID")
        onMeasurementResultDataStatusUpdate(MeasurementResultStatus.ScanProcessCompleted)
        when (scopeStrategy) {
            ScopeStrategy.WaitForProcessing -> {
                //fetch Tread Depth Report and wait for Result
                onMeasurementResultDataStatusUpdate(
                    MeasurementResultStatus.TreadDepthResultQueried(TreadDepthResultStatus.NotYetAvailable)
                )
                lifecycleScope.launch(Dispatchers.IO) {
                    measurementResultData?.getTreadDepthReportResult { treadDepthResultStatus ->
                        onMeasurementResultDataStatusUpdate(
                            MeasurementResultStatus.TreadDepthResultQueried(
                                treadDepthResultStatus
                            )
                        )
                        finishWithResult(RESULT_OK, measurementResultData)
                    }
                }
            }

            ScopeStrategy.CaptureAndUploadOnly -> {
                //Tread Depth Report Result will be fetch later/somewhere else
                finishWithResult(RESULT_OK, measurementResultData)
            }
        }
    }

    /**
     * Handles various scan events and updates the measurement result data accordingly.
     *
     * @param event The scan event to handle.
     */
    private fun handleEvent(event: ScanEvent) {

        fun provideNewMeasurementResultData(measurementUUID: String): MeasurementResultData {
            return MeasurementResultData(
                measurementUUID = measurementUUID,
                measurementSystem = measurementSystem
            )
        }

        when (event) {
            is OnScanStarted -> {
                event.measurementUUID.let { measurementUUID ->
                    measurementResultData = provideNewMeasurementResultData(measurementUUID)
                    onMeasurementResultDataStatusUpdate(MeasurementResultStatus.ScanStarted)
                }
            }

            is OnScanStopped -> {
                onMeasurementResultDataStatusUpdate(MeasurementResultStatus.ScanStopped)
            }

            is OnImageUploaded -> {
                onMeasurementResultDataStatusUpdate(
                    MeasurementResultStatus.ImageUploaded(
                        event.uploaded,
                        event.total
                    )
                )
            }

            is OnDistanceChanged -> {
                if (event.newStatus == DistanceStatus.OK) {
                    TireTreadScanner.instance.apply {
                        if (!isScanning && !useDefaultUi) {
                            startScanning()
                        }
                    }
                }
            }

            else -> {
                // handle previously unhandled events
            }
        }
    }

    private fun onMeasurementResultDataStatusUpdate(measurementResultStatus: MeasurementResultStatus) {
        scanTireTreadViewModel.measurementScanStateLiveData.postValue(
            ScanTireTreadViewModel.MeasurementScanState(
                TireTreadScanner.instance.isScanning, measurementResultStatus
            )
        )
        measurementResultData?.let { measurementResultDataNonNull ->
            measurementResultDataNonNull.measurementResultStatus = measurementResultStatus

            scanTireTreadViewModel.measurementResultUpdateInterface?.onMeasurementResultDataStatusUpdate(
                measurementResultDataNonNull,
                measurementResultStatus,
                customDataContent
            )
        }
    }

    enum class ScopeStrategy {
        @JvmStatic
        WaitForProcessing,

        @JvmStatic
        CaptureAndUploadOnly
    }

    @Serializable
    data class ScanTireTreadActivityParameters @JvmOverloads constructor(
        val configContent: String? = null,
        val scanSpeed: ScanSpeed? = null,
        val measurementSystem: MeasurementSystem? = null,
        val tireWidth: Int? = null,
        val showGuidance: Boolean? = null,
        val customData: String? = null,
        val scopeStrategy: ScopeStrategy = ScopeStrategy.WaitForProcessing
    ) {
        override fun toString() = Json.encodeToString(this)

        companion object {
            @JvmStatic
            fun fromString(value: String) = Json.decodeFromString<ScanTireTreadActivityParameters>(value)
        }
    }

    companion object {
        private const val INTENT_EXTRA_IN_SCAN_TTD_ACTIVITY_PARAMETERS = "INTENT_EXTRA_IN_SCAN_TTD_ACTIVITY_PARAMETERS"
        private const val INTENT_EXTRA_IN_UPDATE_INTERFACE = "INTENT_EXTRA_IN_UPDATE_INTERFACE"

        const val INTENT_EXTRA_OUT_MEASUREMENT_RESULT_DATA = "INTENT_EXTRA_OUT_MEASUREMENT_RESULT_DATA"
        const val INTENT_EXTRA_OUT_CUSTOM_DATA = "INTENT_EXTRA_OUT_CUSTOM_DATA"
        const val INTENT_EXTRA_OUT_CANCEL_MESSAGE = "INTENT_EXTRA_OUT_CANCEL_MESSAGE"

        const val CANCEL_MESSAGE_CAMERA_PERMISSION_DENIED = "Camera permission denied."
        const val CANCEL_MESSAGE_ABORTED = "Aborted."
        const val CANCEL_MESSAGE_ABORTED_WHILE_SCANNING = "Aborted while scanning."
        const val CANCEL_MESSAGE_ABORTED_WHILE_WAITING_FOR_RESULT = "Aborted while waiting for result."

        private var measurementResultUpdateInterface: MeasurementResultUpdateInterface? = null

        @JvmStatic
        @JvmOverloads
        fun buildIntent(
            context: Context,
            scanTireTreadActivityParameters: ScanTireTreadActivityParameters,
            measurementResultUpdateInterface: MeasurementResultUpdateInterface? = null
        )
                : Intent {

            Companion.measurementResultUpdateInterface = measurementResultUpdateInterface

            val intent = Intent(context, ScanTireTreadActivity::class.java)
            intent.putExtra(INTENT_EXTRA_IN_SCAN_TTD_ACTIVITY_PARAMETERS, scanTireTreadActivityParameters.toString())
            intent.putExtra(INTENT_EXTRA_IN_UPDATE_INTERFACE, (measurementResultUpdateInterface != null))

            return intent
        }
    }
}
