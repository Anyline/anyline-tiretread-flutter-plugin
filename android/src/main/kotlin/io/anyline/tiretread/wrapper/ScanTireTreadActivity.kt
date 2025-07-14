package io.anyline.tiretread.flutter

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import io.anyline.tiretread.sdk.scanner.ScanEvent
import io.anyline.tiretread.sdk.scanner.OnScanStarted
import io.anyline.tiretread.sdk.scanner.TireTreadScanView

class ScanTireTreadActivity : AppCompatActivity() {
    
    private var currentScanView: TireTreadScanView? = null
    
    companion object {
        // Config content extra
        const val EXTRA_TIRE_TREAD_CONFIG = "tire_tread_config"
        
        // Result extras
        const val RESULT_MEASUREMENT_UUID = "measurement_uuid"
        const val RESULT_ERROR_MESSAGE = "error_message"
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        val tireTreadConfigJson = intent.getStringExtra(EXTRA_TIRE_TREAD_CONFIG) ?: run {
                finishWithError("No tire tread configuration provided")
                return
            }
        
        try {
            setupScanView(tireTreadConfigJson)
        } catch (e: Exception) {
            finishWithError("Failed to setup scan view: ${e.message}")
        }
    }
    
    private fun setupScanView(tireTreadConfigJson: String) {
        currentScanView = TireTreadScanView(this).apply {
            init(
                tireTreadConfig = tireTreadConfigJson,
                onScanAborted = ::onScanAborted,
                onScanProcessCompleted = ::onScanProcessCompleted,
                tireTreadScanViewCallback = ::handleScanEvent,
                onError = ::onScanError
            )
        }
        
        // Set the scan view as the content view
        setContentView(currentScanView)
    }
    
    /**
     * Handles the event when a scan is aborted.
     *
     * @param measurementUUID The unique identifier for the measurement that was aborted.
     */
    private fun onScanAborted(measurementUUID: String?) {
        TTEventHandler.shared.sendEvent(type = "ScanAborted", uuid = measurementUUID)
        finishWithResult(measurementUUID, "ABORTED")
    }
    
    /**
     * Handles the event when the scan process is completed.
     *
     * @param measurementUUID The unique identifier for the completed measurement.
     */
    private fun onScanProcessCompleted(measurementUUID: String) {
        TTEventHandler.shared.sendEvent(type = "ScanProcessCompleted", uuid = measurementUUID)
        finishWithResult(measurementUUID, "COMPLETED")
    }
    
    /**
     * Handles the event when an error occurs during the scan process.
     *
     * @param measurementUUID The unique identifier for the measurement that encountered an error.
     * @param exception The exception that occurred during scanning.
     */
    private fun onScanError(measurementUUID: String?, exception: Exception) {
        TTEventHandler.shared.sendEvent(type = "ScanFailed", uuid = measurementUUID, error = exception.message)
        finishWithError("Scan failed: ${exception.message}")
    }
    
    /**
     * Handles various scan events and sends appropriate events to Flutter.
     *
     * @param event The scan event to handle.
     */
    private fun handleScanEvent(event: ScanEvent) {
        if (event is OnScanStarted) {
            TTEventHandler.shared.sendEvent(type = "ScanStarted", uuid = event.measurementUUID)
        }
        // Handle other scan events if needed in the future
    }
    
    private fun finishWithResult(measurementUUID: String?, status: String) {
        val resultIntent = Intent().apply {
            putExtra(RESULT_MEASUREMENT_UUID, measurementUUID ?: "")
            putExtra("status", status)
        }
        setResult(Activity.RESULT_OK, resultIntent)
        finish()
    }
    
    private fun finishWithError(errorMessage: String) {
        val resultIntent = Intent().apply {
            putExtra(RESULT_ERROR_MESSAGE, errorMessage)
        }
        setResult(Activity.RESULT_CANCELED, resultIntent)
        finish()
    }
    
    override fun onDestroy() {
        super.onDestroy()
        currentScanView = null
    }
}