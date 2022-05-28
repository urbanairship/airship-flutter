package com.airship.flutter

import android.util.Log

/// The order of enums constant
/// is critically important.
enum class LogLevel {

    /**
     * Priority constant for the println method; use Log.v.
     */
    VERBOSE,

    /**
     * Priority constant for the println method; use Log.d.
     */
    DEBUG,

    /**
     * Priority constant for the println method; use Log.i.
     */
    INFO,

    /**
     * Priority constant for the println method; use Log.w.
     */
    WARN,

    /**
     * Priority constant for the println method; use Log.e.
     */
    ERROR,

    /**
     * Priority constant for the println method.
     */
    ASSERT;

    /// Log static constants start 2
    /// ordinals are zero indexed
    fun logLevel(): Int {
        return ordinal + 2
    }
}