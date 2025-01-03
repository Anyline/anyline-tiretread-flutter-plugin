package io.anyline.tiretread.flutter.anyline_tire_tread_plugin

import io.anyline.tiretread.flutter.AnylineTireTreadPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlin.test.Test
import org.mockito.Mockito

/*
 * This demonstrates a simple unit test of the Kotlin portion of this plugin's implementation.
 *
 * Once you have built the plugin's example app, you can run these tests from the command
 * line by running `./gradlew testDebugUnitTest` in the `example/android/` directory, or
 * you can run them directly from IDEs that support JUnit such as Android Studio.
 */

internal class AnylineTireTreadPluginTest {
  @Test
  fun onMethodCall_getPlatformVersion_returnsExpectedValue() {
    val plugin = AnylineTireTreadPlugin()

    val call = MethodCall("getPlatformVersion", null)
    val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
    plugin.onMethodCall(call, mockResult)

    Mockito.verify(mockResult).success("Android " + android.os.Build.VERSION.RELEASE)
  }

  @Test
  fun onMethodCall_setupWithPluginNotAttached_shouldAssertException() {
    val plugin = AnylineTireTreadPlugin()

    val call = MethodCall("setup", "")
    val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
    plugin.onMethodCall(call, mockResult)

    Mockito.verify(mockResult).error(
      AnylineTireTreadPlugin.PluginError.PluginNotAttachedToActivityError::class.simpleName!!,
      AnylineTireTreadPlugin.PluginError.PluginNotAttachedToActivityError.message,
      null)
  }
}
