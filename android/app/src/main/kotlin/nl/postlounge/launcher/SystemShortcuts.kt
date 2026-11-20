package nl.postlounge.launcher

import android.content.ComponentName
import android.content.Intent
import android.content.pm.PackageManager
import android.provider.Settings

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
        "tv",
        "input",
        "display",
        "acer",
        "aopen",
        "hdmi",
        "panel",
        "video",
        "source",
    )

    fun candidates(): List<ShortcutCandidate> = listOf(
        ShortcutCandidate(
            id = "tv_input_picker",
            title = "TV input / source",
            section = "input",
            builders = listOf(
                { Intent("com.android.tv.action.VIEW_INPUTS") },
                { Intent("com.android.tv.action.OPEN_INPUTS_PANEL") },
                { Intent("android.media.tv.action.SHOW_TV_INPUT") },
                {
                    Intent().setComponent(
                        ComponentName("com.android.tv", "com.android.tv.TvInputSelectorActivity"),
                    )
                },
                {
                    Intent().setComponent(
                        ComponentName("com.google.android.tv", "com.android.tv.TvInputSelectorActivity"),
                    )
                },
                { Intent(Settings.ACTION_INPUT_METHOD_SETTINGS) },
            ),
        ),
        ShortcutCandidate(
            id = "oem_picture",
            title = "Projector picture / display",
            section = "picture",
            builders = listOf(
                { Intent().setComponent(ComponentName("com.acer.settings", "com.acer.settings.MainActivity")) },
                { Intent().setComponent(ComponentName("com.acer.settings", "com.acer.settings.PictureActivity")) },
                { Intent("com.acer.action.PICTURE_SETTINGS") },
                { Intent().setComponent(ComponentName("com.acer.photowizard", "com.acer.photowizard.MainActivity")) },
                { Intent().setComponent(ComponentName("com.acer.dashboard", "com.acer.dashboard.MainActivity")) },
                { Intent().setComponent(ComponentName("com.aopen.settings", "com.aopen.settings.MainActivity")) },
                { Intent().setComponent(ComponentName("com.softwinner.tvsetting", "com.softwinner.tvsetting.MainUI")) },
                { Intent().setComponent(ComponentName("com.softwinner.tvsetting", "com.softwinner.tvsetting.TvSettingUI")) },
                { Intent(Settings.ACTION_DISPLAY_SETTINGS) },
            ),
        ),
        ShortcutCandidate(
            id = "settings_wifi",
            title = "Wi‑Fi",
            section = "system",
            builders = listOf({ Intent(Settings.ACTION_WIFI_SETTINGS) }),
        ),
        ShortcutCandidate(
            id = "settings_bluetooth",
            title = "Bluetooth",
            section = "system",
            builders = listOf({ Intent(Settings.ACTION_BLUETOOTH_SETTINGS) }),
        ),
        ShortcutCandidate(
            id = "settings_sound",
            title = "Sound",
            section = "system",
            builders = listOf(
                { Intent(Settings.ACTION_SOUND_SETTINGS) },
                { Intent("android.settings.SOUND_SETTINGS") },
            ),
        ),
        ShortcutCandidate(
            id = "settings_display",
            title = "Display",
            section = "system",
            builders = listOf({ Intent(Settings.ACTION_DISPLAY_SETTINGS) }),
        ),
        ShortcutCandidate(
            id = "settings_android",
            title = "Android settings",
            section = "system",
            builders = listOf(
                { Intent(Settings.ACTION_SETTINGS) },
                { Intent().setComponent(ComponentName("com.android.tv.settings", "com.android.tv.settings.MainSettings")) },
                {
                    Intent().setComponent(
                        ComponentName("com.android.tv.settings", "com.android.tv.settings.system.FallbackHomeStub"),
                    )
                },
                { packageManagerLaunch("com.android.tv.settings") },
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
}

/** Holds Activity reference for shortcut launches without threading MainActivity everywhere. */
object PostloungeShortcutContext {
    var packageManager: PackageManager? = null
    var activity: MainActivity? = null
}