package com.airship.flutter

import androidx.datastore.core.CorruptionException
import androidx.datastore.core.Serializer
import com.airship.flutter.config.Config
import com.google.protobuf.InvalidProtocolBufferException
import kotlinx.coroutines.*
import java.io.InputStream
import java.io.OutputStream

object ConfigSerializer : Serializer<Config.AirshipConfig> {
    override val defaultValue: Config.AirshipConfig = Config.AirshipConfig.getDefaultInstance()
    override suspend fun readFrom(input: InputStream): Config.AirshipConfig =
        coroutineScope {
            val configIO = async(Dispatchers.IO) {
                Config.AirshipConfig.parseFrom(input)
            }
            try {
                configIO.await()
            }
            catch (exception: InvalidProtocolBufferException) {
                throw CorruptionException("Cannot read proto.", exception)
            }
        }

    override suspend fun writeTo(t: Config.AirshipConfig, output: OutputStream) {
        withContext(Dispatchers.IO) { launch (Dispatchers.IO) {
                t.writeTo(output)
            }
        }
    }
}