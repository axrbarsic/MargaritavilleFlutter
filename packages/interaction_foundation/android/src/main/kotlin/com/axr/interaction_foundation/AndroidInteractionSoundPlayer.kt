package com.axr.interaction_foundation

import android.content.Context
import android.media.AudioAttributes
import android.media.SoundPool
import io.flutter.embedding.engine.plugins.FlutterPlugin

internal class AndroidInteractionSoundPlayer(
  private val context: Context,
  private val flutterAssets: FlutterPlugin.FlutterAssets,
) {
  private var soundPool: SoundPool? = null
  private var registrations = emptyMap<String, NativeSoundRegistration>()
  private val soundIds = mutableMapOf<String, Int>()
  private val loadedIds = mutableSetOf<Int>()
  private var pendingSoundId: String? = null
  private var currentStreamId: Int? = null

  fun configure(sounds: List<NativeSoundRegistration>, poolSize: Int) {
    disposePool()
    registrations = sounds.associateBy { it.id }
    val pool = SoundPool.Builder()
      .setMaxStreams(1)
      .setAudioAttributes(
        AudioAttributes.Builder()
          .setUsage(AudioAttributes.USAGE_ASSISTANCE_SONIFICATION)
          .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
          .build(),
      )
      .build()
    soundPool = pool
    pool.setOnLoadCompleteListener { _, sampleId, status ->
      if (status != 0) return@setOnLoadCompleteListener
      loadedIds += sampleId
      val pending = pendingSoundId
      if (pending != null && soundIds[pending] == sampleId) {
        pendingSoundId = null
        play(pending)
      }
    }
    for (sound in sounds) {
      val assetPath = flutterAssets.getAssetFilePathBySubpath(
        sound.packageAssetPath,
        "interaction_foundation",
      )
      runCatching {
        context.assets.openFd(assetPath).use { descriptor ->
          soundIds[sound.id] = pool.load(descriptor, 1)
        }
      }
    }
  }

  fun play(soundId: String) {
    val pool = soundPool ?: return
    val registration = registrations[soundId] ?: return
    val sampleId = soundIds[soundId] ?: return
    if (sampleId !in loadedIds) {
      pendingSoundId = soundId
      return
    }
    stop()
    val volume = registration.volume.toFloat().coerceIn(0f, 1f)
    val pan = registration.pan.toFloat().coerceIn(-1f, 1f)
    val left = if (pan > 0) volume * (1 - pan) else volume
    val right = if (pan < 0) volume * (1 + pan) else volume
    currentStreamId = pool.play(
      sampleId,
      left,
      right,
      1,
      0,
      registration.rate.toFloat().coerceIn(0.5f, 2f),
    )
  }

  fun stop() {
    val pool = soundPool ?: return
    currentStreamId?.let(pool::stop)
    currentStreamId = null
  }

  fun dispose() {
    disposePool()
    registrations = emptyMap()
  }

  private fun disposePool() {
    stop()
    soundPool?.release()
    soundPool = null
    soundIds.clear()
    loadedIds.clear()
    pendingSoundId = null
  }
}
