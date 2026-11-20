package nl.postlounge.launcher

import android.content.ComponentName
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Environment
import android.provider.Settings
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

data class ShortcutCandidate(
    val id: String,
    val title: String,
    val section: String,
    val builders: List<() -> Intent?>,
)

data class ResolvedShortcut(
    val id: String,
    val title: String,
    val section: String,
    val intent: Intent,
    val resolvedLabel: String,
)

object PostloungeSystemShortcuts {
    private val diagnosticKeywords = listOf(
        "settings",
        "picture",
        "projector",
        "keystone",
        "focus",
        "projection",
        "angle",
        "tv",
        "input",
        "source",
        "display",
        "acer",
        "aopen",
        "hdmi",
        "panel",
        "video",
        "factory",
        "mediatek",
        "siviton",
        "zeasn",
        "joyar",
        "whale",
        "autofocus",
    )

    private fun component(packageName: String, className: String): Intent? =
        Intent().setComponent(ComponentName(packageName, className))

    fun candidates(): List<ShortcutCandidate> = listOf(
        ShortcutCandidate(
            id = "zeasn_sources",
            title = "Bronnen · Sources",
            section = "input",
            builders = listOf(
                { component("com.zeasn.whale.open.launcher.technical", "com.zeasn.whale.open.launcher.technical.ui.SourcesActivity") },
                { Intent("com.android.tv.action.VIEW_INPUTS") },
                { Intent("android.media.tv.action.SHOW_TV_INPUT") },
                { component("com.android.tv", "com.android.tv.TvInputSelectorActivity") },
            ),
        ),
        ShortcutCandidate(
            id = "tv_input_picker",
            title = "TV-ingang kiezen · TV input",
            section = "input",
            builders = listOf(
                { Intent("com.android.tv.action.OPEN_INPUTS_PANEL") },
                { component("com.google.android.tv", "com.android.tv.TvInputSelectorActivity") },
            ),
        ),
        ShortcutCandidate(
            id = "zeasn_picture",
            title = "Beeld · Picture",
            section = "picture",
            builders = listOf(
                { component("com.zeasn.whale.open.launcher.technical", "com.zeasn.whale.open.launcher.technical.ui.BigPictureActivity") },
                { component("com.zeasn.whale.open.launcher.technical", "com.zeasn.whale.open.launcher.technical.ui.AdPictureActivity") },
            ),
        ),
        ShortcutCandidate(
            id = "oem_keystone",
            title = "Keystone / hoek · Angle",
            section = "picture",
            builders = listOf(
                { component("com.siviton.systemui", "com.joyar.settingslib.setup.projection.AngleActivity") },
            ),
        ),
        ShortcutCandidate(
            id = "oem_focus_manual",
            title = "Scherpstellen (handmatig) · Focus",
            section = "picture",
            builders = listOf(
                { component("com.siviton.autofocus", "com.siviton.autofocus.ui.ManualFocusActivity") },
            ),
        ),
        ShortcutCandidate(
            id = "oem_focus_auto",
            title = "Autofocus · Auto focus",
            section = "picture",
            builders = listOf(
                { component("com.siviton.autofocus", "com.siviton.autofocus.ui.AutoFocusActivity") },
            ),
        ),
        ShortcutCandidate(
            id = "tv_display",
            title = "Weergave · Display",
            section = "picture",
            builders = listOf(
                { component("com.android.tv.settings", "com.android.tv.settings.device.display.daydream.DaydreamActivity") },
                { Intent(Settings.ACTION_DISPLAY_SETTINGS) },
            ),
        ),
        ShortcutCandidate(
            id = "settings_wifi",
            title = "Wi‑Fi",
            section = "system",
            builders = listOf(
                { Intent(Settings.ACTION_WIFI_SETTINGS) },
                { component("com.android.tv.settings", "com.android.tv.settings.connectivity.setup.WifiSetupActivity") },
                { component("com.android.tv.settings", "com.android.tv.settings.connectivity.NetworkActivity") },
            ),
        ),
        ShortcutCandidate(
            id = "settings_bluetooth",
            title = "Bluetooth",
            section = "system",
            builders = listOf(
                { Intent(Settings.ACTION_BLUETOOTH_SETTINGS) },
                { component("com.android.tv.settings", "com.android.tv.settings.accessories.AccessoriesActivity") },
            ),
        ),
        ShortcutCandidate(
            id = "settings_sound",
            title = "Geluid · Sound",
            section = "system",
            builders = listOf(
                { component("com.android.tv.settings", "com.android.tv.settings.device.sound.SoundActivity") },
                { Intent(Settings.ACTION_SOUND_SETTINGS) },
            ),
        ),
        ShortcutCandidate(
            id = "settings_display",
            title = "Scherm · Display (Android)",
            section = "system",
            builders = listOf({ Intent(Settings.ACTION_DISPLAY_SETTINGS) }),
        ),
        ShortcutCandidate(
            id = "settings_android_tv",
            title = "Android TV-instellingen",
            section = "system",
            builders = listOf(
                { component("com.android.tv.settings", "com.android.tv.settings.MainSettings") },
                { packageManagerLaunch("com.android.tv.settings") },
            ),
        ),
        ShortcutCandidate(
            id = "settings_android",
            title = "Android-instellingen · Settings",
            section = "system",
            builders = listOf(
                { Intent(Settings.ACTION_SETTINGS) },
                { packageManagerLaunch("com.android.settings") },
            ),
        ),
    )

