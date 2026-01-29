package com.ghz.mystoreday_app

import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.TextView
import com.google.android.gms.ads.nativead.AdChoicesView
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class MainActivity : FlutterActivity() {

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    // ✅ O mesmo factoryId que você usa no Flutter:
    // factoryId: 'productCardNative'
    GoogleMobileAdsPlugin.registerNativeAdFactory(
      flutterEngine,
      "productCardNative",
      ProductCardNativeFactory(layoutInflater)
    )
  }

  override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
    GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "productCardNative")
    super.cleanUpFlutterEngine(flutterEngine)
  }
}

class ProductCardNativeFactory(
  private val inflater: LayoutInflater
) : GoogleMobileAdsPlugin.NativeAdFactory {

  override fun createNativeAd(
    nativeAd: NativeAd,
    customOptions: MutableMap<String, Any>?
  ): NativeAdView {

    val adView = inflater.inflate(R.layout.native_ad_card, null) as NativeAdView

    // ✅ IDs 100% iguais ao XML
    val mediaView = adView.findViewById<MediaView>(R.id.ad_media)
    val headlineView = adView.findViewById<TextView>(R.id.ad_headline)
    val bodyView = adView.findViewById<TextView>(R.id.ad_body)
    val ctaView = adView.findViewById<Button>(R.id.ad_call_to_action)
    val adChoicesView = adView.findViewById<AdChoicesView>(R.id.ad_choices)

    // ✅ Liga views ao NativeAdView (obrigatório)
    adView.mediaView = mediaView
    adView.headlineView = headlineView
    adView.bodyView = bodyView
    adView.callToActionView = ctaView
    adView.adChoicesView = adChoicesView

    // Headline
    headlineView.text = nativeAd.headline ?: ""
    headlineView.visibility = if (nativeAd.headline.isNullOrEmpty()) View.GONE else View.VISIBLE

    // Body
    bodyView.text = nativeAd.body ?: ""
    bodyView.visibility = if (nativeAd.body.isNullOrEmpty()) View.GONE else View.VISIBLE

    // CTA
    ctaView.text = nativeAd.callToAction ?: ""
    ctaView.visibility = if (nativeAd.callToAction.isNullOrEmpty()) View.GONE else View.VISIBLE

    // Media (imagem/vídeo)
    // Se não tiver media, fica só o fundo do MediaView (layout ainda fica ok)
    mediaView.setMediaContent(nativeAd.mediaContent)

    // Finaliza
    adView.setNativeAd(nativeAd)

    return adView
  }
}
