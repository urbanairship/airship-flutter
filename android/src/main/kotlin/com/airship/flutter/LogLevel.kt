package com.airship.flutter

import android.util.Log
import com.airship.flutter.config.Config

val Config.LogLevel.parse: Int
    get() {
        return when (this) {
            Config.LogLevel.VERBOSE -> Log.VERBOSE
            Config.LogLevel.DEBUG -> Log.DEBUG
            Config.LogLevel.INFO -> Log.INFO
            Config.LogLevel.WARN -> Log.WARN
            Config.LogLevel.ERROR -> Log.ERROR
            Config.LogLevel.NONE -> Log.ASSERT
            else -> Log.ASSERT
        }
    }

