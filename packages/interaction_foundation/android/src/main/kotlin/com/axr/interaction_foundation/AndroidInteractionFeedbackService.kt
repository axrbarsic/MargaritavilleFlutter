package com.axr.interaction_foundation

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.view.HapticFeedbackConstants
import android.view.View
import io.flutter.embedding.engine.plugins.FlutterPlugin

internal class AndroidInteractionFeedbackService(
  context: Context,
  flutterAssets: FlutterPlugin.FlutterAssets,
  private val viewProvider: () -> View?,
) : NativeInteractionFeedbackHostApi {
  private val handler = Handler(Looper.getMainLooper())
  private val soundPlayer = AndroidInteractionSoundPlayer(context, flutterAssets)
  private val hapticPlayer = AndroidInteractionHapticPlayer(context, viewProvider)
  private var audioContext = NativeInteractionAudioContext.INTERACTIVE
  private var coalescingWindowMs = 45L
  private var queuedSound: QueuedSound? = null
  private var soundRunnable: Runnable? = null

  override fun configure(configuration: NativeFeedbackConfiguration) {
    coalescingWindowMs = configuration.soundCoalescingWindowMs.coerceAtLeast(0)
    soundPlayer.configure(configuration.sounds, configuration.playerPoolSize.toInt())
  }

  override fun emit(request: NativeFeedbackRequest) {
    if (audioContext == NativeInteractionAudioContext.BACKGROUND) return
    hapticPlayer.perform(request.cue)
    val soundId = request.soundId ?: return
    if (audioContext == NativeInteractionAudioContext.VOICE_CAPTURE) return
    queueSound(soundId, request.soundPriority)
  }

  override fun previewSound(soundId: String) {
    if (
      audioContext == NativeInteractionAudioContext.BACKGROUND ||
        audioContext == NativeInteractionAudioContext.VOICE_CAPTURE
    ) return
    clearPending()
    soundPlayer.play(soundId)
  }

  override fun setAudioContext(context: NativeInteractionAudioContext) {
    audioContext = context
    if (
      context == NativeInteractionAudioContext.BACKGROUND ||
        context == NativeInteractionAudioContext.VOICE_CAPTURE
    ) {
      clearPending()
      soundPlayer.stop()
    }
  }

  override fun clearPending() {
    soundRunnable?.let(handler::removeCallbacks)
    soundRunnable = null
    queuedSound = null
  }

  fun dispose() {
    clearPending()
    soundPlayer.dispose()
  }

  private fun queueSound(id: String, priority: Long) {
    val next = QueuedSound(id, priority)
    if ((queuedSound?.priority ?: Long.MIN_VALUE) > priority) return
    queuedSound = next
    if (soundRunnable != null) return
    val runnable = Runnable {
      soundRunnable = null
      val sound = queuedSound
      queuedSound = null
      sound?.let { soundPlayer.play(it.id) }
    }
    soundRunnable = runnable
    handler.postDelayed(runnable, coalescingWindowMs)
  }

  private data class QueuedSound(val id: String, val priority: Long)
}
