package com.tarmslitaren.frosthaven_assistant

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL =
            "com.tarmslitaren.frosthaven_assistant/foreground_service"
    }

    // Use the engine cached by MainApplication so Activity recreation does
    // not restart the Dart VM or close the server socket.
    override fun getCachedEngineId(): String = MainApplication.ENGINE_ID

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "start" -> {
                        ServerForegroundService.start(this)
                        result.success(null)
                    }
                    "stop" -> {
                        ServerForegroundService.stop(this)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
