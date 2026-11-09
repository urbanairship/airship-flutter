package com.airship.flutter

import android.content.Context
import androidx.datastore.preferences.core.PreferenceDataStoreFactory
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStoreFile
import androidx.test.core.app.ApplicationProvider
import com.urbanairship.android.framework.proxy.ProxyStore
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.runBlocking
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import java.io.File

/**
 * Covers the data store that plugin versions before 7.0.0 used to hold the app key and secret.
 */
@RunWith(RobolectricTestRunner::class)
class FlutterAutopilotMigrationTest {

    private val context: Context = ApplicationProvider.getApplicationContext()
    private val storeFile: File
        get() = context.preferencesDataStoreFile(STORE_NAME)

    /** A [ProxyStore] built by reflection: the proxy keeps its constructor internal to its module. */
    private fun newProxyStore(): ProxyStore {
        val constructor = ProxyStore::class.java.getDeclaredConstructor(Context::class.java)
        constructor.isAccessible = true
        return constructor.newInstance(context)
    }

    /** True if a DataStore can be opened on [file], i.e. no other instance holds it. */
    private fun canClaim(file: File): Boolean {
        val scope = CoroutineScope(Dispatchers.IO + SupervisorJob())
        return try {
            val store = PreferenceDataStoreFactory.create(scope = scope) { file }
            runBlocking { store.data.first() }
            true
        } catch (e: IllegalStateException) {
            false
        } finally {
            scope.cancel()
        }
    }

    /** Writes the legacy store with DataStore itself, then releases its hold on the file. */
    private fun writeLegacyStore(vararg entries: Pair<String, String>) {
        val scope = CoroutineScope(Dispatchers.IO + SupervisorJob())
        try {
            val store = PreferenceDataStoreFactory.create(scope = scope) { storeFile }
            runBlocking {
                store.edit { preferences ->
                    entries.forEach { (key, value) ->
                        preferences[stringPreferencesKey(key)] = value
                    }
                }
            }
        } finally {
            scope.cancel()
        }
    }

    @Test
    fun migrationWithNoStoreDoesNotOpenTheDataStore() {
        val proxyStore = newProxyStore()

        FlutterAutopilot().onMigrateData(context, proxyStore)

        // DataStore refuses a second instance for a file one is already active on, and the
        // migration never releases the one it creates, so claiming the file here succeeds only
        // if the migration left it alone.
        assertTrue("the store must not be opened when there is no file to migrate", canClaim(storeFile))
        assertFalse(storeFile.exists())
        assertNull(proxyStore.airshipConfig)
    }

    @Test
    fun migrationMovesTheAppKeyAndSecretIntoTheProxyStore() {
        writeLegacyStore("app_key" to "legacy-app-key", "app_secret" to "legacy-app-secret")
        val proxyStore = newProxyStore()

        FlutterAutopilot().onMigrateData(context, proxyStore)

        val environment = proxyStore.airshipConfig?.defaultEnvironment
        assertEquals("legacy-app-key", environment?.appKey)
        assertEquals("legacy-app-secret", environment?.appSecret)
        assertFalse("a surviving store would migrate again next launch", storeFile.exists())
    }

    @Test
    fun migrationDiscardsAnUnreadableStore() {
        storeFile.parentFile!!.mkdirs()
        storeFile.writeBytes("not a preferences proto".toByteArray())
        val proxyStore = newProxyStore()

        FlutterAutopilot().onMigrateData(context, proxyStore)

        assertFalse("retrying a corrupt store would stall every later launch", storeFile.exists())
        assertNull(proxyStore.airshipConfig)
    }

    private companion object {
        const val STORE_NAME = "airshipFlutterPlugin"
    }
}
