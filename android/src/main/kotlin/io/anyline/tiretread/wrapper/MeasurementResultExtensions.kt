package io.anyline.tiretread.wrapper

import io.anyline.tiretread.sdk.types.TreadDepthResult
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

@JvmOverloads
fun TreadDepthResult.encodeToString(prettyPrint: Boolean? = null, prettyPrintIndent: String? = null): String {
    return encodeToString(this, prettyPrint, prettyPrintIndent)
}

private inline fun <reified T> encodeToString(source: T,  prettyPrint: Boolean?, prettyPrintIndent: String?): String {
    val prettyJson = Json {
        this.prettyPrint = prettyPrint?: true
        this.prettyPrintIndent = prettyPrintIndent?: " "
    }
    return prettyJson.encodeToString(source)
}