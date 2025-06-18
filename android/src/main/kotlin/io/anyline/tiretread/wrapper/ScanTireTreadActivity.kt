package io.anyline.tiretread.wrapper

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.View
import android.widget.Toast
import androidx.activity.OnBackPressedCallback
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.lifecycleScope
import io.anyline.tiretread.flutter.databinding.ActivityScanTireTreadBinding
import io.anyline.tiretread.sdk.scanner.DistanceStatus
import io.anyline.tiretread.sdk.scanner.MeasurementSystem
import io.anyline.tiretread.sdk.scanner.OnDistanceChanged
import io.anyline.tiretread.sdk.scanner.OnImageUploaded
import io.anyline.tiretread.sdk.scanner.OnScanStarted
import io.anyline.tiretread.sdk.scanner.OnScanStopped
import io.anyline.tiretread.sdk.scanner.ScanEvent
import io.anyline.tiretread.sdk.scanner.ScanSpeed
import io.anyline.tiretread.sdk.config.TireTreadConfig
import io.anyline.tiretread.sdk.config.HeatmapStyle
import io.anyline.tiretread.sdk.types.AdditionalContext
import io.anyline.tiretread.sdk.types.TirePosition
import io.anyline.tiretread.sdk.types.TireSide
import io.anyline.tiretread.sdk.scanner.TireTreadScanner
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

    private var customDataContent: String? = null

    private val TAG = ScanTireTreadActivity::class.qualifiedName

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        inflateLayout()
    }

    private fun inflateLayout() {
        binding = ActivityScanTireTreadBinding.inflate(layoutInflater)
        binding.root.also { rootView ->
            setContentView(rootView)
        }
        supportActionBar?.setDisplayHomeAsUpEnabled(true)

        observeMeasurementScanState()
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
                            if (intent.hasExtra(INTENT_EXTRA_IN_SCAN_TTD_ACTIVITY_PARAMETERS)) {
                                intent.getStringExtra(INTENT_EXTRA_IN_SCAN_TTD_ACTIVITY_PARAMETERS)?.let {
                                    ScanTireTreadActivityParameters.fromString(it)
                                } ?: ScanTireTreadActivityParameters()
                            } else {
                                ScanTireTreadActivityParameters()
                            }

                        customDataContent = activityParameters.customData

                        binding.tireTreadScanView.apply {
                            val scanConfig = activityParameters.tireTreadConfigJson
                            scanTireTreadViewModel.measurementResultData = null

                            this.init(
                                tireTreadConfig = scanConfig ?: "",
                                onScanAborted = ::onScanAborted,
                                onScanProcessCompleted = ::onScanProcessCompleted,
                                tireTreadScanViewCallback = ::handleEvent,
                                onError = { measurementUUID, exception ->
                                    onMeasurementResultDataStatusUpdate(MeasurementResultStatus.ExceptionCaught(exception.message))
                                    finishWithResult(RESULT_CANCELED, scanTireTreadViewModel.measurementResultData, exception.message)
                                }
                            )
                        }
                    }

                    else -> {
                    }
                }
            }
        }
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
        MeasurementResultStatus.ScanAborted.also { scanAbortedStatus ->
            scanTireTreadViewModel.measurementResultData = if (measurementUUID == null) {
                provideNewMeasurementResultData(measurementUUID)
            } else {
                scanTireTreadViewModel.measurementResultData
            }
            onMeasurementResultDataStatusUpdate(scanAbortedStatus)
            finishWithResult(RESULT_CANCELED, scanTireTreadViewModel.measurementResultData, scanAbortedStatus.statusDescription)
        }
    }

    /**
     * Handles the event when the scan process is completed.
     *
     * @param measurementUUID The unique identifier for the completed measurement.
     */
    private fun onScanProcessCompleted(measurementUUID: String) {
        onMeasurementResultDataStatusUpdate(MeasurementResultStatus.ScanProcessCompleted)
        finishWithResult(RESULT_OK, scanTireTreadViewModel.measurementResultData)
    }

    fun provideNewMeasurementResultData(measurementUUID: String?): MeasurementResultData {
        return MeasurementResultData(
            measurementUUID = measurementUUID
        )
    }

    /**
     * Handles various scan events and updates the measurement result data accordingly.
     *
     * @param event The scan event to handle.
     */
    private fun handleEvent(event: ScanEvent) {

        when (event) {
            is OnScanStarted -> {
                event.measurementUUID.let { measurementUUID ->
                    scanTireTreadViewModel.measurementResultData = provideNewMeasurementResultData(measurementUUID)
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

        scanTireTreadViewModel.measurementResultData?.let { measurementResultDataNonNull ->
            measurementResultDataNonNull.measurementResultStatus = measurementResultStatus

            scanTireTreadViewModel.measurementResultUpdateInterface?.onMeasurementResultDataStatusUpdate(
                measurementResultDataNonNull,
                measurementResultStatus,
                customDataContent
            )
        }
    }

    @Serializable
    data class ScanTireTreadActivityParameters @JvmOverloads constructor(
        val tireTreadConfigJson: String? = null,
        val customData: String? = null
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

        const val CANCEL_MESSAGE_ABORTED = "Aborted."
        const val CANCEL_MESSAGE_ABORTED_WHILE_SCANNING = "Aborted while scanning."

        private var measurementResultUpdateInterface: MeasurementResultUpdateInterface? = null

        @JvmStatic
        @JvmOverloads
        fun buildIntent(
            context: Context,
            scanTireTreadActivityParameters: ScanTireTreadActivityParameters,
            measurementResultUpdateInterface: MeasurementResultUpdateInterface? = null
        ): Intent {

            Companion.measurementResultUpdateInterface = measurementResultUpdateInterface

            val intent = Intent(context, ScanTireTreadActivity::class.java)
            intent.putExtra(INTENT_EXTRA_IN_SCAN_TTD_ACTIVITY_PARAMETERS, scanTireTreadActivityParameters.toString())
            intent.putExtra(INTENT_EXTRA_IN_UPDATE_INTERFACE, (measurementResultUpdateInterface != null))

            return intent
        }
    }
}
