package com.airship.flutter

import androidx.datastore.core.CorruptionException
import androidx.datastore.core.Serializer
import com.airship.flutter.config.Config
import com.google.protobuf.InvalidProtocolBufferException
import java.io.InputStream
import java.io.OutputStream

object ConfigSerializer : Serializer<Config.AirshipConfig> {
    override val defaultValue: Config.AirshipConfig = Config.AirshipConfig.getDefaultInstance()
    override suspend fun readFrom(input: InputStream): Config.AirshipConfig {
        try {
            return Config.AirshipConfig.parseFrom(input)
        } catch (exception: InvalidProtocolBufferException) {
            throw CorruptionException("Cannot read proto.", exception)
        }
    }

    override suspend fun writeTo(t: Config.AirshipConfig, output: OutputStream) {
        t.writeTo(output)
    }

}