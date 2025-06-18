package io.anyline.tiretread.wrapper

import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel

class ScanTireTreadViewModel: ViewModel() {

    data class MeasurementScanState(
        val isScanning: Boolean,
        val measurementResultStatus: MeasurementResultStatus?) {
    }

    val measurementScanStateLiveData: MutableLiveData<MeasurementScanState> =
        MutableLiveData(MeasurementScanState(false, null))

    var measurementResultData: MeasurementResultData? = null

    var measurementResultUpdateInterface: MeasurementResultUpdateInterface? = null
}