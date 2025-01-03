package io.anyline.tiretread.wrapper

fun interface MeasurementResultUpdateInterface {
    fun onMeasurementResultDataStatusUpdate(
        measurementResultData: MeasurementResultData,
        measurementResultStatus: MeasurementResultStatus,
        customData: String?)
}