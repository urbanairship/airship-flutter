import android.content.Context
import android.content.Intent
import android.util.Log
import com.airship.flutter.EventService
import com.urbanairship.UAirship
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.view.FlutterMain

class EventPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    private var mContext : Context? = null

    companion object {

        @JvmStatic
        val EVENT_PREFERENCES_KEY = "event_plugin_cache"

        @JvmStatic
        val CALLBACK_DISPATCHER_HANDLE_KEY = "callback_dispatch_handler"

        @JvmStatic
        fun saveCallBackHandle(context: Context, args: ArrayList<*>?) {
            val callbackHandle = args!![0] as Long

            context.getSharedPreferences(EVENT_PREFERENCES_KEY, Context.MODE_PRIVATE)
                    .edit()
                    .putLong(CALLBACK_DISPATCHER_HANDLE_KEY, callbackHandle)
                    .apply()
        }

        /*@JvmStatic
        private fun performAction(call: MethodCall, result: Result) {
            val args = call.arguments<ArrayList<*>>()
            //EventPlugin.saveCallBackHandle(context, args)

            Log.d("UALibUlrich", "test Ulrich")
            Log.d("UALibUlrich", "payload: " + "oh oh")

            FlutterMain.startInitialization(UAirship.getApplicationContext())
            FlutterMain.ensureInitializationComplete(UAirship.getApplicationContext(), null)
            var intent = Intent()
            intent.putExtra("payload", args!![1] as String)
            EventService.enqueueWork(UAirship.getApplicationContext(), intent)

            result.success(true)
        }*/

        @JvmStatic
        fun test(payload: String) {
            Log.d("UALibUlrich", "test Ulrich")
            Log.d("UALibUlrich", "payload: $payload")
        }
    }



    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        mContext = binding.getApplicationContext()

        val channel = MethodChannel(binding.binaryMessenger, "com.airship.flutter/event_plugin")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        mContext = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        /*val args = call.arguments<ArrayList<*>>()
        when(call.method) {
            "EventPlugin.performAction" -> {
                saveCallBackHandle(mContext!!, args)
                performAction(call, result)
            }
            else -> {
                print("Unknown method.")
                result.notImplemented()
            }
        }*/
    }

}