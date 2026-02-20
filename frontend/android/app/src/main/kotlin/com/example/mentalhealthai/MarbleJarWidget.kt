package com.yourapp.mindfulcare

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import android.content.SharedPreferences
import org.json.JSONArray

class MarbleJarWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val prefs = context.getSharedPreferences(
            "FlutterSharedPreferences",
            Context.MODE_PRIVATE
        )
        
        val marblesJson = prefs.getString("flutter.mood_marbles", "[]")
        val marbles = JSONArray(marblesJson)
        
        val views = RemoteViews(context.packageName, R.layout.marble_jar_widget)
        views.setTextViewText(R.id.marble_count, "${marbles.length()}/30 days")
        
        // Update marbles display
        // (You'd draw the marbles here using RemoteViews)
        
        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}