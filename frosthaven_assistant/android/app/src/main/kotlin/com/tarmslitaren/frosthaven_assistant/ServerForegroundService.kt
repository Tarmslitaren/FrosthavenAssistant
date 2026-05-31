package com.tarmslitaren.frosthaven_assistant

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.IBinder

class ServerForegroundService : Service() {

    companion object {
        private const val CHANNEL_ID = "frosthaven_server"
        private const val NOTIFICATION_ID = 1001

        fun start(context: Context) {
            context.startForegroundService(
                Intent(context, ServerForegroundService::class.java)
            )
        }

        fun stop(context: Context) {
            context.stopService(
                Intent(context, ServerForegroundService::class.java)
            )
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val nm = getSystemService(NotificationManager::class.java)
        nm.createNotificationChannel(
            NotificationChannel(
                CHANNEL_ID,
                "Game Server",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Keeps the X-haven server running while the app is in the background"
            }
        )

        val notification = Notification.Builder(this, CHANNEL_ID)
            .setContentTitle("X-haven Server Running")
            .setContentText("Clients can connect and play")
            .setSmallIcon(R.mipmap.launcher_icon)
            .setOngoing(true)
            .build()

        startForeground(NOTIFICATION_ID, notification)
        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
