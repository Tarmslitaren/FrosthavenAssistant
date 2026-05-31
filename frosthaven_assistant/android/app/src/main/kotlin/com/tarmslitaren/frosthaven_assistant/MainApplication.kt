package com.tarmslitaren.frosthaven_assistant

import android.app.Application
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugins.GeneratedPluginRegistrant

class MainApplication : Application() {

    companion object {
        const val ENGINE_ID = "main_engine"
    }

    override fun onCreate() {
        super.onCreate()
        // Pre-warm a cached FlutterEngine so its lifecycle is tied to the
        // process rather than to any individual Activity.  Without this,
        // "Don't keep activities" (or any Activity recreation) destroys the
        // Dart VM and closes the server socket even though the foreground
        // service is still running.
        val engine = FlutterEngine(this)
        GeneratedPluginRegistrant.registerWith(engine)
        engine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )
        FlutterEngineCache.getInstance().put(ENGINE_ID, engine)
    }
}
