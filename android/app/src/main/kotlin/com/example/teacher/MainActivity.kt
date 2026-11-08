package com.example.teacher

import android.content.Intent
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.security.MessageDigest

/**
 * Exposes the small amount of Android package information the update flow
 * needs. Everything here is read-only except [openInstallSettings], which only
 * opens the system settings screen.
 */
class MainActivity : FlutterActivity() {
    private companion object {
        const val CHANNEL = "mr/update/apk"
        const val INVALID_PATH = "invalid_path"
        const val CHANNEL_ERROR = "apk_channel_error"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "inspect" -> {
                            val path = call.argument<String>("path")
                            if (path.isNullOrBlank()) {
                                result.error(
                                    INVALID_PATH,
                                    "مسار ملف التحديث غير صالح.",
                                    null,
                                )
                            } else {
                                result.success(inspectApk(path))
                            }
                        }

                        "installed" -> result.success(installedAppInfo())
                        "canInstallPackages" -> result.success(canInstallPackages())
                        "openInstallSettings" -> {
                            openInstallSettings()
                            result.success(null)
                        }

                        else -> result.notImplemented()
                    }
                } catch (error: Exception) {
                    result.error(
                        CHANNEL_ERROR,
                        error.message ?: "تعذر إكمال عملية التحقق من التحديث.",
                        null,
                    )
                }
            }
    }

    private fun inspectApk(path: String): Map<String, Any?> {
        if (!File(path).exists()) {
            return mapOf(
                "parsed" to false,
                "deviceSdk" to Build.VERSION.SDK_INT,
                "error" to "ملف التحديث غير موجود على الجهاز.",
            )
        }

        val info = readPackageInfo(path)
            ?: return mapOf(
                "parsed" to false,
                "deviceSdk" to Build.VERSION.SDK_INT,
                "error" to "ملف التحديث غير صالح أو لا يمكن لـ Android قراءته.",
            )

        val appInfo = info.applicationInfo
        val minSdk = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N && appInfo != null) {
            appInfo.minSdkVersion
        } else {
            0
        }

        return mapOf(
            "parsed" to true,
            "packageName" to info.packageName,
            "versionCode" to versionCodeOf(info),
            "versionName" to (info.versionName ?: ""),
            "minSdk" to minSdk,
            "deviceSdk" to Build.VERSION.SDK_INT,
            "signatureHashes" to signatureHashes(info),
        )
    }

    private fun installedAppInfo(): Map<String, Any?> {
        val info = readInstalledPackageInfo(applicationContext.packageName)
            ?: return mapOf(
                "packageName" to applicationContext.packageName,
                "versionCode" to 0,
                "versionName" to "",
                "signatureHashes" to emptyList<String>(),
                "deviceSdk" to Build.VERSION.SDK_INT,
            )

        return mapOf(
            "packageName" to info.packageName,
            "versionCode" to versionCodeOf(info),
            "versionName" to (info.versionName ?: ""),
            "signatureHashes" to signatureHashes(info),
            "deviceSdk" to Build.VERSION.SDK_INT,
        )
    }

    @Suppress("DEPRECATION")
    private fun readPackageInfo(path: String): PackageInfo? {
        val pm = applicationContext.packageManager
        return try {
            pm.getPackageArchiveInfo(path, signatureFlag())
        } catch (_: Exception) {
            null
        }
    }

    @Suppress("DEPRECATION")
    private fun readInstalledPackageInfo(packageName: String): PackageInfo? {
        val pm = applicationContext.packageManager
        return try {
            pm.getPackageInfo(packageName, signatureFlag())
        } catch (_: Exception) {
            null
        }
    }

    @Suppress("DEPRECATION")
    private fun signatureFlag(): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            PackageManager.GET_SIGNING_CERTIFICATES
        } else {
            PackageManager.GET_SIGNATURES
        }
    }

    @Suppress("DEPRECATION")
    private fun versionCodeOf(info: PackageInfo): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            info.longVersionCode.toInt()
        } else {
            info.versionCode
        }
    }

    /**
     * Returns the SHA-256 of each signing certificate, lower-case hex. Older
     * certificates from the signing history are included so a legitimate key
     * rotation does not block updates.
     */
    @Suppress("DEPRECATION")
    private fun signatureHashes(info: PackageInfo): List<String> {
        val signatures = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            val signingInfo = info.signingInfo ?: return emptyList()
            if (signingInfo.hasMultipleSigners()) {
                signingInfo.apkContentsSigners
            } else {
                signingInfo.signingCertificateHistory
            }
        } else {
            info.signatures ?: return emptyList()
        }

        return signatures
            .map { signature ->
                MessageDigest
                    .getInstance("SHA-256")
                    .digest(signature.toByteArray())
                    .joinToString("") { byte ->
                        "%02x".format(byte.toInt() and 0xFF)
                    }
            }
            .distinct()
    }

    private fun canInstallPackages(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return true
        return applicationContext.packageManager.canRequestPackageInstalls()
    }

    private fun openInstallSettings() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val intent = Intent(
            Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
            Uri.parse("package:${applicationContext.packageName}"),
        ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }
}