    private fun packageManagerLaunch(packageName: String): Intent? {
        val pm = PostloungeShortcutContext.packageManager ?: return null
        val intent = Intent(Intent.ACTION_MAIN)
            .addCategory(Intent.CATEGORY_LEANBACK_LAUNCHER)
            .setPackage(packageName)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        return if (pm.resolveActivity(intent, PackageManager.MATCH_DEFAULT_ONLY) != null) intent else null
    }

    fun resolveAll(pm: PackageManager): List<ResolvedShortcut> {
        val resolved = LinkedHashMap<String, ResolvedShortcut>()
        for (candidate in candidates()) {
            if (resolved.containsKey(candidate.id)) continue
            for (builder in candidate.builders) {
                val base = builder() ?: continue
                val intent = base.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                val info = try {
                    pm.resolveActivity(intent, PackageManager.MATCH_DEFAULT_ONLY)
                } catch (_: Exception) {
                    null
                } ?: continue
                val label = info.loadLabel(pm).toString()
                resolved[candidate.id] = ResolvedShortcut(
                    candidate.id,
                    candidate.title,
                    candidate.section,
                    intent,
                    label,
                )
                break
            }
        }
        return resolved.values.toList()
    }

    fun launch(pm: PackageManager, id: String): Boolean {
        val shortcut = resolveAll(pm).firstOrNull { it.id == id } ?: return false
        return try {
            PostloungeShortcutContext.activity?.startActivity(shortcut.intent) ?: return false
            true
        } catch (_: Exception) {
            false
        }
    }

    fun scanDiagnostic(pm: PackageManager): List<Map<String, String>> {
        val matches = LinkedHashSet<String>()
        val rows = mutableListOf<Map<String, String>>()

        fun addRow(packageName: String, activityName: String, label: String) {
            if (activityName.isBlank()) return
            if (activityName == packageName) return
            if (!activityName.startsWith("$packageName.")) return
            if (activityName.endsWith(".EmptyStubActivity")) return
            val key = "$packageName/$activityName"
            if (!matches.add(key)) return
            rows.add(
                mapOf(
                    "package" to packageName,
                    "activity" to activityName,
                    "label" to label,
                ),
            )
        }

        for (pkg in pm.getInstalledPackages(PackageManager.GET_ACTIVITIES)) {
            val packageName = pkg.packageName
            val packageHit = diagnosticKeywords.any { packageName.contains(it, ignoreCase = true) }
            val activities = pkg.activities ?: continue
            for (activity in activities) {
                val activityName = activity.name
                val activityHit = diagnosticKeywords.any { activityName.contains(it, ignoreCase = true) }
                if (!packageHit && !activityHit) continue
                val label = try {
                    activity.loadLabel(pm).toString()
                } catch (_: Exception) {
                    activityName
                }
                addRow(packageName, activityName, label)
            }
        }
        return rows.sortedWith(compareBy({ it["package"] }, { it["activity"] }))
    }

    fun exportDiagnostic(pm: PackageManager): String? {
        val rows = scanDiagnostic(pm)
        val timestamp = SimpleDateFormat("yyyy-MM-dd_HH-mm-ss", Locale.US).format(Date())
        val fileName = "postlounge-oem-discovery-$timestamp.txt"
        val header = buildString {
            appendLine("# Postlounge TV OEM discovery export")
            appendLine("# $timestamp")
            appendLine("# package\tactivity\tlabel")
            appendLine()
        }
        val body = rows.joinToString("\n") { row ->
            "${row["package"]}\t${row["activity"]}\t${row["label"]}"
        }
        val content = header + body + "\n"

        val candidates = mutableListOf<File>()
        @Suppress("DEPRECATION")
        val downloads = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
        candidates.add(File(downloads, fileName))
        PostloungeShortcutContext.activity?.getExternalFilesDir(null)?.let {
            candidates.add(File(it, fileName))
        }

        for (file in candidates) {
            try {
                file.parentFile?.mkdirs()
                file.writeText(content)
                return file.absolutePath
            } catch (_: Exception) {
                continue
            }
        }
        return null
    }
}

/** Holds Activity reference for shortcut launches without threading MainActivity everywhere. */
object PostloungeShortcutContext {
    var packageManager: PackageManager? = null
    var activity: MainActivity? = null
}