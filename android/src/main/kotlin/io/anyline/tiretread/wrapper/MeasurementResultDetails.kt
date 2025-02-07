package io.anyline.tiretread.wrapper

import io.anyline.tiretread.sdk.AnylineTireTreadSdk
import io.anyline.tiretread.sdk.Response
import io.anyline.tiretread.sdk.getHeatmap
import io.anyline.tiretread.sdk.types.Heatmap
import io.ktor.client.HttpClient
import io.ktor.client.call.body
import io.ktor.client.request.get
import io.ktor.client.statement.bodyAsText
import io.ktor.http.HttpStatusCode
import io.ktor.http.Url
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import java.io.InputStream

class MeasurementResultDetails(private val measurementResultData: MeasurementResultData) {

    private val heatMapResult: MutableStateFlow<HeatMapState> = MutableStateFlow(HeatMapState.Unknown)
    val heatMapResultValue = heatMapResult.asStateFlow()

    sealed class HeatMapState() {
        data object Unknown: HeatMapState()
        data object GettingHeatMapUrl: HeatMapState()
        data class HeatMapUrlReady(val heatmap: Heatmap): HeatMapState()
        data class DownloadingHeatMap(val heatmap: Heatmap): HeatMapState()
        data class Failed(val code: String, val message: String)
            : HeatMapState()
        data class Ready(val heatmap: Heatmap, val stream: InputStream)
            : HeatMapState()
    }

    suspend fun getHeatMap(): HeatMapState {
        if (heatMapResult.value is HeatMapState.Ready) {
            return heatMapResult.value
        }
        return getHeatMapUrl().run {
            if (this is HeatMapState.HeatMapUrlReady) {
                getHeatMapImageContent(this.heatmap)
            }
            this
        }
    }

    private fun getHeatMapUrl(): HeatMapState {
        heatMapResult.update { HeatMapState.Unknown }
        heatMapResult.update { HeatMapState.GettingHeatMapUrl }
        AnylineTireTreadSdk.getHeatmap(measurementResultData.measurementUUID) { heatMapResponse ->
            when (heatMapResponse) {
                is Response.Success -> {
                    heatMapResult.update { HeatMapState.HeatMapUrlReady(heatMapResponse.data) }
                }
                is Response.Error -> {
                    heatMapResult.update {
                        HeatMapState.Failed(
                            heatMapResponse.errorCode ?: "",
                            heatMapResponse.errorMessage ?: "HeatMap Url not available!"
                        )
                    }
                }
                is Response.Exception -> {
                    heatMapResult.update {
                        HeatMapState.Failed(
                            "",
                            heatMapResponse.exception.message ?: "Failed to get HeatMap Url!"
                        )
                    }
                }
            }
        }
        return heatMapResult.value
    }

    private suspend fun getHeatMapImageContent(heatmap: Heatmap): HeatMapState {
        heatMapResult.update { HeatMapState.DownloadingHeatMap(heatmap) }

        val httpClient = HttpClient()

        val url = Url(heatmap.url)
        try {
            val response = httpClient.get(url)
            heatMapResult.update {
                when (response.status) {
                    HttpStatusCode.OK -> HeatMapState.Ready(heatmap, response.body())
                    else -> {
                        HeatMapState.Failed("", response.bodyAsText())
                    }
                }
            }
        }
        catch (e: Exception) {
            heatMapResult.update { HeatMapState.Failed("", e.localizedMessage ?: "") }
        }
        return heatMapResult.value
    }
}