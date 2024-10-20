/* Copyright Urban Airship and Contributors */

package com.urbanairship.reactnative

import android.content.Context
import com.urbanairship.UAirship

/**
 * Extender that will be called during takeOff to customize the airship instance.
 * Register the extender fully qualified class name in the manifest under the key
 * `com.urbanairship.flutter.AIRSHIP_EXTENDER`.
 */
@Deprecated("Use com.urbanairship.android.framework.proxy.AirshipPluginExtender instead and register it under the manifest key `com.urbanairship.plugin.extender`")
interface AirshipExtender  {
    fun onAirshipReady(context: Context, airship: UAirship)
}