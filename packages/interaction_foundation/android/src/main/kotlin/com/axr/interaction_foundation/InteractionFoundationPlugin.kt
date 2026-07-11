package com.axr.interaction_foundation

import android.app.Activity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

class InteractionFoundationPlugin : FlutterPlugin, ActivityAware {
  private var activity: Activity? = null
  private var service: AndroidInteractionFeedbackService? = null
  private var voiceService: AndroidVoiceCaptureUnavailableService? = null

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    service = AndroidInteractionFeedbackService(
      context = binding.applicationContext,
      flutterAssets = binding.flutterAssets,
      viewProvider = { activity?.window?.decorView },
    ).also {
      NativeInteractionFeedbackHostApi.setUp(binding.binaryMessenger, it)
    }
    voiceService = AndroidVoiceCaptureUnavailableService().also {
      VoiceCaptureHostApi.setUp(binding.binaryMessenger, it)
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    NativeInteractionFeedbackHostApi.setUp(binding.binaryMessenger, null)
    VoiceCaptureHostApi.setUp(binding.binaryMessenger, null)
    service?.dispose()
    service = null
    voiceService = null
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    activity = null
  }
}
