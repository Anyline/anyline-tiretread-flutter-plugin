package io.anyline.tiretread.wrapper

import io.anyline.tiretread.sdk.AnylineTireTreadSdk
import io.anyline.tiretread.sdk.Response
import io.anyline.tiretread.sdk.getTreadDepthReportResult
import io.anyline.tiretread.sdk.scanner.MeasurementSystem
import io.anyline.tiretread.sdk.types.TreadDepthResult
import kotlinx.serialization.Serializable
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

@Serializable
sealed class MeasurementResultStatus(val statusDescription: String) {
    @Serializable
    data object ScanStarted
        : MeasurementResultStatus("Scan Started...")
    @Serializable
    data object ScanStopped
        : MeasurementResultStatus("Scan Stopped, waiting for images to be uploaded...")
    @Serializable
    data object ScanAborted
        : MeasurementResultStatus("Scan Aborted.")
    @Serializable
    data class ImageUploaded(val uploaded: Int, val total: Int)
        : MeasurementResultStatus(when(uploaded < total) {
        true -> "Uploaded Image $uploaded of $total"
        false -> "Processing images...."
    })
    @Serializable
    data object ScanProcessCompleted
        : MeasurementResultStatus("ScanProcess completed!")
    @Serializable
    data class ExceptionCaught(val reason: String?)
        : MeasurementResultStatus("Exception: $reason")
    @Serializable
    data class TreadDepthResultQueried(val treadDepthResultStatus: TreadDepthResultStatus)
        : MeasurementResultStatus(treadDepthResultStatus.statusDescription)

    override fun toString(): String {
        return Json.encodeToString(this)
    }
}

@Serializable
sealed class TreadDepthResultStatus(val statusDescription: String) {
    @Serializable
    data object NotYetAvailable: TreadDepthResultStatus(
        "Waiting for result...")
    @Serializable
    data class Succeed(val treadDepthResult: TreadDepthResult): TreadDepthResultStatus(
        "Tread depth result ready.")
    @Serializable
    data class Failed(val errorCode: String?, val reason: String?): TreadDepthResultStatus(
        "Failed to get tread depth result.")

    override fun toString(): String {
        return Json.encodeToString(this)
    }
}

@Serializable
data class MeasurementResultData(val measurementUUID: String?,
                                 var measurementSystem: MeasurementSystem = MeasurementSystem.Metric,
                                 var measurementResultStatus: MeasurementResultStatus = MeasurementResultStatus.ScanStarted
) {

    fun getTreadDepthReportResult(onStatusResult: ((TreadDepthResultStatus) -> Unit)) {
        AnylineTireTreadSdk.getTreadDepthReportResult(
            measurementUUID.toString(),
            onResponse = { response: Response<TreadDepthResult> ->
                when (response) {
                    is Response.Success -> {
                        TreadDepthResultStatus.Succeed(response.data).apply {
                            measurementResultStatus =
                                MeasurementResultStatus.TreadDepthResultQueried(this)
                            onStatusResult.invoke(this)
                        }
                    }

                    is Response.Error -> {
                        response.errorCode?.let {
                            TreadDepthResultStatus.Failed(it,response.errorMessage).apply {
                                measurementResultStatus =
                                    MeasurementResultStatus.TreadDepthResultQueried(this)
                                onStatusResult.invoke(this)
                            }
                        }
                    }

                    is Response.Exception -> {
                        TreadDepthResultStatus.Failed("",response.exception.message).apply {
                            measurementResultStatus =
                                MeasurementResultStatus.TreadDepthResultQueried(this)
                            onStatusResult.invoke(this)
                        }
                    }
                }
            }
        )
    }

    override fun toString(): String {
        return Json{encodeDefaults = true}.encodeToString(this)
    }

    companion object {
        @JvmStatic
        fun fromString(value: String): MeasurementResultData {
            return Json.decodeFromString<MeasurementResultData>(value)
        }
    }
}


