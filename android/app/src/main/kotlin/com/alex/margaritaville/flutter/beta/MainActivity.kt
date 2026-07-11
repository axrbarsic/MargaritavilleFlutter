package com.alex.margaritaville.flutter.beta

import android.os.Build
import android.os.Bundle
import com.alex.margaritaville.flutter.beta.edr.AndroidEdrOverlayAdapter
import com.alex.margaritaville.flutter.beta.edr.EdrOverlayHostApi
import com.alex.margaritaville.flutter.beta.hdr.runtime.AndroidVsyncFrameClock
import com.alex.margaritaville.flutter.beta.hdr.runtime.VipHdrOverlayHost
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BinaryMessenger

class MainActivity : FlutterActivity() {
    private var edrAdapter: AndroidEdrOverlayAdapter? = null
    private var edrMessenger: BinaryMessenger? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        edrMessenger = flutterEngine.dartExecutor.binaryMessenger
    }

    override fun onPostCreate(savedInstanceState: Bundle?) {
        super.onPostCreate(savedInstanceState)
        val messenger = edrMessenger ?: return
        val hdrSupported = Build.VERSION.SDK_INT >= 34 && display?.isHdr == true
        val host =
            if (hdrSupported) {
                VipHdrOverlayHost(
                    activity = this,
                    frameClock = AndroidVsyncFrameClock(),
                    requestedHeadroom = AndroidEdrOverlayAdapter.DEFAULT_PRODUCTION_WINDOW_HEADROOM,
                    maximumSignalHeadroom =
                        AndroidEdrOverlayAdapter.DEFAULT_PRODUCTION_SIGNAL_HEADROOM,
                )
            } else {
                null
            }
        edrAdapter =
            AndroidEdrOverlayAdapter(
                activity = this,
                binaryMessenger = messenger,
                overlayHost = host,
                maximumSignalHeadroom =
                    AndroidEdrOverlayAdapter.DEFAULT_PRODUCTION_SIGNAL_HEADROOM,
            ).also {
                EdrOverlayHostApi.setUp(messenger, it)
            }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        EdrOverlayHostApi.setUp(flutterEngine.dartExecutor.binaryMessenger, null)
        edrAdapter?.close()
        edrAdapter = null
        edrMessenger = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    override fun onDestroy() {
        edrMessenger?.let { EdrOverlayHostApi.setUp(it, null) }
        edrAdapter?.close()
        edrAdapter = null
        super.onDestroy()
    }
}
