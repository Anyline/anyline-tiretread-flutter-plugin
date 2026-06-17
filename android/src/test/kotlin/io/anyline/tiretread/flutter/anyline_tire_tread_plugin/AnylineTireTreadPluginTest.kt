package io.anyline.tiretread.flutter.anyline_tire_tread_plugin

import io.anyline.tiretread.flutter.AnylineTireTreadPlugin
import io.anyline.tiretread.flutter.Constants
import io.anyline.tiretread.sdk.api.ErrorCode
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlin.test.Test
import kotlin.test.assertEquals
import org.mockito.ArgumentCaptor
import org.mockito.Mockito

/*
 * JVM unit tests for the plugin's synchronous error paths. Paths that hit the
 * SDK or the Android main looper are covered by manual device testing.
 *
 * Run from `example/android/` with `./gradlew testDebugUnitTest`.
 */
internal class AnylineTireTreadPluginTest {

  @Test
  fun onMethodCall_unknownMethod_callsNotImplemented() {
    val plugin = AnylineTireTreadPlugin()
    val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)

    plugin.onMethodCall(MethodCall("METHOD_DOES_NOT_EXIST", null), mockResult)

    Mockito.verify(mockResult).notImplemented()
  }

  @Test
  fun onMethodCall_setExperimentalFlagsWithNullFlags_returnsInvalidArgument() {
    val plugin = AnylineTireTreadPlugin()
    val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)

    val call = MethodCall(
      Constants.METHOD_SET_EXPERIMENTAL_FLAGS,
      mapOf(Constants.EXTRA_EXPERIMENTAL_FLAGS to null),
    )
    plugin.onMethodCall(call, mockResult)

    Mockito.verify(mockResult).error(
      ErrorCode.INVALID_ARGUMENT.name,
      "Experimental flags are null",
      null,
    )
  }

  @Test
  fun onMethodCall_scanWithoutContext_returnsFailedOutcomeWithInvalidArgument() {
    // Plugin is not attached to an engine or activity -> no context available.
    // Must resolve with a ScanFailed outcome (RN parity), not an exception.
    val plugin = AnylineTireTreadPlugin()
    val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)

    val call = MethodCall(
      Constants.METHOD_SCAN,
      mapOf(
        Constants.EXTRA_CONFIG_JSON to "{}",
        Constants.EXTRA_SCAN_OPTIONS_JSON to null,
      ),
    )
    plugin.onMethodCall(call, mockResult)

    @Suppress("UNCHECKED_CAST")
    val captor = ArgumentCaptor.forClass(Map::class.java) as ArgumentCaptor<Map<String, Any?>>
    Mockito.verify(mockResult).success(captor.capture())

    val outcome = captor.value
    assertEquals("ScanFailed", outcome["kind"])
    @Suppress("UNCHECKED_CAST")
    val error = outcome["error"] as Map<String, Any?>
    assertEquals(ErrorCode.INVALID_ARGUMENT.name, error["code"])
  }
}
