package io.anyline.tiretread.wrapper

import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import io.anyline.tiretread.wrapper.ScanTireTreadActivity.Companion.CANCEL_MESSAGE_ABORTED_WHILE_SCANNING
import io.anyline.tiretread.wrapper.ScanTireTreadActivity.Companion.CANCEL_MESSAGE_ABORTED_WHILE_WAITING_FOR_RESULT

class ScanTireTreadViewModel: ViewModel() {

    data class MeasurementScanState(
        val isScanning: Boolean,
        val measurementResultStatus: MeasurementResultStatus?) {

        sealed class ConfirmationToAbortRequired {
            data object No: ConfirmationToAbortRequired()
            data class Yes(
                val confirmationMessage: String,
                val abortMessage: String): ConfirmationToAbortRequired()
        }

        fun confirmationToAbortRequired(): ConfirmationToAbortRequired {
            if (isScanning) {
                return ConfirmationToAbortRequired.Yes(
                    MeasurementResultStatus.ScanStarted.statusDescription,
                    CANCEL_MESSAGE_ABORTED_WHILE_SCANNING
                )
            }
            if (measurementResultStatus is MeasurementResultStatus.TreadDepthResultQueried) {
                if (measurementResultStatus.treadDepthResultStatus == TreadDepthResultStatus.NotYetAvailable) {
                    return ConfirmationToAbortRequired.Yes(
                        TreadDepthResultStatus.NotYetAvailable.statusDescription,
                        CANCEL_MESSAGE_ABORTED_WHILE_WAITING_FOR_RESULT
                    )
                }
            }
            return ConfirmationToAbortRequired.No
        }

        fun stopScanningOnFinishRequired(): Boolean {
            return isScanning || measurementResultStatus == null
        }
    }

    val measurementScanStateLiveData: MutableLiveData<MeasurementScanState> =
        MutableLiveData(MeasurementScanState(false, null))

    var measurementResultUpdateInterface: MeasurementResultUpdateInterface? = null

    enum class CameraPermissionState {
        NotRequested,
        Granted,
        Denied
    }
    val cameraPermissionStateLiveData: MutableLiveData<CameraPermissionState> =
        MutableLiveData(CameraPermissionState.NotRequested)

}