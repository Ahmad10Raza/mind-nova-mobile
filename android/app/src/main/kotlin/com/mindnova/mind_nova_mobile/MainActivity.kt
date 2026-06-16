package com.mindnova.app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.os.Bundle
import com.ryanheise.audioservice.AudioServiceActivity

class MainActivity: AudioServiceActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannels()
    }

    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            
            // Focus Timer Channel
            val focusChannel = NotificationChannel(
                "mindnova_focus_timer",
                "MindNova Focus Timer",
                NotificationManager.IMPORTANCE_LOW
            )
            manager.createNotificationChannel(focusChannel)
            
            // Sleep Audio Channel
            val sleepChannel = NotificationChannel(
                "com.mindnova.sleep.channel.audio",
                "MindNova Sleep Mode",
                NotificationManager.IMPORTANCE_LOW
            )
            manager.createNotificationChannel(sleepChannel)
        }
    }
}
