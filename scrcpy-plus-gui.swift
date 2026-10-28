import Cocoa
import SwiftUI
import UniformTypeIdentifiers
import Combine

// MARK: - Models

enum SidebarSection: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard & Profil"
    case virtualDesktop = "DeX Desktop Workspace"
    case videoCamera = "Video, Layar & Kamera"
    case audioRecord = "Audio & Perekaman"
    case inputWindow = "Input, HID & Jendela"
    case appManager = "Manajer Aplikasi"
    case remoteFiles = "Remote & Kirim File"
    case wireless = "Wi-Fi & Pairing ADB"
    case logsTools = "Log & Diagnostik"
    case howToAbout = "How-To & Info Developer"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .dashboard: return "sparkles.tv"
        case .virtualDesktop: return "macwindow.on.rectangle"
        case .videoCamera: return "video.badge.waveform"
        case .audioRecord: return "waveform.circle"
        case .inputWindow: return "keyboard.badge.eye"
        case .appManager: return "square.grid.2x2"
        case .remoteFiles: return "iphone.gen3.radiowaves.left.and.right"
        case .wireless: return "wifi.router"
        case .logsTools: return "terminal"
        case .howToAbout: return "book.pages.fill"
        }
    }
}

struct ProfilePreset: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let badge: String
}

let allProfiles: [ProfilePreset] = [
    ProfilePreset(id: "gaming", title: "Gaming", subtitle: "60 FPS, 20M bitrate, fullscreen & sentuhan aktif", icon: "gamecontroller.fill", badge: "60 FPS"),
    ProfilePreset(id: "desktop", title: "DeX Desktop Mode", subtitle: "Multi-window desktop ala Samsung DeX (buka banyak app sekaligus)", icon: "macwindow.on.rectangle", badge: "Multi-Window"),
    ProfilePreset(id: "productivity", title: "Productivity", subtitle: "Hemat daya, jaga HP menyala (-w), bitrate 8M", icon: "desktopcomputer", badge: "Kerja"),
    ProfilePreset(id: "studio", title: "Studio H.265", subtitle: "Visual tajam H.265 15M untuk konten & demo", icon: "film.stack.fill", badge: "H.265"),
    ProfilePreset(id: "recording", title: "Recording", subtitle: "Rekam layar & audio otomatis kualitas 30M", icon: "record.circle.fill", badge: "30M Rec"),
    ProfilePreset(id: "presentation", title: "Presentation", subtitle: "Fullscreen + indikator sentuhan untuk presentasi", icon: "person.and.background.dotted", badge: "Demo"),
    ProfilePreset(id: "private", title: "Private Screen", subtitle: "Layar fisik HP mati (-S), hanya tampil di Mac", icon: "eye.slash.fill", badge: "Layar Mati"),
    ProfilePreset(id: "camera", title: "Camera / Webcam", subtitle: "Mirror kamera HP langsung (Android 12+)", icon: "camera.aperture", badge: "Kamera"),
    ProfilePreset(id: "audio-only", title: "Audio Only", subtitle: "Streaming audio HP ke Mac tanpa jendela video", icon: "hifispeaker.2.fill", badge: "Audio"),
    ProfilePreset(id: "low-latency", title: "Low Latency", subtitle: "Ringan & responsif (1024px, 4M, 60 FPS) untuk Wi-Fi", icon: "bolt.horizontal.fill", badge: "Cepat"),
    ProfilePreset(id: "windowed", title: "Windowed", subtitle: "Jendela desktop standar 9M bitrate", icon: "macwindow", badge: "Jendela"),
    ProfilePreset(id: "debug", title: "Debug & FPS", subtitle: "Tampilkan sentuhan & pantau FPS di konsol", icon: "ladybug.fill", badge: "Dev"),
    ProfilePreset(id: "otg", title: "USB OTG", subtitle: "Keyboard & mouse fisik lewat USB tanpa video", icon: "cable.connector.horizontal", badge: "HID OTG"),
    ProfilePreset(id: "default", title: "Default", subtitle: "Pengaturan standar bawaan scrcpy", icon: "iphone", badge: "Standar")
]

struct VirtualDesktopPreset: Identifiable {
    let id: String
    let title: String
    let spec: String
    let winW: String
    let winH: String
    let subtitle: String
    let badge: String
    let isPortrait: Bool
}

let virtualDesktopPresets: [VirtualDesktopPreset] = [
    VirtualDesktopPreset(id: "fhd-160", title: "Landscape Full HD (16:9)", spec: "1920x1080/160", winW: "1280", winH: "720", subtitle: "Layar PC/Monitor Landscape penuh • Ruang kerja luas", badge: "Landscape 16:9", isPortrait: false),
    VirtualDesktopPreset(id: "dex-1280", title: "Landscape MacBook (16:10)", spec: "1280x800/180", winW: "1150", winH: "720", subtitle: "Proporsi ideal layar MacBook 16:10", badge: "Landscape 16:10", isPortrait: false),
    VirtualDesktopPreset(id: "ultrawide-21-9", title: "Landscape Ultrawide (21:9)", spec: "2560x1080/180", winW: "1440", winH: "610", subtitle: "Kanvas ekstra lebar untuk multitasking & split-screen", badge: "Ultrawide 21:9", isPortrait: false),
    VirtualDesktopPreset(id: "qhd-220", title: "Landscape QHD 2K (16:9)", spec: "2560x1440/220", winW: "1360", winH: "765", subtitle: "Resolusi tinggi 2K tajam untuk layar besar", badge: "Landscape 2K", isPortrait: false),
    VirtualDesktopPreset(id: "hd-140", title: "Landscape HD Ringan", spec: "1280x720/140", winW: "1024", winH: "576", subtitle: "Sangat ringan & hemat baterai untuk Wi-Fi", badge: "Landscape HD", isPortrait: false),
    VirtualDesktopPreset(id: "portrait-320", title: "Portrait Vertikal (9:16)", spec: "1080x1920/320", winW: "410", winH: "730", subtitle: "Mode layar berdiri (Portrait 9:16)", badge: "Portrait 9:16", isPortrait: true)
]

struct QuickAppShortcut: Identifiable {
    let id: String
    let title: String
    let query: String
    let icon: String
    let color: Color
    let preferPortrait: Bool
}

let virtualDesktopQuickApps: [QuickAppShortcut] = [
    QuickAppShortcut(id: "chrome", title: "Chrome", query: "+?chrome", icon: "globe", color: .blue, preferPortrait: false),
    QuickAppShortcut(id: "youtube", title: "YouTube", query: "+?youtube", icon: "play.rectangle.fill", color: .red, preferPortrait: false),
    QuickAppShortcut(id: "whatsapp", title: "WhatsApp", query: "+?whatsapp", icon: "message.fill", color: .green, preferPortrait: false),
    QuickAppShortcut(id: "telegram", title: "Telegram", query: "+?telegram", icon: "paperplane.fill", color: .cyan, preferPortrait: false),
    QuickAppShortcut(id: "instagram", title: "Instagram", query: "+?instagram", icon: "camera.circle.fill", color: .pink, preferPortrait: true),
    QuickAppShortcut(id: "facebook", title: "Facebook", query: "+?facebook", icon: "person.2.fill", color: .indigo, preferPortrait: false),
    QuickAppShortcut(id: "capcut", title: "CapCut", query: "+?capcut", icon: "scissors", color: .purple, preferPortrait: false),
    QuickAppShortcut(id: "files", title: "File Manager", query: "+?files", icon: "folder.fill", color: .orange, preferPortrait: false),
    QuickAppShortcut(id: "gmail", title: "Gmail", query: "+?gmail", icon: "envelope.fill", color: .red, preferPortrait: false),
    QuickAppShortcut(id: "maps", title: "Maps", query: "+?maps", icon: "map.fill", color: .green, preferPortrait: false),
    QuickAppShortcut(id: "spotify", title: "Musik / Spotify", query: "+?spotify", icon: "music.note", color: .mint, preferPortrait: false),
    QuickAppShortcut(id: "settings", title: "Settings HP", query: "+com.android.settings", icon: "gearshape.fill", color: .gray, preferPortrait: false)
]

struct RunningDeXApp: Identifiable, Hashable {
    var id: String { packageQuery }
    let appName: String
    let packageQuery: String
    let resolvedPackage: String
    let icon: String
}

struct DetachedDeXWindow: Identifiable {
    let id: UUID
    let title: String
    let packageQuery: String
    let isPiP: Bool
    let process: Process
}

struct DeXWorkspaceBundle: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let apps: [(name: String, query: String, icon: String)]
    let useFreeform: Bool
}

let dexWorkspaceBundles: [DeXWorkspaceBundle] = [
    DeXWorkspaceBundle(
        id: "work",
        title: "Paket Kerja & Browsing",
        subtitle: "Chrome + Gmail + File Manager (Landscape)",
        icon: "briefcase.fill",
        color: .blue,
        apps: [
            ("Chrome", "+?chrome", "globe"),
            ("Gmail", "+?gmail", "envelope.fill"),
            ("File Manager", "+?files", "folder.fill")
        ],
        useFreeform: false
    ),
    DeXWorkspaceBundle(
        id: "chat",
        title: "Paket Komunikasi Dual-Chat",
        subtitle: "WhatsApp + Telegram + Multi-App",
        icon: "bubble.left.and.bubble.right.fill",
        color: .green,
        apps: [
            ("WhatsApp", "+?whatsapp", "message.fill"),
            ("Telegram", "+?telegram", "paperplane.fill")
        ],
        useFreeform: true
    ),
    DeXWorkspaceBundle(
        id: "media",
        title: "Paket Hiburan & Musik",
        subtitle: "YouTube + Musik/Spotify di DeX",
        icon: "play.tv.fill",
        color: .red,
        apps: [
            ("YouTube", "+?youtube", "play.rectangle.fill"),
            ("Musik / Spotify", "+?spotify", "music.note")
        ],
        useFreeform: false
    ),
    DeXWorkspaceBundle(
        id: "creator",
        title: "Paket Kreator & Sosmed",
        subtitle: "CapCut + Instagram + Galeri/Files",
        icon: "sparkles.rectangle.stack.fill",
        color: .purple,
        apps: [
            ("CapCut", "+?capcut", "scissors"),
            ("Instagram", "+?instagram", "camera.circle.fill"),
            ("Files", "+?files", "folder.fill")
        ],
        useFreeform: true
    )
]

struct AndroidFileItem: Identifiable, Hashable {
    var id: String { fullPath }
    let name: String
    let fullPath: String
    let isDirectory: Bool
}

struct ConnectedDevice: Identifiable, Hashable {
    let serial: String
    let state: String
    let model: String
    let isWifi: Bool
    var id: String { serial }

    var displayName: String {
        if model.isEmpty {
            return "\(serial) (\(state))"
        }
        return "\(model) — \(serial)"
    }
}

struct DeviceTelemetry {
    var manufacturer: String = "-"
    var model: String = "-"
    var androidVersion: String = "-"
    var sdkVersion: String = "-"
    var batteryLevel: Int = 0
    var batteryTemp: String = "-"
    var ramUsage: String = "-"
    var screenSize: String = "-"
    var ipAddress: String = "-"
}

struct AndroidAppItem: Identifiable, Hashable {
    let packageName: String
    let appName: String
    let isSystem: Bool
    var id: String { packageName }

    var symbolName: String {
        let lower = (appName + " " + packageName).lowercased()
        if lower.contains("chrome") || lower.contains("browser") { return "globe" }
        if lower.contains("youtube") || lower.contains("video") { return "play.rectangle.fill" }
        if lower.contains("whatsapp") || lower.contains("chat") || lower.contains("message") { return "message.fill" }
        if lower.contains("telegram") { return "paperplane.fill" }
        if lower.contains("instagram") { return "camera.filters" }
        if lower.contains("facebook") { return "person.2.fill" }
        if lower.contains("capcut") || lower.contains("edit") { return "film.fill" }
        if lower.contains("bri") || lower.contains("bank") || lower.contains("dana") || lower.contains("ovo") || lower.contains("wallet") { return "creditcard.fill" }
        if lower.contains("camera") || lower.contains("kamera") { return "camera.fill" }
        if lower.contains("music") || lower.contains("spotify") || lower.contains("audio") { return "music.note" }
        if lower.contains("mail") || lower.contains("gmail") { return "envelope.fill" }
        if lower.contains("map") { return "map.fill" }
        if lower.contains("file") || lower.contains("document") { return "folder.fill" }
        if lower.contains("phone") || lower.contains("dialer") || lower.contains("call") { return "phone.fill" }
        if lower.contains("contact") { return "person.crop.circle.fill" }
        if lower.contains("setting") { return "gearshape.fill" }
        if lower.contains("calc") { return "plus.forwardslash.minus" }
        if lower.contains("calendar") { return "calendar" }
        if lower.contains("clock") || lower.contains("alarm") { return "clock.fill" }
        if lower.contains("photo") || lower.contains("gallery") { return "photo.fill" }
        if lower.contains("store") || lower.contains("vending") { return "bag.fill" }
        return isSystem ? "gearshape.2.fill" : "app.fill"
    }

    var accentColor: Color {
        let lower = (appName + " " + packageName).lowercased()
        if lower.contains("whatsapp") || lower.contains("phone") || lower.contains("map") { return .green }
        if lower.contains("youtube") || lower.contains("gmail") { return .red }
        if lower.contains("chrome") || lower.contains("facebook") || lower.contains("bri") { return .blue }
        if lower.contains("telegram") { return .cyan }
        if lower.contains("instagram") { return .pink }
        if lower.contains("capcut") { return .purple }
        if lower.contains("file") || lower.contains("photo") { return .orange }
        return isSystem ? .gray : .accentColor
    }
}

struct CustomUserPreset: Codable, Identifiable, Hashable {
    var id: String { name }
    var name: String
    var profile: String
    var bitrate: String
    var fps: String
    var maxSize: String
    var videoCodec: String
    var wireless: Bool
    var fullscreen: Bool
    var screenOff: Bool
    var audioDup: Bool
}

// MARK: - ViewModel / Controller

@MainActor
final class ScrcpyPlusViewModel: ObservableObject {
    @Published var selectedSection: SidebarSection = .dashboard

    // Devices & Telemetry
    @Published var devices: [ConnectedDevice] = []
    @Published var selectedSerial: String = ""
    @Published var telemetry = DeviceTelemetry()
    @Published var isRefreshingDevices: Bool = false

    // Session State
    @Published var isRunning: Bool = false
    @Published var statusMessage: String = "Siap menjalankan scrcpy"
    @Published var logText: String = "Selamat datang di scrcpy-plus v3 (SwiftUI + DeX Multi-Window Edition).\n"
    @Published var lastScreenshotImage: NSImage? = nil
    @Published var lastScreenshotPath: String = ""

    // Installed Apps & Hybrid Single/Multi-Window DeX State
    @Published var installedApps: [AndroidAppItem] = []
    @Published var isLoadingApps: Bool = false
    @Published var appSearchQuery: String = ""
    @Published var dexSearchQuery: String = ""
    @Published var showSystemApps: Bool = false
    @Published var showDeXStartMenu: Bool = false
    @Published var dexRunningApps: [RunningDeXApp] = []
    @Published var detachedDeXWindows: [DetachedDeXWindow] = []
    @Published var activeDeXAppPackage: String = ""
    @Published var activeDeXDisplayID: String = "auto"
    @Published var isDeXSessionRunning: Bool = false
    @Published var dexFreeformMode: Bool = false
    @Published var dexLiveDPI: Double = 160
    @Published var splitLeftAppQuery: String = "+?chrome"
    @Published var splitRightAppQuery: String = "+?whatsapp"
    private var dexOpenedPackages = Set<String>()
    private var floatingDeXTaskbarWindow: NSPanel? = nil
    private var floatingDeXStartMenuWindow: NSPanel? = nil

    // Android 2-Way File Browser & Clipboard History State
    @Published var currentAndroidDir: String = "/sdcard/Download"
    @Published var androidFiles: [AndroidFileItem] = []
    @Published var isLoadingFiles: Bool = false
    @Published var clipboardHistory: [String] = []
    @Published var savedWifiHosts: [String] = []
    @Published var discoveredLanDevices: [String] = []
    @Published var isScanningLan: Bool = false
    @Published var macLocalIP: String = "-"

    // Dedicated DeX Configuration (Separated so it never pollutes Camera/Gaming modes!)
    @AppStorage("dexDisplaySpec") var dexDisplaySpec: String = "1920x1080/160"
    @AppStorage("dexWindowWidth") var dexWindowWidth: String = "1280"
    @AppStorage("dexWindowHeight") var dexWindowHeight: String = "720"
    @AppStorage("dexOrientationMode") var dexOrientationMode: String = "landscape"
    @AppStorage("dexOpenInNewWindow") var dexOpenInNewWindow: Bool = false
    @AppStorage("dexForceStopOnStart") var dexForceStopOnStart: Bool = true
    @AppStorage("dexNoSystemDecorations") var dexNoSystemDecorations: Bool = true
    @AppStorage("dexKeepContentOnClose") var dexKeepContentOnClose: Bool = true
    @AppStorage("autoReconnectWifi") var autoReconnectWifi: Bool = true
    @AppStorage("autoRecoverSession") var autoRecoverSession: Bool = true

    // Persistent Configuration (@AppStorage)
    @AppStorage("profile") var profile: String = "gaming"
    @AppStorage("wireless") var wireless: Bool = false
    @AppStorage("fullscreen") var fullscreen: Bool = false
    @AppStorage("windowed") var windowed: Bool = false
    @AppStorage("screenOff") var screenOff: Bool = false
    @AppStorage("powerOffOnClose") var powerOffOnClose: Bool = false
    @AppStorage("showTouches") var showTouches: Bool = false
    @AppStorage("stayAwake") var stayAwake: Bool = false
    @AppStorage("noControl") var noControl: Bool = false
    @AppStorage("borderless") var borderless: Bool = false
    @AppStorage("alwaysOnTop") var alwaysOnTop: Bool = false
    @AppStorage("disableScreensaver") var disableScreensaver: Bool = false
    @AppStorage("audioDup") var audioDup: Bool = false
    @AppStorage("noAudio") var noAudio: Bool = false
    @AppStorage("noVideo") var noVideo: Bool = false
    @AppStorage("printFps") var printFps: Bool = false
    @AppStorage("recordEnabled") var recordEnabled: Bool = false

    // Window & Timers
    @AppStorage("windowTitle") var windowTitle: String = ""
    @AppStorage("startApp") var startApp: String = ""
    @AppStorage("timeLimit") var timeLimit: String = ""
    @AppStorage("screenOffTimeout") var screenOffTimeout: String = ""
    @AppStorage("windowX") var windowX: String = ""
    @AppStorage("windowY") var windowY: String = ""
    @AppStorage("windowWidth") var windowWidth: String = ""
    @AppStorage("windowHeight") var windowHeight: String = ""

    // Video, Display & Camera
    @AppStorage("videoCodec") var videoCodec: String = "default"
    @AppStorage("maxSize") var maxSize: String = "default"
    @AppStorage("renderDriver") var renderDriver: String = "default"
    @AppStorage("bitrate") var bitrate: String = ""
    @AppStorage("fps") var fps: String = ""
    @AppStorage("orientation") var orientation: String = "default"
    @AppStorage("captureOrientation") var captureOrientation: String = ""
    @AppStorage("angle") var angle: String = ""
    @AppStorage("videoBuffer") var videoBuffer: String = ""
    @AppStorage("crop") var crop: String = ""
    @AppStorage("displayId") var displayId: String = ""
    @AppStorage("displayImePolicy") var displayImePolicy: String = "default"

    // Camera
    @AppStorage("videoSource") var videoSource: String = "default"
    @AppStorage("cameraFacing") var cameraFacing: String = "default"
    @AppStorage("cameraId") var cameraId: String = ""
    @AppStorage("cameraSize") var cameraSize: String = ""
    @AppStorage("cameraAr") var cameraAr: String = ""
    @AppStorage("cameraFps") var cameraFps: String = ""
    @AppStorage("cameraHighSpeed") var cameraHighSpeed: Bool = false

    // Audio & Recording
    @AppStorage("audioSource") var audioSource: String = "default"
    @AppStorage("audioCodec") var audioCodec: String = "default"
    @AppStorage("audioBitrate") var audioBitrate: String = ""
    @AppStorage("audioBuffer") var audioBuffer: String = ""
    @AppStorage("audioOutputBuffer") var audioOutputBuffer: String = ""
    @AppStorage("requireAudio") var requireAudio: Bool = false
    @AppStorage("recordFormat") var recordFormat: String = "mp4"
    @AppStorage("noPlayback") var noPlayback: Bool = false
    @AppStorage("extraArgs") var extraArgs: String = ""

    // Input & Peripherals
    @AppStorage("keyboardMode") var keyboardMode: String = "default"
    @AppStorage("mouseMode") var mouseMode: String = "default"
    @AppStorage("gamepadMode") var gamepadMode: String = "default"
    @AppStorage("shortcutMod") var shortcutMod: String = "default"
    @AppStorage("otgMode") var otgMode: Bool = false
    @AppStorage("preferText") var preferText: Bool = false
    @AppStorage("rawKeyEvents") var rawKeyEvents: Bool = false
    @AppStorage("noKeyRepeat") var noKeyRepeat: Bool = false
    @AppStorage("legacyPaste") var legacyPaste: Bool = false
    @AppStorage("noClipboardSync") var noClipboardSync: Bool = false
    @AppStorage("noMouseHover") var noMouseHover: Bool = false

    // Wireless & Remote Input
    @AppStorage("tcpipAddress") var tcpipAddress: String = ""
    @Published var pairAddress: String = ""
    @Published var pairCode: String = ""
    @Published var remoteTextToSend: String = ""
    @Published var customPresetName: String = ""
    @Published var savedPresets: [CustomUserPreset] = []
    @Published var isDropTargeted: Bool = false

    private var scrcpyTask: Process?
    private var outputPipe: Pipe?
    private var userRequestedStop: Bool = false
    private var recoveryAttempts: Int = 0
    private var telemetryTimer: Timer? = nil

    var workspacePath: String {
        let bundleURL = Bundle.main.bundleURL
        let parent = bundleURL.deletingLastPathComponent().path
        if FileManager.default.isExecutableFile(atPath: (parent as NSString).appendingPathComponent("scrcpy-plus")) {
            return parent
        }
        return FileManager.default.currentDirectoryPath
    }

    var launcherPath: String {
        (workspacePath as NSString).appendingPathComponent("scrcpy-plus")
    }

    var adbPath: String {
        let bundled = (workspacePath as NSString).appendingPathComponent("adb")
        if FileManager.default.isExecutableFile(atPath: bundled) {
            return bundled
        }
        return "/usr/bin/env"
    }

    init() {
        // Clear any leftover displayImePolicy/windowWidth leakage from previous sessions
        if displayImePolicy == "hide" && profile != "desktop" {
            displayImePolicy = "default"
        }
        if windowWidth == "1280" && windowHeight == "720" {
            windowWidth = ""
            windowHeight = ""
        }
        loadCustomPresets()
        loadSavedHistoryAndHosts()
        refreshDevices()
        startLiveTelemetryMonitor()
        if autoReconnectWifi && !tcpipAddress.trimmingCharacters(in: .whitespaces).isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                if self.devices.isEmpty {
                    self.connectWifiIP()
                }
            }
        }
        NotificationCenter.default.addObserver(forName: NSApplication.willTerminateNotification, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in
                self?.stopScrcpy()
            }
        }
    }

    func startLiveTelemetryMonitor() {
        telemetryTimer?.invalidate()
        telemetryTimer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                if !self.devices.isEmpty {
                    self.fetchTelemetry()
                } else if self.autoReconnectWifi && !self.tcpipAddress.trimmingCharacters(in: .whitespaces).isEmpty {
                    self.connectWifiIP()
                }
            }
        }
    }

    func runSystemDoctor() {
        runUtilityCommand(["--doctor"], status: "Menjalankan System & ADB Doctor (Auto-Fix)...", switchToLogs: true)
    }

    func loadSavedHistoryAndHosts() {
        if let hosts = UserDefaults.standard.stringArray(forKey: "ScrcpyPlusSavedWifiHosts") {
            savedWifiHosts = hosts
        }
        if let clips = UserDefaults.standard.stringArray(forKey: "ScrcpyPlusClipboardHistory") {
            clipboardHistory = clips
        }
    }

    func saveWifiHost(_ host: String) {
        let trimmed = host.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        savedWifiHosts.removeAll { $0 == trimmed }
        savedWifiHosts.insert(trimmed, at: 0)
        if savedWifiHosts.count > 8 {
            savedWifiHosts = Array(savedWifiHosts.prefix(8))
        }
        UserDefaults.standard.set(savedWifiHosts, forKey: "ScrcpyPlusSavedWifiHosts")
    }

    func addClipboardHistory(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        clipboardHistory.removeAll { $0 == trimmed }
        clipboardHistory.insert(trimmed, at: 0)
        if clipboardHistory.count > 12 {
            clipboardHistory = Array(clipboardHistory.prefix(12))
        }
        UserDefaults.standard.set(clipboardHistory, forKey: "ScrcpyPlusClipboardHistory")
    }

    func appendLog(_ text: String) {
        guard !text.isEmpty else { return }
        logText += text
        if logText.count > 40000 {
            logText = String(logText.suffix(30000))
        }
    }

    // MARK: - Single-Window Samsung DeX Engine (Buka & Ganti Aplikasi di Dalam 1 Jendela DeX!)

    func applyDeXPreset(_ preset: VirtualDesktopPreset) {
        dexDisplaySpec = preset.spec
        dexWindowWidth = preset.winW
        dexWindowHeight = preset.winH
        if preset.isPortrait {
            dexOrientationMode = "portrait"
        } else if dexOrientationMode == "portrait" {
            dexOrientationMode = "landscape"
        }
        statusMessage = "Resolusi Jendela Tunggal DeX diatur ke \(preset.title) (\(preset.spec))"
    }

    /// Sets and locks DeX orientation (landscape, landscape-reverse, portrait, auto) both for config and live active DeX display!
    func setDeXOrientation(_ mode: String) {
        dexOrientationMode = mode
        if mode == "landscape" || mode == "landscape-reverse" {
            // Ensure spec & window dimensions are horizontal (W >= H)
            if dexDisplaySpec.hasPrefix("1080x1920") {
                dexDisplaySpec = "1920x1080/160"
                dexWindowWidth = "1280"
                dexWindowHeight = "720"
            }
        } else if mode == "portrait" {
            if !dexDisplaySpec.hasPrefix("1080x1920") {
                dexDisplaySpec = "1080x1920/320"
                dexWindowWidth = "410"
                dexWindowHeight = "730"
            }
        }

        if isDeXSessionRunning, let task = scrcpyTask, task.isRunning {
            applyLiveDeXRotation(mode)
        } else {
            let label = mode == "landscape" ? "Landscape (Horizontal 16:9)" : (mode == "portrait" ? "Portrait (Vertikal 9:16)" : mode.capitalized)
            statusMessage = "Mode Orientasi DeX diatur ke: \(label)"
        }
    }

    func toggleDeXLandscapePortrait() {
        let next = (dexOrientationMode == "landscape") ? "portrait" : "landscape"
        setDeXOrientation(next)
    }

    func applyLiveDeXDPI(_ dpi: Int) {
        dexLiveDPI = Double(dpi)
        // Update spec string DPI suffix as well
        let baseRes = dexDisplaySpec.components(separatedBy: "/").first ?? "1920x1080"
        dexDisplaySpec = "\(baseRes)/\(dpi)"

        guard isDeXSessionRunning else {
            statusMessage = "Skala DPI DeX disiapkan ke \(dpi) DPI (\(baseRes)/\(dpi))"
            return
        }
        let did = activeDeXDisplayID.isEmpty ? "auto" : activeDeXDisplayID
        var fullArgs: [String] = []
        if !selectedSerial.isEmpty {
            fullArgs.append(contentsOf: ["--serial", selectedSerial])
        }
        fullArgs.append(contentsOf: ["--display-dpi", did, "\(dpi)"])
        appendLog("\n[DeX Live DPI] $ ./scrcpy-plus \(fullArgs.joined(separator: " "))\n")

        let launcher = launcherPath
        let workspace = workspacePath
        Task.detached {
            let out = Self.runProcessCapture(executable: launcher, args: fullArgs, currentDir: workspace)
            await MainActor.run {
                if !out.isEmpty { self.appendLog(out + "\n") }
                self.statusMessage = "Live Zoom/DPI Jendela DeX diubah ke \(dpi) DPI"
            }
        }
    }

    /// Hybrid Multi-Window / Picture-in-Picture Spawner: Opens an app in its own separate independent window (or Always-on-Top PiP mini window)
    func spawnDetachedDeXWindow(appName: String, packageQuery: String, icon: String = "macwindow", isPiP: Bool = false) {
        guard FileManager.default.isExecutableFile(atPath: launcherPath) else { return }

        var startAppArg = packageQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if startAppArg.isEmpty {
            startAppArg = "+com.android.settings"
        } else if !startAppArg.hasPrefix("+") {
            startAppArg = "+" + startAppArg
        }

        let spec = isPiP ? "1280x720/180" : (dexDisplaySpec.isEmpty ? "1920x1080/160" : dexDisplaySpec)
        let winW = isPiP ? "440" : "1024"
        let winH = isPiP ? "250" : "640"

        var args: [String] = []
        if !selectedSerial.isEmpty {
            args.append(contentsOf: ["--serial", selectedSerial])
        }
        args.append(contentsOf: [
            "--new-display=\(spec)",
            "--start-app", startAppArg,
            "--no-vd-system-decorations",
            "--no-vd-destroy-content",
            "--display-ime-policy", "hide",
            "--window-width", winW,
            "--window-height", winH,
            "--title", isPiP ? "PiP • \(appName)" : "\(appName) — Jendela DeX Mandiri",
            "--bitrate", isPiP ? "8M" : "14M",
            "--fps", "60"
        ])
        if isPiP {
            args.append(contentsOf: ["--always-on-top", "--window-x", "40", "--window-y", "60"])
        }
        if dexOrientationMode == "landscape" {
            args.append(contentsOf: ["--capture-orientation", "@0"])
        }

        appendLog("\n[\(isPiP ? "PiP Window" : "Detached DeX Window")] $ ./scrcpy-plus \(args.joined(separator: " "))\n")

        let task = Process()
        task.executableURL = URL(fileURLWithPath: launcherPath)
        task.arguments = args
        task.currentDirectoryURL = URL(fileURLWithPath: workspacePath)

        let winID = UUID()
        task.terminationHandler = { [weak self] _ in
            Task { @MainActor in
                self?.detachedDeXWindows.removeAll { $0.id == winID }
            }
        }

        do {
            try task.run()
            detachedDeXWindows.append(DetachedDeXWindow(id: winID, title: appName, packageQuery: startAppArg, isPiP: isPiP, process: task))
            statusMessage = isPiP
                ? "Mode Picture-in-Picture (Always-on-Top) dibuka untuk '\(appName)'"
                : "Membuka '\(appName)' di Jendela Mandiri Baru"
        } catch {
            statusMessage = "Gagal membuka jendela mandiri: \(error.localizedDescription)"
        }
    }

    /// Starts a compact Always-on-Top Picture-in-Picture (PiP) mirror of the phone screen
    func startPiPMirror() {
        guard FileManager.default.isExecutableFile(atPath: launcherPath) else { return }
        var args: [String] = []
        if !selectedSerial.isEmpty {
            args.append(contentsOf: ["--serial", selectedSerial])
        }
        args.append(contentsOf: [
            "--always-on-top",
            "--window-width", "310",
            "--window-height", "660",
            "--window-x", "36",
            "--window-y", "60",
            "--title", "PiP Mirror — \(telemetry.model.isEmpty ? "Android" : telemetry.model)",
            "--bitrate", "8M",
            "--fps", "60"
        ])
        let task = Process()
        task.executableURL = URL(fileURLWithPath: launcherPath)
        task.arguments = args
        task.currentDirectoryURL = URL(fileURLWithPath: workspacePath)
        let winID = UUID()
        task.terminationHandler = { [weak self] _ in
            Task { @MainActor in
                self?.detachedDeXWindows.removeAll { $0.id == winID }
            }
        }
        do {
            try task.run()
            detachedDeXWindows.append(DetachedDeXWindow(id: winID, title: "PiP Layar HP", packageQuery: "mirror", isPiP: true, process: task))
            statusMessage = "Jendela PiP (Always-on-Top) aktif"
        } catch {
            statusMessage = "Gagal membuka PiP: \(error.localizedDescription)"
        }
    }

    /// 1-Click Workspace Macro: Launches a bundle of apps into the Single-Window DeX session!
    func launchDeXWorkspaceBundle(_ bundle: DeXWorkspaceBundle) {
        dexOrientationMode = "landscape"
        dexFreeformMode = bundle.useFreeform
        guard let first = bundle.apps.first else { return }
        launchDeXApp(appName: first.name, packageQuery: first.query, icon: first.icon)

        // Launch remaining apps in the bundle after the DeX display is ready
        for (idx, item) in bundle.apps.dropFirst().enumerated() {
            let delay = Double(idx + 1) * 1.4
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.launchDeXApp(appName: item.name, packageQuery: item.query, icon: item.icon)
            }
        }
        statusMessage = "Menjalankan Paket Workspace '\(bundle.title)' (\(bundle.apps.count) aplikasi)..."
    }

    /// Launches 2 chosen apps together in Freeform / Split-Screen inside the Landscape DeX window
    func launchSplitScreenDeX() {
        dexOrientationMode = "landscape"
        dexFreeformMode = true
        let leftPkg = resolvePackageIdentifier(splitLeftAppQuery)
        let rightPkg = resolvePackageIdentifier(splitRightAppQuery)
        launchDeXApp(appName: leftPkg, packageQuery: splitLeftAppQuery, icon: "rectangle.lefthalf.filled")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            self.launchDeXApp(appName: rightPkg, packageQuery: self.splitRightAppQuery, icon: "rectangle.righthalf.filled")
            self.statusMessage = "Split-Screen / Multi-App Freeform aktif: \(leftPkg) + \(rightPkg)"
        }
    }

    func applyLiveDeXRotation(_ modeOverride: String? = nil) {
        let mode = modeOverride ?? dexOrientationMode
        let did = activeDeXDisplayID.isEmpty ? "auto" : activeDeXDisplayID
        var fullArgs: [String] = []
        if !selectedSerial.isEmpty {
            fullArgs.append(contentsOf: ["--serial", selectedSerial])
        }
        fullArgs.append(contentsOf: ["--display-rotation", did, mode])
        appendLog("\n[DeX Orientation] $ ./scrcpy-plus \(fullArgs.joined(separator: " "))\n")

        let launcher = launcherPath
        let workspace = workspacePath
        Task.detached {
            let out = Self.runProcessCapture(executable: launcher, args: fullArgs, currentDir: workspace)
            await MainActor.run {
                if !out.isEmpty {
                    self.appendLog(out + "\n")
                }
                let label = mode == "landscape" ? "Landscape Terkunci" : (mode == "portrait" ? "Portrait" : mode.capitalized)
                self.statusMessage = "Orientasi Jendela DeX (Display #\(self.activeDeXDisplayID)): \(label)"
            }
        }
    }

    /// Resolves a shortcut query like "+?chrome" or "+com.whatsapp" into a clean package or keyword for `--launch-on-display`
    func resolvePackageIdentifier(_ rawQuery: String) -> String {
        var q = rawQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        while q.hasPrefix("+") || q.hasPrefix("?") {
            q.removeFirst()
        }
        guard !q.isEmpty else { return "com.android.settings" }
        if q.contains(".") {
            return q
        }
        // Try matching against installedApps first
        if let match = installedApps.first(where: {
            $0.packageName.localizedCaseInsensitiveContains(q) ||
            $0.appName.localizedCaseInsensitiveContains(q)
        }) {
            return match.packageName
        }
        return q
    }

    /// Parses `New display: 1920x1080/160 (id=7)` from scrcpy output so we know the exact virtual display ID
    private func parseVirtualDisplayID(from text: String) {
        guard let range = text.range(of: #"\(id=([0-9]+)\)"#, options: .regularExpression) else { return }
        let matched = String(text[range]) // "(id=7)"
        let digits = matched.filter { $0.isNumber }
        if !digits.isEmpty && digits != "0" {
            let changed = (activeDeXDisplayID != digits)
            activeDeXDisplayID = digits
            statusMessage = "DeX Display aktif (Display ID: \(digits), Mode: \(dexOrientationMode.capitalized))"
            if changed {
                applyLiveDeXRotation(dexOrientationMode)
            }
        }
    }

    /// Launches or switches an Android app INSIDE the single DeX virtual display window without opening a new macOS window!
    func launchDeXApp(appName: String, packageQuery: String, icon: String = "app.fill", preferPortrait: Bool = false, forceRestartApp: Bool = false) {
        guard FileManager.default.isExecutableFile(atPath: launcherPath) else {
            statusMessage = "Error: scrcpy-plus tidak ditemukan"
            return
        }

        let resolvedPkg = resolvePackageIdentifier(packageQuery)
        let appEntry = RunningDeXApp(
            appName: appName,
            packageQuery: resolvedPkg,
            resolvedPackage: resolvedPkg,
            icon: icon
        )

        // If Hybrid "Buka di Jendela Mandiri Baru" toggle is enabled, spawn an independent window!
        if dexOpenInNewWindow && isDeXSessionRunning {
            spawnDetachedDeXWindow(appName: appName, packageQuery: packageQuery, icon: icon, isPiP: false)
            return
        }

        // CASE 1: Single DeX Window is ALREADY running -> switch/launch app INSIDE that same DeX window!
        if isDeXSessionRunning, let task = scrcpyTask, task.isRunning {
            let targetDid = activeDeXDisplayID.isEmpty ? "auto" : activeDeXDisplayID
            let isFirstLaunchInDeX = !dexOpenedPackages.contains(resolvedPkg)
            let shouldForceStop = forceRestartApp || (dexForceStopOnStart && isFirstLaunchInDeX)

            var cmdArgs: [String] = []
            if !selectedSerial.isEmpty {
                cmdArgs.append(contentsOf: ["--serial", selectedSerial])
            }
            cmdArgs.append(contentsOf: ["--launch-on-display", targetDid, resolvedPkg])
            if dexFreeformMode {
                cmdArgs.append("--freeform")
            }
            if shouldForceStop {
                cmdArgs.append("--force-stop")
            }
            if dexOrientationMode == "landscape" || dexOrientationMode == "landscape-reverse" {
                cmdArgs.append("--landscape")
            }

            dexOpenedPackages.insert(resolvedPkg)
            activeDeXAppPackage = resolvedPkg
            if !dexRunningApps.contains(where: { $0.resolvedPackage == resolvedPkg }) {
                dexRunningApps.append(appEntry)
            }
            showDeXStartMenu = false
            floatingDeXStartMenuWindow?.orderOut(nil)
            statusMessage = "Membuka '\(appName)' di dalam jendela DeX (\(dexOrientationMode.capitalized))..."
            appendLog("\n[DeX In-Window Switch] $ ./scrcpy-plus \(cmdArgs.joined(separator: " "))\n")

            let launcher = launcherPath
            let workspace = workspacePath
            Task.detached {
                let out = Self.runProcessCapture(executable: launcher, args: cmdArgs, currentDir: workspace)
                await MainActor.run {
                    if !out.isEmpty {
                        self.appendLog(out + "\n")
                        // Also capture display ID if scrcpy-plus reported "display #X"
                        if let r = out.range(of: #"display #([0-9]+)"#, options: [.regularExpression, .caseInsensitive]) {
                            let d = String(out[r]).filter { $0.isNumber }
                            if !d.isEmpty { self.activeDeXDisplayID = d }
                        }
                    }
                    self.statusMessage = "Aktif di Jendela DeX (\(self.dexOrientationMode.capitalized)): \(appName)"
                }
            }
            return
        }

        // CASE 2: No DeX window is running yet -> Start the SINGLE DeX Virtual Display Window!
        if let existingTask = scrcpyTask, existingTask.isRunning {
            existingTask.terminate()
            scrcpyTask = nil
        }

        var spec = dexDisplaySpec.isEmpty ? "1920x1080/160" : dexDisplaySpec
        var winW = dexWindowWidth.isEmpty ? "1280" : dexWindowWidth
        var winH = dexWindowHeight.isEmpty ? "720" : dexWindowHeight

        // Guarantee landscape dimensions when dexOrientationMode is landscape!
        if dexOrientationMode == "landscape" || dexOrientationMode == "landscape-reverse" {
            if spec.hasPrefix("1080x1920") {
                spec = "1920x1080/160"
            }
            if let w = Int(winW), let h = Int(winH), w < h {
                winW = "1280"
                winH = "720"
            }
        } else if dexOrientationMode == "portrait" {
            if !spec.hasPrefix("1080x1920") {
                spec = "1080x1920/320"
                winW = "410"
                winH = "730"
            }
        }

        var startAppArg = packageQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if startAppArg.isEmpty {
            startAppArg = "+com.android.settings"
        } else if dexForceStopOnStart && !startAppArg.hasPrefix("+") {
            startAppArg = "+" + startAppArg
        }

        var args: [String] = []
        if !selectedSerial.isEmpty {
            args.append(contentsOf: ["--serial", selectedSerial])
        }
        args.append(contentsOf: [
            "--new-display=\(spec)",
            "--start-app", startAppArg,
            "--display-ime-policy", "hide",
            "--window-width", winW,
            "--window-height", winH,
            "--title", "Samsung DeX (\(dexOrientationMode.capitalized)) — \(telemetry.model.isEmpty ? "Android" : telemetry.model)",
            "--bitrate", bitrate.isEmpty ? "16M" : bitrate,
            "--fps", fps.isEmpty ? "60" : fps
        ])
        if dexOrientationMode == "landscape" {
            // Lock scrcpy virtual display capture to natural Landscape orientation (@0)
            args.append(contentsOf: ["--capture-orientation", "@0"])
        } else if dexOrientationMode == "landscape-reverse" {
            args.append(contentsOf: ["--capture-orientation", "@180"])
        }
        if dexNoSystemDecorations {
            args.append("--no-vd-system-decorations")
        }
        if dexKeepContentOnClose {
            args.append("--no-vd-destroy-content")
        }
        if noAudio {
            args.append("--no-audio")
        } else if audioDup {
            args.append("--audio-dup")
        }

        appendLog("\n[DeX Single Window] $ ./scrcpy-plus \(args.joined(separator: " "))\n")

        let task = Process()
        task.executableURL = URL(fileURLWithPath: launcherPath)
        task.arguments = args
        task.currentDirectoryURL = URL(fileURLWithPath: workspacePath)

        let pipe = Pipe()
        outputPipe = pipe
        task.standardOutput = pipe
        task.standardError = pipe

        pipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            guard !data.isEmpty, let str = String(data: data, encoding: .utf8) else { return }
            Task { @MainActor in
                self?.appendLog(str)
                self?.parseVirtualDisplayID(from: str)
            }
        }

        let wasUserStop = userRequestedStop
        userRequestedStop = false

        task.terminationHandler = { [weak self] finished in
            pipe.fileHandleForReading.readabilityHandler = nil
            let status = finished.terminationStatus
            Task { @MainActor in
                guard let self = self else { return }
                let stoppedByUser = self.userRequestedStop || wasUserStop
                self.isRunning = false
                self.isDeXSessionRunning = false
                self.scrcpyTask = nil
                self.activeDeXDisplayID = "auto"
                self.floatingDeXStartMenuWindow?.orderOut(nil)
                self.floatingDeXTaskbarWindow?.orderOut(nil)

                if status != 0 && !stoppedByUser && self.autoRecoverSession && self.recoveryAttempts < 3 {
                    self.recoveryAttempts += 1
                    self.statusMessage = "Koneksi DeX terputus (kode \(status)). Memulihkan otomatis (\(self.recoveryAttempts)/3)..."
                    self.appendLog("\n[Auto-Recovery Watchdog] Sesi DeX terputus tak terduga. Mencoba reconnect dalam 2 detik...\n")
                    let adb = self.adbPath
                    Task.detached {
                        let args = adb == "/usr/bin/env" ? ["adb", "reconnect", "offline"] : ["reconnect", "offline"]
                        _ = Self.runProcessCapture(executable: adb, args: args, timeoutSeconds: 4.0)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.launchDeXApp(appName: appName, packageQuery: packageQuery, icon: icon)
                    }
                } else {
                    self.recoveryAttempts = 0
                    self.statusMessage = "Jendela Samsung DeX ditutup"
                }
            }
        }

        do {
            try task.run()
            scrcpyTask = task
            isRunning = true
            isDeXSessionRunning = true
            activeDeXDisplayID = "auto"
            dexOpenedPackages = [resolvedPkg]
            activeDeXAppPackage = resolvedPkg
            dexRunningApps = [appEntry]
            statusMessage = "Jendela Tunggal DeX aktif (\(spec)) — Klik aplikasi lain untuk berganti di jendela yang sama"
            showFloatingDeXTaskbar()
        } catch {
            pipe.fileHandleForReading.readabilityHandler = nil
            statusMessage = "Gagal membuka jendela DeX: \(error.localizedDescription)"
        }
    }

    /// Starts the Single-Window DeX session (if not already running) and shows the floating DeX taskbar
    func startSingleWindowDeXSession() {
        if installedApps.isEmpty && !isLoadingApps {
            loadInstalledApps()
        }
        if isDeXSessionRunning, let task = scrcpyTask, task.isRunning {
            showFloatingDeXTaskbar()
            statusMessage = "Sesi DeX sudah aktif — pilih aplikasi di bawah atau dari DeX Taskbar"
            return
        }
        // Pick first user app or Chrome/Settings to initialize the clean single DeX window without phone home screen
        if let firstApp = installedApps.first(where: { $0.packageName.contains("chrome") }) ?? installedApps.first(where: { !$0.isSystem }) {
            launchDeXApp(appName: firstApp.appName, packageQuery: firstApp.packageName, icon: firstApp.symbolName)
        } else {
            launchDeXApp(appName: "Settings HP", packageQuery: "+com.android.settings", icon: "gearshape.fill")
        }
    }

    /// Sends a keyevent (Back=4, Recent=187, Home=3) directly to the DeX virtual display
    func sendDeXKeyevent(_ key: String, label: String) {
        let did = activeDeXDisplayID.isEmpty ? "auto" : activeDeXDisplayID
        var fullArgs: [String] = []
        if !selectedSerial.isEmpty {
            fullArgs.append(contentsOf: ["--serial", selectedSerial])
        }
        fullArgs.append(contentsOf: ["--display-keyevent", did, key])
        statusMessage = "DeX \(label) dikirim ke Display \(did)"
        let launcher = launcherPath
        let workspace = workspacePath
        Task.detached {
            _ = Self.runProcessCapture(executable: launcher, args: fullArgs, currentDir: workspace)
        }
    }

    func removeDeXAppFromTaskbar(_ app: RunningDeXApp) {
        dexRunningApps.removeAll { $0.id == app.id }
        dexOpenedPackages.remove(app.resolvedPackage)
        if activeDeXAppPackage == app.resolvedPackage, let last = dexRunningApps.last {
            launchDeXApp(appName: last.appName, packageQuery: last.resolvedPackage, icon: last.icon)
        }
    }

    func closeAllDeXWindows() {
        if isDeXSessionRunning, let task = scrcpyTask, task.isRunning {
            task.terminate()
        }
        for win in detachedDeXWindows where win.process.isRunning {
            win.process.terminate()
        }
        detachedDeXWindows.removeAll()
        isDeXSessionRunning = false
        dexRunningApps.removeAll()
        dexOpenedPackages.removeAll()
        activeDeXAppPackage = ""
        activeDeXDisplayID = "auto"
        showDeXStartMenu = false
        floatingDeXStartMenuWindow?.orderOut(nil)
        floatingDeXTaskbarWindow?.orderOut(nil)
        statusMessage = "Semua Sesi DeX & Jendela PiP dihentikan"
    }

    /// Shows a sleek floating Samsung DeX Dock/Taskbar at the bottom of the macOS screen so users can switch apps inside the single DeX window!
    func showFloatingDeXTaskbar() {
        if installedApps.isEmpty && !isLoadingApps {
            loadInstalledApps()
        }
        if floatingDeXTaskbarWindow == nil {
            let panel = NSPanel(
                contentRect: NSRect(x: 0, y: 0, width: 960, height: 56),
                styleMask: [.titled, .nonactivatingPanel, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            panel.titleVisibility = .hidden
            panel.titlebarAppearsTransparent = true
            panel.isFloatingPanel = true
            panel.level = .floating
            panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            panel.isMovableByWindowBackground = true
            panel.backgroundColor = .clear
            panel.isOpaque = false
            panel.hasShadow = true
            panel.isReleasedWhenClosed = false
            panel.contentView = NSHostingView(rootView: FloatingDeXTaskbarView(vm: self))
            if let screen = NSScreen.main {
                let frame = screen.visibleFrame
                let x = frame.midX - 480
                let y = frame.minY + 14
                panel.setFrameOrigin(NSPoint(x: x, y: y))
            }
            floatingDeXTaskbarWindow = panel
        }
        floatingDeXTaskbarWindow?.orderFront(nil)
    }

    func toggleFloatingDeXStartMenu() {
        showDeXStartMenu.toggle()
        if showDeXStartMenu {
            if floatingDeXStartMenuWindow == nil {
                let panel = NSPanel(
                    contentRect: NSRect(x: 0, y: 0, width: 680, height: 480),
                    styleMask: [.titled, .closable, .nonactivatingPanel, .fullSizeContentView],
                    backing: .buffered,
                    defer: false
                )
                panel.titleVisibility = .hidden
                panel.titlebarAppearsTransparent = true
                panel.isFloatingPanel = true
                panel.level = .floating
                panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
                panel.isMovableByWindowBackground = true
                panel.backgroundColor = .clear
                panel.isOpaque = false
                panel.hasShadow = true
                panel.isReleasedWhenClosed = false
                panel.contentView = NSHostingView(rootView: FloatingDeXStartMenuView(vm: self))
                floatingDeXStartMenuWindow = panel
            }
            if let dockFrame = floatingDeXTaskbarWindow?.frame {
                let x = dockFrame.minX
                let y = dockFrame.maxY + 10
                floatingDeXStartMenuWindow?.setFrameOrigin(NSPoint(x: x, y: y))
            } else if let screen = NSScreen.main {
                let frame = screen.visibleFrame
                floatingDeXStartMenuWindow?.setFrameOrigin(NSPoint(x: frame.midX - 340, y: frame.minY + 80))
            }
            floatingDeXStartMenuWindow?.makeKeyAndOrderFront(nil)
        } else {
            floatingDeXStartMenuWindow?.orderOut(nil)
        }
    }

    // MARK: - Presets Management

    func loadCustomPresets() {
        if let data = UserDefaults.standard.data(forKey: "ScrcpyPlusCustomPresetsV3"),
           let decoded = try? JSONDecoder().decode([CustomUserPreset].self, from: data) {
            savedPresets = decoded
        }
    }

    func saveCurrentAsCustomPreset() {
        let trimmed = customPresetName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let preset = CustomUserPreset(
            name: trimmed,
            profile: profile,
            bitrate: bitrate,
            fps: fps,
            maxSize: maxSize,
            videoCodec: videoCodec,
            wireless: wireless,
            fullscreen: fullscreen,
            screenOff: screenOff,
            audioDup: audioDup
        )
        savedPresets.removeAll { $0.name.lowercased() == trimmed.lowercased() }
        savedPresets.append(preset)
        if let data = try? JSONEncoder().encode(savedPresets) {
            UserDefaults.standard.set(data, forKey: "ScrcpyPlusCustomPresetsV3")
        }
        customPresetName = ""
        statusMessage = "Preset '\(trimmed)' disimpan"
    }

    func applyCustomPreset(_ preset: CustomUserPreset) {
        profile = preset.profile
        bitrate = preset.bitrate
        fps = preset.fps
        maxSize = preset.maxSize
        videoCodec = preset.videoCodec
        wireless = preset.wireless
        fullscreen = preset.fullscreen
        screenOff = preset.screenOff
        audioDup = preset.audioDup
        statusMessage = "Preset '\(preset.name)' diterapkan"
    }

    func deleteCustomPreset(_ preset: CustomUserPreset) {
        savedPresets.removeAll { $0.id == preset.id }
        if let data = try? JSONEncoder().encode(savedPresets) {
            UserDefaults.standard.set(data, forKey: "ScrcpyPlusCustomPresetsV3")
        }
    }

    func resetToDefaults() {
        profile = "gaming"
        wireless = false
        fullscreen = false
        windowed = false
        screenOff = false
        powerOffOnClose = false
        showTouches = false
        stayAwake = false
        noControl = false
        borderless = false
        alwaysOnTop = false
        disableScreensaver = false
        audioDup = false
        noAudio = false
        noVideo = false
        printFps = false
        recordEnabled = false
        windowTitle = ""
        startApp = ""
        timeLimit = ""
        screenOffTimeout = ""
        windowX = ""
        windowY = ""
        windowWidth = ""
        windowHeight = ""
        videoCodec = "default"
        maxSize = "default"
        renderDriver = "default"
        bitrate = ""
        fps = ""
        orientation = "default"
        captureOrientation = ""
        angle = ""
        videoBuffer = ""
        crop = ""
        displayId = ""
        displayImePolicy = "default"
        dexDisplaySpec = "1920x1080/160"
        dexWindowWidth = "1280"
        dexWindowHeight = "720"
        dexOrientationMode = "landscape"
        dexForceStopOnStart = true
        dexNoSystemDecorations = true
        dexKeepContentOnClose = true
        videoSource = "default"
        cameraFacing = "default"
        cameraId = ""
        cameraSize = ""
        cameraAr = ""
        cameraFps = ""
        cameraHighSpeed = false
        audioSource = "default"
        audioCodec = "default"
        audioBitrate = ""
        audioBuffer = ""
        audioOutputBuffer = ""
        requireAudio = false
        recordFormat = "mp4"
        noPlayback = false
        extraArgs = ""
        keyboardMode = "default"
        mouseMode = "default"
        gamepadMode = "default"
        shortcutMod = "default"
        otgMode = false
        preferText = false
        rawKeyEvents = false
        noKeyRepeat = false
        legacyPaste = false
        noClipboardSync = false
        noMouseHover = false
        statusMessage = "Semua pengaturan di-reset ke default"
    }

    // MARK: - Device Discovery & Telemetry

    func refreshDevices() {
        isRefreshingDevices = true
        let adb = adbPath
        Task.detached {
            let output = Self.runProcessCapture(executable: adb, args: adb == "/usr/bin/env" ? ["adb", "devices", "-l"] : ["devices", "-l"])
            var parsed: [ConnectedDevice] = []
            for line in output.components(separatedBy: .newlines) {
                let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.isEmpty || trimmed.hasPrefix("List of devices") || trimmed.hasPrefix("*") {
                    continue
                }
                let parts = trimmed.split(whereSeparator: { $0.isWhitespace }).map(String.init)
                if parts.count >= 2 {
                    let serial = parts[0]
                    let state = parts[1]
                    var model = ""
                    for token in parts where token.hasPrefix("model:") {
                        model = String(token.dropFirst(6)).replacingOccurrences(of: "_", with: " ")
                    }
                    let isWifi = serial.contains(":")
                    parsed.append(ConnectedDevice(serial: serial, state: state, model: model, isWifi: isWifi))
                }
            }
            let finalDevices = parsed
            await MainActor.run {
                self.devices = finalDevices
                self.isRefreshingDevices = false
                if !finalDevices.contains(where: { $0.serial == self.selectedSerial }) {
                    self.selectedSerial = finalDevices.first?.serial ?? ""
                }
                if !finalDevices.isEmpty {
                    self.statusMessage = "\(finalDevices.count) perangkat terhubung"
                    self.fetchTelemetry()
                    if self.installedApps.isEmpty {
                        self.loadInstalledApps()
                    }
                } else {
                    self.statusMessage = "Tidak ada perangkat ADB terdeteksi"
                    self.telemetry = DeviceTelemetry()
                }
            }
        }
    }

    func fetchTelemetry() {
        let serial = selectedSerial
        let adb = adbPath
        Task.detached {
            func adbCmd(_ cmdArgs: [String]) -> String {
                var full: [String] = []
                if adb == "/usr/bin/env" { full.append("adb") }
                if !serial.isEmpty { full.append(contentsOf: ["-s", serial]) }
                full.append(contentsOf: cmdArgs)
                return Self.runProcessCapture(executable: adb, args: full).trimmingCharacters(in: .whitespacesAndNewlines)
            }

            let state = adbCmd(["get-state"])
            guard state == "device" else { return }

            let manufacturer = adbCmd(["shell", "getprop", "ro.product.manufacturer"])
            let model = adbCmd(["shell", "getprop", "ro.product.model"])
            let androidVer = adbCmd(["shell", "getprop", "ro.build.version.release"])
            let sdkVer = adbCmd(["shell", "getprop", "ro.build.version.sdk"])
            let batteryDump = adbCmd(["shell", "dumpsys", "battery"])
            let wmSizeOut = adbCmd(["shell", "wm", "size"])
            let wlanAddrOut = adbCmd(["shell", "ip", "-f", "inet", "addr", "show", "wlan0"])
            let allInetOut = wlanAddrOut.contains("inet ") ? "" : adbCmd(["shell", "ip", "-f", "inet", "addr", "show"])
            let ipRouteWlanOut = adbCmd(["shell", "ip", "route", "show", "table", "wlan0"])
            let ipRouteOut = adbCmd(["shell", "ip", "route"])
            let memInfoOut = adbCmd(["shell", "cat", "/proc/meminfo"])

            var battery = 0
            var tempStr = "-"
            for line in batteryDump.components(separatedBy: .newlines) {
                if let range = line.range(of: "level:") {
                    let val = line[range.upperBound...].trimmingCharacters(in: .whitespaces)
                    battery = Int(val) ?? 0
                } else if let range = line.range(of: "temperature:") {
                    let val = line[range.upperBound...].trimmingCharacters(in: .whitespaces)
                    if let rawTemp = Double(val), rawTemp > 0 {
                        tempStr = String(format: "%.1f°C", rawTemp / 10.0)
                    }
                }
            }

            var ramStr = "-"
            var memTotalKB: Double = 0
            var memAvailKB: Double = 0
            for line in memInfoOut.components(separatedBy: .newlines) {
                if line.hasPrefix("MemTotal:") {
                    let digits = line.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                    memTotalKB = Double(digits) ?? 0
                } else if line.hasPrefix("MemAvailable:") {
                    let digits = line.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                    memAvailKB = Double(digits) ?? 0
                }
            }
            if memTotalKB > 0 && memAvailKB > 0 {
                let usedGB = (memTotalKB - memAvailKB) / 1048576.0
                let totalGB = memTotalKB / 1048576.0
                ramStr = String(format: "%.1f / %.1f GB", usedGB, totalGB)
            }

            var sizeStr = "-"
            for line in wmSizeOut.components(separatedBy: .newlines) {
                if let range = line.range(of: "Physical size:") {
                    sizeStr = line[range.upperBound...].trimmingCharacters(in: .whitespaces)
                    break
                }
            }

            func extractInetIP(from text: String) -> String? {
                for line in text.components(separatedBy: .newlines) {
                    let trimmed = line.trimmingCharacters(in: .whitespaces)
                    if trimmed.hasPrefix("inet ") {
                        let parts = trimmed.split(whereSeparator: { $0.isWhitespace }).map(String.init)
                        if parts.count >= 2 {
                            let ip = parts[1].components(separatedBy: "/").first ?? ""
                            if !ip.isEmpty && ip != "127.0.0.1" {
                                return ip
                            }
                        }
                    }
                }
                return nil
            }

            var ipStr = "-"
            // Stage 1: Direct wlan0 IPv4 address (Android 12-15 accurate even when Mobile Data is active)
            if let ip = extractInetIP(from: wlanAddrOut) {
                ipStr = ip
            }
            // Stage 2: Check wlan1 / ap0 / swlan0 / private LAN IPv4 (192.168.x.x / 172.16-31.x.x)
            if ipStr == "-", !allInetOut.isEmpty {
                for line in allInetOut.components(separatedBy: .newlines) {
                    let trimmed = line.trimmingCharacters(in: .whitespaces)
                    if trimmed.hasPrefix("inet 192.168.") || trimmed.hasPrefix("inet 172.") {
                        let parts = trimmed.split(whereSeparator: { $0.isWhitespace }).map(String.init)
                        if parts.count >= 2 {
                            ipStr = parts[1].components(separatedBy: "/").first ?? "-"
                            break
                        }
                    }
                }
            }
            // Stage 3: Per-interface routing table wlan0 (Android 13+ policy routing)
            if ipStr == "-" {
                let wlanTokens = ipRouteWlanOut.split(whereSeparator: { $0.isWhitespace }).map(String.init)
                if let idx = wlanTokens.firstIndex(of: "src"), idx + 1 < wlanTokens.count {
                    ipStr = wlanTokens[idx + 1]
                }
            }
            // Stage 4: Main routing table (prefer wlan lines first)
            if ipStr == "-" {
                for line in ipRouteOut.components(separatedBy: .newlines) where line.contains("wlan") {
                    let t = line.split(whereSeparator: { $0.isWhitespace }).map(String.init)
                    if let idx = t.firstIndex(of: "src"), idx + 1 < t.count {
                        ipStr = t[idx + 1]
                        break
                    }
                }
            }
            if ipStr == "-" {
                let tokens = ipRouteOut.split(whereSeparator: { $0.isWhitespace }).map(String.init)
                if let idx = tokens.firstIndex(of: "src"), idx + 1 < tokens.count {
                    ipStr = tokens[idx + 1]
                }
            }

            let info = DeviceTelemetry(
                manufacturer: manufacturer.isEmpty ? "-" : manufacturer.capitalized,
                model: model.isEmpty ? "-" : model,
                androidVersion: androidVer.isEmpty ? "-" : androidVer,
                sdkVersion: sdkVer.isEmpty ? "-" : sdkVer,
                batteryLevel: battery,
                batteryTemp: tempStr,
                ramUsage: ramStr,
                screenSize: sizeStr,
                ipAddress: ipStr
            )

            await MainActor.run {
                self.telemetry = info
                if info.ipAddress != "-" {
                    let current = self.tcpipAddress.trimmingCharacters(in: .whitespacesAndNewlines)
                    if current.isEmpty || current.hasPrefix("10.") || !current.hasPrefix(info.ipAddress) {
                        self.tcpipAddress = "\(info.ipAddress):5555"
                    }
                    self.savedWifiHosts.removeAll { $0.hasPrefix("10.150.") }
                }
            }
        }
    }

    // MARK: - App Manager Discovery

    func loadInstalledApps() {
        guard !isLoadingApps else { return }
        isLoadingApps = true
        let launcher = launcherPath
        let serial = selectedSerial
        let workspace = workspacePath

        Task.detached {
            var args: [String] = []
            if !serial.isEmpty { args.append(contentsOf: ["--serial", serial]) }
            args.append("--list-apps")
            let output = Self.runProcessCapture(executable: launcher, args: args, currentDir: workspace)
            var apps: [AndroidAppItem] = []
            for line in output.components(separatedBy: .newlines) {
                let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.hasPrefix("*") || trimmed.hasPrefix("-") {
                    let isSystem = trimmed.hasPrefix("-")
                    let body = trimmed.dropFirst().trimmingCharacters(in: .whitespaces)
                    let parts = body.split(whereSeparator: { $0.isWhitespace }).map(String.init)
                    if let pkg = parts.last, pkg.contains(".") {
                        let name = parts.dropLast().joined(separator: " ")
                        apps.append(AndroidAppItem(packageName: pkg, appName: name.isEmpty ? pkg : name, isSystem: isSystem))
                    }
                }
            }
            apps.sort { $0.appName.localizedCaseInsensitiveCompare($1.appName) == .orderedAscending }
            let finalApps = apps
            await MainActor.run {
                self.installedApps = finalApps
                self.isLoadingApps = false
            }
        }
    }

    var filteredApps: [AndroidAppItem] {
        installedApps.filter { app in
            if !showSystemApps && app.isSystem { return false }
            if appSearchQuery.isEmpty { return true }
            return app.appName.localizedCaseInsensitiveContains(appSearchQuery)
                || app.packageName.localizedCaseInsensitiveContains(appSearchQuery)
        }
    }

    var dexFilteredApps: [AndroidAppItem] {
        let userApps = installedApps.filter { !$0.isSystem || showSystemApps }
        if dexSearchQuery.isEmpty { return userApps }
        return userApps.filter {
            $0.appName.localizedCaseInsensitiveContains(dexSearchQuery)
            || $0.packageName.localizedCaseInsensitiveContains(dexSearchQuery)
        }
    }

    func launchSpecificApp(_ app: AndroidAppItem, inVirtualDisplay: Bool) {
        if inVirtualDisplay {
            launchDeXApp(appName: app.appName, packageQuery: app.packageName, icon: app.symbolName)
        } else {
            startApp = app.packageName
            if profile == "desktop" {
                profile = "default"
            }
            startScrcpy()
        }
    }

    // MARK: - Build Arguments & Start/Stop Main Mirror Session

    func buildArguments(recordPath: String? = nil) -> [String] {
        var args: [String] = []

        if !selectedSerial.isEmpty {
            args.append(contentsOf: ["--serial", selectedSerial])
        }

        let isCameraMode = (profile == "camera" || videoSource == "camera")
        let isOtgMode = (profile == "otg" || otgMode)
        let isAudioOnly = (profile == "audio-only" || noVideo)

        args.append(contentsOf: ["--profile", profile])

        if wireless { args.append("--wireless") }
        if fullscreen { args.append("--fullscreen") }
        if windowed { args.append("--windowed") }
        if screenOff && !isCameraMode && !isOtgMode { args.append("--screen-off") }
        if powerOffOnClose && !isCameraMode && !isOtgMode { args.append("--power-off-on-close") }
        if showTouches && !isCameraMode && !isOtgMode { args.append("--show-touches") }
        if stayAwake && !isCameraMode && !isOtgMode { args.append("--stay-awake") }
        if noControl { args.append("--no-control") }
        if borderless { args.append("--borderless") }
        if alwaysOnTop { args.append("--always-on-top") }
        if disableScreensaver { args.append("--disable-screensaver") }
        if audioDup { args.append("--audio-dup") }
        if noAudio { args.append("--no-audio") }
        if noVideo { args.append("--no-video") }
        if printFps { args.append("--print-fps") }

        // Window & Timers
        if !windowTitle.isEmpty { args.append(contentsOf: ["--title", windowTitle]) }
        if !startApp.isEmpty && !isCameraMode && !isOtgMode { args.append(contentsOf: ["--start-app", startApp]) }
        if !timeLimit.isEmpty { args.append(contentsOf: ["--time-limit", timeLimit]) }
        if !screenOffTimeout.isEmpty && !isCameraMode { args.append(contentsOf: ["--screen-off-timeout", screenOffTimeout]) }
        if !windowX.isEmpty { args.append(contentsOf: ["--window-x", windowX]) }
        if !windowY.isEmpty { args.append(contentsOf: ["--window-y", windowY]) }
        if !windowWidth.isEmpty { args.append(contentsOf: ["--window-width", windowWidth]) }
        if !windowHeight.isEmpty { args.append(contentsOf: ["--window-height", windowHeight]) }

        // Video & Display
        if videoCodec != "default" { args.append(contentsOf: ["--video-codec", videoCodec]) }
        if maxSize != "default" { args.append(contentsOf: ["--max-size", maxSize]) }
        if renderDriver != "default" { args.append(contentsOf: ["--render-driver", renderDriver]) }
        if !bitrate.isEmpty { args.append(contentsOf: ["--bitrate", bitrate]) }
        if !fps.isEmpty { args.append(contentsOf: ["--fps", fps]) }
        if orientation != "default" { args.append(contentsOf: ["--orientation", orientation]) }
        if !captureOrientation.isEmpty { args.append(contentsOf: ["--capture-orientation", captureOrientation]) }
        if !angle.isEmpty { args.append(contentsOf: ["--angle", angle]) }
        if !videoBuffer.isEmpty { args.append(contentsOf: ["--video-buffer", videoBuffer]) }

        // Display-only options (Never pass when videoSource == camera!)
        if !isCameraMode && !isOtgMode && !isAudioOnly {
            if !crop.isEmpty { args.append(contentsOf: ["--crop", crop]) }
            if !displayId.isEmpty { args.append(contentsOf: ["--display-id", displayId]) }
            if displayImePolicy != "default" { args.append(contentsOf: ["--display-ime-policy", displayImePolicy]) }
        }

        // Camera
        if videoSource != "default" { args.append(contentsOf: ["--video-source", videoSource]) }
        if isCameraMode {
            if cameraFacing != "default" { args.append(contentsOf: ["--camera-facing", cameraFacing]) }
            if !cameraId.isEmpty { args.append(contentsOf: ["--camera-id", cameraId]) }
            if !cameraSize.isEmpty { args.append(contentsOf: ["--camera-size", cameraSize]) }
            if !cameraAr.isEmpty { args.append(contentsOf: ["--camera-ar", cameraAr]) }
            if !cameraFps.isEmpty { args.append(contentsOf: ["--camera-fps", cameraFps]) }
            if cameraHighSpeed { args.append("--camera-high-speed") }
        }

        // Audio
        if audioSource != "default" { args.append(contentsOf: ["--audio-source", audioSource]) }
        if audioCodec != "default" { args.append(contentsOf: ["--audio-codec", audioCodec]) }
        if !audioBitrate.isEmpty { args.append(contentsOf: ["--audio-bitrate", audioBitrate]) }
        if !audioBuffer.isEmpty { args.append(contentsOf: ["--audio-buffer", audioBuffer]) }
        if !audioOutputBuffer.isEmpty { args.append(contentsOf: ["--audio-output-buffer", audioOutputBuffer]) }
        if requireAudio { args.append("--require-audio") }

        // Recording
        if let rec = recordPath, !rec.isEmpty {
            args.append(contentsOf: ["--record", rec])
        }
        if recordFormat != "mp4" && !recordFormat.isEmpty {
            args.append(contentsOf: ["--record-format", recordFormat])
        }
        if noPlayback { args.append("--no-playback") }

        // Input & Peripherals
        if keyboardMode != "default" { args.append(contentsOf: ["--keyboard", keyboardMode]) }
        if mouseMode != "default" { args.append(contentsOf: ["--mouse", mouseMode]) }
        if gamepadMode != "default" { args.append(contentsOf: ["--gamepad", gamepadMode]) }
        if shortcutMod != "default" { args.append(contentsOf: ["--shortcut-mod", shortcutMod]) }
        if otgMode { args.append("--otg") }
        if preferText { args.append("--prefer-text") }
        if rawKeyEvents { args.append("--raw-key-events") }
        if noKeyRepeat { args.append("--no-key-repeat") }
        if legacyPaste { args.append("--legacy-paste") }
        if noClipboardSync { args.append("--no-clipboard-autosync") }
        if noMouseHover { args.append("--no-mouse-hover") }

        // Extra raw flags
        let trimmedExtra = extraArgs.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedExtra.isEmpty {
            args.append("--")
            let parts = trimmedExtra.split(whereSeparator: { $0.isWhitespace }).map(String.init)
            args.append(contentsOf: parts)
        }

        return args
    }

    func startScrcpy() {
        // When profile is "desktop" (DeX Mode), launch the Single-Window DeX Session!
        if profile == "desktop" {
            selectedSection = .virtualDesktop
            if !startApp.trimmingCharacters(in: .whitespaces).isEmpty {
                launchDeXApp(appName: startApp, packageQuery: startApp, icon: "macwindow")
            } else {
                startSingleWindowDeXSession()
            }
            return
        }

        if isRunning {
            stopScrcpy()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.startScrcpy()
            }
            return
        }

        var chosenRecordPath: String? = nil
        if recordEnabled || profile == "recording" {
            let panel = NSSavePanel()
            let ext = recordFormat.isEmpty ? "mp4" : recordFormat
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd-HHmmss"
            panel.nameFieldStringValue = "scrcpy-\(formatter.string(from: Date())).\(ext)"
            if let utType = UTType(filenameExtension: ext) {
                panel.allowedContentTypes = [utType]
            }
            if panel.runModal() != .OK || panel.url == nil {
                statusMessage = "Perekaman dibatalkan"
                return
            }
            chosenRecordPath = panel.url?.path
        }

        guard FileManager.default.isExecutableFile(atPath: launcherPath) else {
            statusMessage = "Error: scrcpy-plus tidak ditemukan di \(launcherPath)"
            return
        }

        let arguments = buildArguments(recordPath: chosenRecordPath)
        appendLog("\n$ ./scrcpy-plus \(arguments.joined(separator: " "))\n")

        let logDir = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Logs/scrcpy-plus", isDirectory: true)
        try? FileManager.default.createDirectory(at: logDir, withIntermediateDirectories: true)
        let logFileURL = logDir.appendingPathComponent("gui-launch.log")
        if !FileManager.default.fileExists(atPath: logFileURL.path) {
            FileManager.default.createFile(atPath: logFileURL.path, contents: nil)
        }
        let fileHandle = try? FileHandle(forWritingTo: logFileURL)
        fileHandle?.seekToEndOfFile()

        let task = Process()
        task.executableURL = URL(fileURLWithPath: launcherPath)
        task.arguments = arguments
        task.currentDirectoryURL = URL(fileURLWithPath: workspacePath)

        let pipe = Pipe()
        outputPipe = pipe
        task.standardOutput = pipe
        task.standardError = pipe

        pipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            guard !data.isEmpty else { return }
            fileHandle?.write(data)
            if let str = String(data: data, encoding: .utf8) {
                Task { @MainActor in
                    self?.appendLog(str)
                }
            }
        }

        userRequestedStop = false

        task.terminationHandler = { [weak self] finished in
            pipe.fileHandleForReading.readabilityHandler = nil
            try? fileHandle?.close()
            let status = finished.terminationStatus
            Task { @MainActor in
                guard let self = self else { return }
                let stoppedByUser = self.userRequestedStop
                self.isRunning = false
                self.scrcpyTask = nil

                if status != 0 && !stoppedByUser && self.autoRecoverSession && self.recoveryAttempts < 3 {
                    self.recoveryAttempts += 1
                    self.statusMessage = "scrcpy terputus (kode \(status)). Auto-Reconnect (\(self.recoveryAttempts)/3)..."
                    self.appendLog("\n[Auto-Recovery Watchdog] scrcpy berhenti dengan kode \(status). Memulihkan koneksi ADB & sesi dalam 2 detik...\n")
                    let adb = self.adbPath
                    Task.detached {
                        let args = adb == "/usr/bin/env" ? ["adb", "reconnect", "offline"] : ["reconnect", "offline"]
                        _ = Self.runProcessCapture(executable: adb, args: args, timeoutSeconds: 4.0)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.startScrcpy()
                    }
                } else {
                    self.recoveryAttempts = 0
                    self.statusMessage = status == 0
                        ? "Sesi scrcpy selesai"
                        : "scrcpy berhenti (kode \(status)). Klik 'Doctor & Auto-Fix' untuk diagnostik."
                }
            }
        }

        do {
            try task.run()
            scrcpyTask = task
            isRunning = true
            statusMessage = "scrcpy aktif (\(profile))"
        } catch {
            pipe.fileHandleForReading.readabilityHandler = nil
            try? fileHandle?.close()
            statusMessage = "Gagal menjalankan scrcpy: \(error.localizedDescription)"
        }
    }

    func stopScrcpy() {
        userRequestedStop = true
        recoveryAttempts = 0
        if let task = scrcpyTask, task.isRunning {
            task.terminate()
        }
        closeAllDeXWindows()
        isRunning = false
        statusMessage = "Sesi dihentikan"
    }

    // MARK: - ADB & Utility Commands

    func runUtilityCommand(_ args: [String], status: String, switchToLogs: Bool = false) {
        if switchToLogs {
            selectedSection = .logsTools
        }
        statusMessage = status
        var fullArgs: [String] = []
        if !selectedSerial.isEmpty {
            fullArgs.append(contentsOf: ["--serial", selectedSerial])
        }
        fullArgs.append(contentsOf: args)
        let cmdLine = "\n$ ./scrcpy-plus \(fullArgs.joined(separator: " "))\n"
        appendLog(cmdLine)

        let launcher = launcherPath
        let workspace = workspacePath
        Task.detached {
            let out = Self.runProcessCapture(executable: launcher, args: fullArgs, currentDir: workspace)
            await MainActor.run {
                self.appendLog(out.isEmpty ? "(Selesai tanpa output)\n" : out + "\n")
                self.statusMessage = "Selesai: \(status)"
                self.refreshDevices()
            }
        }
    }

    func sendKeyevent(_ key: String, label: String) {
        runUtilityCommand(["--keyevent", key], status: "Tombol \(label)")
    }

    func sendRemoteText() {
        let text = remoteTextToSend.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        addClipboardHistory(text)
        runUtilityCommand(["--send-text", text], status: "Mengirim teks ke HP")
        remoteTextToSend = ""
    }

    func syncMacClipboardToPhone() {
        guard let str = NSPasteboard.general.string(forType: .string)?.trimmingCharacters(in: .whitespacesAndNewlines),
              !str.isEmpty else {
            statusMessage = "Clipboard Mac kosong"
            return
        }
        addClipboardHistory(str)
        runUtilityCommand(["--send-text", str], status: "Menempelkan isi Clipboard Mac ke HP")
    }

    func runQuickMacro(_ action: String) {
        switch action {
        case "wake_unlock":
            runUtilityCommand(["--keyevent", "224"], status: "Membangunkan layar HP...")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                self.runUtilityCommand(["--swipe", "540", "1900", "540", "500", "250"], status: "Membuka kunci layar (Swipe Up)")
            }
        case "scroll_down":
            runUtilityCommand(["--swipe", "540", "1700", "540", "600", "280"], status: "Scroll ke bawah")
        case "scroll_up":
            runUtilityCommand(["--swipe", "540", "600", "540", "1700", "280"], status: "Scroll ke atas")
        case "quick_settings":
            runUtilityCommand(["--keyevent", "83"], status: "Membuka panel notifikasi / Quick Settings")
        default:
            break
        }
    }

    func loadAndroidFiles(dir: String? = nil) {
        let targetDir = dir ?? currentAndroidDir
        currentAndroidDir = targetDir
        isLoadingFiles = true
        let launcher = launcherPath
        let serial = selectedSerial
        let workspace = workspacePath
        Task.detached {
            var args: [String] = []
            if !serial.isEmpty { args.append(contentsOf: ["--serial", serial]) }
            args.append(contentsOf: ["--list-files", targetDir])
            let out = Self.runProcessCapture(executable: launcher, args: args, currentDir: workspace)
            var items: [AndroidFileItem] = []
            for line in out.components(separatedBy: .newlines) {
                let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty && !trimmed.hasPrefix("Error:") else { continue }
                let isDir = trimmed.hasSuffix("/")
                let cleanName = isDir ? String(trimmed.dropLast()) : trimmed
                let full = (targetDir as NSString).appendingPathComponent(cleanName)
                items.append(AndroidFileItem(name: cleanName, fullPath: full, isDirectory: isDir))
            }
            let finalItems = items
            await MainActor.run {
                self.androidFiles = finalItems
                self.isLoadingFiles = false
                self.statusMessage = "Memuat \(finalItems.count) item dari \(targetDir)"
            }
        }
    }

    func pullAndroidFile(_ item: AndroidFileItem) {
        let downloads = NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .userDomainMask, true).first ?? NSHomeDirectory()
        statusMessage = "Mengunduh \(item.name) ke folder Downloads Mac..."
        let launcher = launcherPath
        let serial = selectedSerial
        let workspace = workspacePath
        Task.detached {
            var args: [String] = []
            if !serial.isEmpty { args.append(contentsOf: ["--serial", serial]) }
            args.append(contentsOf: ["--pull", item.fullPath, downloads])
            let out = Self.runProcessCapture(executable: launcher, args: args, currentDir: workspace)
            let localPath = (downloads as NSString).appendingPathComponent(item.name)
            await MainActor.run {
                self.appendLog("\n$ ./scrcpy-plus --pull \(item.fullPath) \(downloads)\n\(out)\n")
                self.statusMessage = "Berhasil diunduh ke Downloads: \(item.name)"
                NSWorkspace.shared.selectFile(localPath, inFileViewerRootedAtPath: "")
            }
        }
    }

    func takeInstantScreenshot(fromDeXDisplay: Bool = false) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        let prefix = (fromDeXDisplay || isDeXSessionRunning) ? "scrcpy-dex-shot" : "scrcpy-shot"
        let filename = "\(prefix)-\(formatter.string(from: Date())).png"
        let desktop = NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true).first ?? NSHomeDirectory()
        let fullPath = (desktop as NSString).appendingPathComponent(filename)
        let useDeX = fromDeXDisplay || isDeXSessionRunning
        let did = activeDeXDisplayID.isEmpty ? "auto" : activeDeXDisplayID
        statusMessage = useDeX ? "Mengambil screenshot Jendela DeX & menyalin ke Clipboard..." : "Mengambil screenshot HP & menyalin ke Clipboard..."

        let launcher = launcherPath
        let serial = selectedSerial
        let workspace = workspacePath
        Task.detached {
            var args: [String] = []
            if !serial.isEmpty { args.append(contentsOf: ["--serial", serial]) }
            if useDeX {
                args.append(contentsOf: ["--screenshot-display", did, fullPath])
            } else {
                args.append(contentsOf: ["--screenshot", fullPath])
            }
            let out = Self.runProcessCapture(executable: launcher, args: args, currentDir: workspace)
            let img = NSImage(contentsOfFile: fullPath)
            await MainActor.run {
                self.appendLog(out + "\n")
                if let img = img {
                    self.lastScreenshotImage = img
                    self.lastScreenshotPath = fullPath
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.writeObjects([img])
                    self.statusMessage = "Screenshot tersimpan di Desktop & disalin ke Clipboard Mac (Cmd+V): \(filename)"
                } else {
                    self.statusMessage = "Gagal mengambil screenshot"
                }
            }
        }
    }

    func promptInstallAPK() {
        let panel = NSOpenPanel()
        if let apkType = UTType(filenameExtension: "apk") {
            panel.allowedContentTypes = [apkType]
        }
        panel.allowsMultipleSelection = false
        panel.message = "Pilih file APK untuk di-install ke perangkat Android"
        if panel.runModal() == .OK, let url = panel.url {
            runUtilityCommand(["--install-apk", url.path], status: "Meng-install \(url.lastPathComponent)...", switchToLogs: true)
        }
    }

    func promptPushFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.message = "Pilih file untuk dikirim ke \(currentAndroidDir)"
        if panel.runModal() == .OK, let url = panel.url {
            runUtilityCommand(["--push", url.path, currentAndroidDir + "/"], status: "Mengirim \(url.lastPathComponent) ke \(currentAndroidDir)/...", switchToLogs: true)
        }
    }

    func handleDroppedFiles(_ urls: [URL]) {
        for url in urls {
            if url.pathExtension.lowercased() == "apk" {
                runUtilityCommand(["--install-apk", url.path], status: "Meng-install APK \(url.lastPathComponent)...", switchToLogs: false)
            } else {
                runUtilityCommand(["--push", url.path, currentAndroidDir + "/"], status: "Mengirim \(url.lastPathComponent) ke \(currentAndroidDir)/...", switchToLogs: false)
            }
        }
    }

    func connectWifiIP() {
        let addr = tcpipAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !addr.isEmpty else { return }
        saveWifiHost(addr)
        let adb = adbPath
        let serial = selectedSerial
        let macIP = macLocalIP
        statusMessage = "Menghubungkan ke \(addr)..."
        Task.detached {
            let hostIP = addr.components(separatedBy: ":").first ?? addr
            // 1. Warm up ARP from both sides (Android -> Mac if USB attached, and Mac -> Android)
            if !macIP.isEmpty && macIP != "-" {
                var usbArgs: [String] = []
                if adb == "/usr/bin/env" { usbArgs.append("adb") }
                if !serial.isEmpty && !serial.contains(":") {
                    usbArgs.append(contentsOf: ["-s", serial])
                } else {
                    usbArgs.append("-d")
                }
                usbArgs.append(contentsOf: ["shell", "ping", "-c", "2", "-W", "1", macIP])
                _ = Self.runProcessCapture(executable: adb, args: usbArgs, timeoutSeconds: 3.0)
            }
            _ = Self.runProcessCapture(executable: "/sbin/ping", args: ["-c", "1", "-t", "1", hostIP], timeoutSeconds: 2.0)

            let args = adb == "/usr/bin/env" ? ["adb", "connect", addr] : ["connect", addr]
            var out = Self.runProcessCapture(executable: adb, args: args)

            // 2. Self-heal macOS Sequoia 'No route to host' / stale ADB daemon NECP permission issue
            if out.contains("No route to host") || out.contains("cannot connect") || out.contains("failed to connect") {
                let killArgs = adb == "/usr/bin/env" ? ["adb", "kill-server"] : ["kill-server"]
                _ = Self.runProcessCapture(executable: adb, args: killArgs, timeoutSeconds: 3.0)
                _ = Self.runProcessCapture(executable: "/sbin/ping", args: ["-c", "1", "-t", "1", hostIP], timeoutSeconds: 2.0)
                out = Self.runProcessCapture(executable: adb, args: args, timeoutSeconds: 6.0)
            }

            let finalOut = out
            await MainActor.run {
                self.appendLog("\n$ adb connect \(addr)\n\(finalOut)\n")
                self.statusMessage = finalOut.trimmingCharacters(in: .whitespacesAndNewlines)
                self.refreshDevices()
            }
        }
    }

    func bridgeUsbToWifi() {
        let initialIP = telemetry.ipAddress
        let adb = adbPath
        let serial = selectedSerial
        let launcher = launcherPath
        let workspace = workspacePath
        statusMessage = "Mendeteksi IP Wi-Fi (wlan0) & mengaktifkan TCP/IP port 5555..."
        Task.detached {
            var base: [String] = []
            if adb == "/usr/bin/env" { base.append("adb") }
            if !serial.isEmpty && !serial.contains(":") {
                base.append(contentsOf: ["-s", serial])
            } else {
                base.append("-d")
            }

            let macIP = Self.runProcessCapture(executable: "/usr/sbin/ipconfig", args: ["getifaddr", "en0"], timeoutSeconds: 2.0).trimmingCharacters(in: .whitespacesAndNewlines)

            var ip = initialIP
            if ip == "-" || ip.isEmpty || ip.hasPrefix("10.") {
                let wlanOut = Self.runProcessCapture(executable: adb, args: base + ["shell", "ip", "-f", "inet", "addr", "show", "wlan0"])
                for line in wlanOut.components(separatedBy: .newlines) {
                    let trimmed = line.trimmingCharacters(in: .whitespaces)
                    if trimmed.hasPrefix("inet ") {
                        let parts = trimmed.split(whereSeparator: { $0.isWhitespace }).map(String.init)
                        if parts.count >= 2 {
                            ip = parts[1].components(separatedBy: "/").first ?? "-"
                            break
                        }
                    }
                }
            }

            // Warm up reverse ARP from Android phone to Mac so hotspot/router populates ARP immediately!
            if !macIP.isEmpty {
                _ = Self.runProcessCapture(executable: adb, args: base + ["shell", "ping", "-c", "2", "-W", "1", macIP], timeoutSeconds: 3.0)
            }

            _ = Self.runProcessCapture(executable: adb, args: base + ["tcpip", "5555"])
            try? await Task.sleep(nanoseconds: 1_100_000_000)

            if !macIP.isEmpty {
                _ = Self.runProcessCapture(executable: adb, args: base + ["shell", "ping", "-c", "1", "-W", "1", macIP], timeoutSeconds: 2.0)
            }

            var connOut = "Port 5555 aktif. Pastikan HP & Mac terhubung ke Wi-Fi yang sama."
            if ip != "-" && !ip.isEmpty {
                _ = Self.runProcessCapture(executable: "/sbin/ping", args: ["-c", "1", "-t", "1", ip], timeoutSeconds: 2.0)
                let target = "\(ip):5555"
                let connArgs = adb == "/usr/bin/env" ? ["adb", "connect", target] : ["connect", target]
                connOut = Self.runProcessCapture(executable: adb, args: connArgs)
                if connOut.contains("No route to host") || connOut.contains("failed to connect") {
                    let killArgs = adb == "/usr/bin/env" ? ["adb", "kill-server"] : ["kill-server"]
                    _ = Self.runProcessCapture(executable: adb, args: killArgs, timeoutSeconds: 3.0)
                    connOut = Self.runProcessCapture(executable: adb, args: connArgs, timeoutSeconds: 6.0)
                }
            } else {
                // Also run --scan-wifi to check if device appeared on LAN
                let scanOut = Self.runProcessCapture(executable: launcher, args: ["--scan-wifi"], currentDir: workspace)
                for line in scanOut.components(separatedBy: .newlines) where line.hasPrefix("FOUND:") {
                    let raw = line.replacingOccurrences(of: "FOUND:", with: "")
                    let hostPart = raw.split(whereSeparator: { $0.isWhitespace }).first.map(String.init) ?? ""
                    if !hostPart.isEmpty {
                        ip = hostPart.components(separatedBy: ":").first ?? "-"
                        let connArgs = adb == "/usr/bin/env" ? ["adb", "connect", hostPart] : ["connect", hostPart]
                        connOut = Self.runProcessCapture(executable: adb, args: connArgs)
                        break
                    }
                }
            }
            let finalIP = ip
            let finalOut = connOut
            await MainActor.run {
                if finalIP != "-" && !finalIP.isEmpty {
                    self.tcpipAddress = "\(finalIP):5555"
                    self.saveWifiHost("\(finalIP):5555")
                }
                self.appendLog("\n\(finalOut)\n")
                self.statusMessage = finalOut.trimmingCharacters(in: .whitespacesAndNewlines)
                self.refreshDevices()
            }
        }
    }

    func scanLocalWifiDevices() {
        guard !isScanningLan else { return }
        isScanningLan = true
        statusMessage = "Memindai jaringan Wi-Fi lokal (mDNS, wlan0, ARP & Port 5555)..."
        let launcher = launcherPath
        let workspace = workspacePath
        Task.detached {
            let out = Self.runProcessCapture(executable: launcher, args: ["--scan-wifi"], currentDir: workspace, timeoutSeconds: 10.0)
            var found: [String] = []
            var macIP = "-"
            for line in out.components(separatedBy: .newlines) {
                let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.hasPrefix("MAC_IP:") {
                    macIP = trimmed.replacingOccurrences(of: "MAC_IP:", with: "")
                } else if trimmed.hasPrefix("FOUND:") {
                    let item = trimmed.replacingOccurrences(of: "FOUND:", with: "")
                    if !found.contains(item) {
                        found.append(item)
                    }
                }
            }
            let finalFound = found
            let finalMacIP = macIP
            await MainActor.run {
                self.macLocalIP = finalMacIP
                self.discoveredLanDevices = finalFound
                self.isScanningLan = false
                if let first = finalFound.first {
                    let hostOnly = first.split(whereSeparator: { $0.isWhitespace }).first.map(String.init) ?? ""
                    if self.tcpipAddress.isEmpty && !hostOnly.isEmpty {
                        self.tcpipAddress = hostOnly
                    }
                    self.statusMessage = "Ditemukan \(finalFound.count) perangkat Android di jaringan Wi-Fi lokal!"
                } else {
                    self.statusMessage = "Tidak ditemukan port 5555/mDNS aktif di LAN (\(finalMacIP)). Sambungkan USB sekali lalu klik 'Auto USB → Wi-Fi'."
                }
            }
        }
    }

    func pairDevice() {
        let addr = pairAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        let code = pairCode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !addr.isEmpty && !code.isEmpty else { return }
        runUtilityCommand(["--pair", addr, code], status: "Pairing dengan \(addr)...", switchToLogs: true)
    }

    func disconnectAllWifi() {
        runUtilityCommand(["--disconnect"], status: "Memutuskan koneksi Wi-Fi ADB")
    }

    nonisolated static func runProcessCapture(executable: String, args: [String], currentDir: String? = nil, timeoutSeconds: Double = 8.0) -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = args
        if let dir = currentDir {
            process.currentDirectoryURL = URL(fileURLWithPath: dir)
        }
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        do {
            try process.run()
            DispatchQueue.global().asyncAfter(deadline: .now() + timeoutSeconds) {
                if process.isRunning {
                    process.terminate()
                }
            }
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            process.waitUntilExit()
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            return "Error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Main SwiftUI Views

struct MainWindowView: View {
    @ObservedObject var vm: ScrcpyPlusViewModel

    var body: some View {
        NavigationSplitView {
            List(SidebarSection.allCases, selection: $vm.selectedSection) { section in
                Label(section.rawValue, systemImage: section.icon)
                    .font(.system(size: 13, weight: .medium))
                    .padding(.vertical, 3)
                    .tag(section)
            }
            .listStyle(.sidebar)
            .navigationSplitViewColumnWidth(min: 215, ideal: 225, max: 245)
        } detail: {
            VStack(spacing: 0) {
                TopHeaderBar(vm: vm)
                Divider()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        switch vm.selectedSection {
                        case .dashboard:
                            DashboardSectionView(vm: vm)
                        case .virtualDesktop:
                            VirtualDesktopSectionView(vm: vm)
                        case .videoCamera:
                            VideoCameraSectionView(vm: vm)
                        case .audioRecord:
                            AudioRecordSectionView(vm: vm)
                        case .inputWindow:
                            InputWindowSectionView(vm: vm)
                        case .appManager:
                            AppManagerSectionView(vm: vm)
                        case .remoteFiles:
                            RemoteFilesSectionView(vm: vm)
                        case .wireless:
                            WirelessSectionView(vm: vm)
                        case .logsTools:
                            LogsToolsSectionView(vm: vm)
                        case .howToAbout:
                            HowToAboutSectionView(vm: vm)
                        }
                    }
                    .padding(20)
                }
                Divider()
                BottomControlBar(vm: vm)
            }
        }
        .frame(minWidth: 980, minHeight: 700)
    }
}

// MARK: - Top Header Bar

struct TopHeaderBar: View {
    @ObservedObject var vm: ScrcpyPlusViewModel

    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: (vm.isRunning || vm.isDeXSessionRunning) ? "dot.radiowaves.left.and.right" : "iphone.gen3")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle((vm.isRunning || vm.isDeXSessionRunning) ? .green : .accentColor)
                VStack(alignment: .leading, spacing: 1) {
                    Text("scrcpy-plus")
                        .font(.system(size: 15, weight: .bold))
                    Text(vm.isDeXSessionRunning ? "Samsung DeX Aktif (Display #\(vm.activeDeXDisplayID))" : (vm.isRunning ? "Sesi Aktif • \(vm.profile.capitalized)" : "Control Center v3"))
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            HStack(spacing: 6) {
                Image(systemName: "cable.connector")
                    .foregroundStyle(.secondary)
                Picker("Perangkat", selection: $vm.selectedSerial) {
                    Text("Otomatis (Semua)").tag("")
                    ForEach(vm.devices) { dev in
                        Text(dev.displayName).tag(dev.serial)
                    }
                }
                .labelsHidden()
                .frame(width: 230)
                .onChange(of: vm.selectedSerial) { _, _ in
                    vm.fetchTelemetry()
                }

                Button {
                    vm.refreshDevices()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .help("Muat ulang perangkat ADB")
            }

            Divider().frame(height: 20)

            Button {
                vm.selectedSection = .virtualDesktop
                vm.startSingleWindowDeXSession()
            } label: {
                Label(vm.isDeXSessionRunning ? "Tampilkan DeX Taskbar" : "Start DeX (1 Jendela)", systemImage: "macwindow.on.rectangle")
            }
            .help("Jalankan mode Samsung DeX di dalam 1 jendela tunggal beserta Floating DeX Taskbar")

            Button {
                vm.startPiPMirror()
            } label: {
                Label("Mode PiP", systemImage: "pip.enter")
            }
            .help("Buka jendela kecil mengambang (Picture-in-Picture Always-on-Top)")

            Button {
                vm.takeInstantScreenshot(fromDeXDisplay: vm.isDeXSessionRunning)
            } label: {
                Label("Screenshot", systemImage: "camera.viewfinder")
            }
            .help("Simpan screenshot ke Desktop & salin otomatis ke Clipboard Mac (Cmd+V)")

            Button {
                vm.runSystemDoctor()
            } label: {
                Label("Doctor", systemImage: "stethoscope")
            }
            .help("System & ADB Doctor: Cek kesehatan sistem & perbaiki perangkat ADB offline otomatis")

            Button {
                vm.selectedSection = .howToAbout
            } label: {
                Label("How-To", systemImage: "questionmark.circle.fill")
            }
            .help("Buka Panduan Penggunaan (How-To) & Informasi Developer")

            Button {
                vm.resetToDefaults()
            } label: {
                Image(systemName: "arrow.counterclockwise")
            }
            .help("Reset ke pengaturan awal")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.bar)
    }
}

// MARK: - Bottom Control Bar

struct BottomControlBar: View {
    @ObservedObject var vm: ScrcpyPlusViewModel

    var body: some View {
        HStack(spacing: 10) {
            Group {
                Button("Home") { vm.sendKeyevent("3", label: "Home") }
                Button("Back") { vm.sendKeyevent("4", label: "Back") }
                Button("Recent") { vm.sendKeyevent("187", label: "App Switch") }
                Button("Power") { vm.sendKeyevent("26", label: "Power") }
                Button("Vol -") { vm.sendKeyevent("25", label: "Volume Down") }
                Button("Vol +") { vm.sendKeyevent("24", label: "Volume Up") }
            }
            .controlSize(.small)

            Divider().frame(height: 18)

            Text(vm.statusMessage)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Spacer()

            if vm.isRunning || vm.isDeXSessionRunning {
                Button(role: .destructive) {
                    vm.stopScrcpy()
                } label: {
                    Label("Stop Sesi", systemImage: "stop.fill")
                        .padding(.horizontal, 8)
                }
                .controlSize(.large)
            }

            Button {
                vm.startScrcpy()
            } label: {
                Label(
                    vm.profile == "desktop" ? (vm.isDeXSessionRunning ? "DeX Aktif (Buka Taskbar)" : "Start DeX (1 Jendela)") : (vm.isRunning ? "Restart scrcpy" : "Start scrcpy"),
                    systemImage: vm.profile == "desktop" ? "macwindow.on.rectangle" : "play.fill"
                )
                .font(.system(size: 13, weight: .semibold))
                .padding(.horizontal, 10)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .keyboardShortcut(.defaultAction)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.bar)
    }
}

// MARK: - 1. Dashboard & Profiles Section

struct DashboardSectionView: View {
    @ObservedObject var vm: ScrcpyPlusViewModel

    let columns = [
        GridItem(.adaptive(minimum: 210, maximum: 260), spacing: 12)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            // Live Device Telemetry Card
            GroupBox {
                HStack(spacing: 18) {
                    VStack(alignment: .leading, spacing: 4) {
                        Label("Perangkat Terhubung", systemImage: "iphone.badge.play")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.secondary)
                        Text("\(vm.telemetry.manufacturer) \(vm.telemetry.model)")
                            .font(.system(size: 16, weight: .bold))
                        Text("Android \(vm.telemetry.androidVersion) (API \(vm.telemetry.sdkVersion))")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }

                    Divider().frame(height: 44)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Baterai & Suhu")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.secondary)
                        HStack(spacing: 6) {
                            Image(systemName: vm.telemetry.batteryLevel > 20 ? "battery.75percent" : "battery.25percent")
                                .foregroundStyle(vm.telemetry.batteryLevel > 20 ? .green : .orange)
                            Text("\(vm.telemetry.batteryLevel)% • \(vm.telemetry.batteryTemp)")
                                .font(.system(size: 14, weight: .bold))
                        }
                    }

                    Divider().frame(height: 44)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Memori RAM")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.secondary)
                        Text(vm.telemetry.ramUsage)
                            .font(.system(size: 13.5, weight: .semibold))
                    }

                    Divider().frame(height: 44)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Resolusi Layar")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.secondary)
                        Text(vm.telemetry.screenSize)
                            .font(.system(size: 13.5, weight: .semibold))
                    }

                    Divider().frame(height: 44)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Alamat IP Wi-Fi")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.secondary)
                        Text(vm.telemetry.ipAddress)
                            .font(.system(size: 13.5, weight: .semibold, design: .monospaced))
                    }

                    Spacer()

                    Button {
                        vm.runSystemDoctor()
                    } label: {
                        Label("Doctor ADB", systemImage: "stethoscope")
                    }
                    .help("Periksa & pulihkan koneksi ADB otomatis")

                    Button {
                        vm.bridgeUsbToWifi()
                    } label: {
                        Label("Aktifkan Wi-Fi", systemImage: "wifi")
                    }
                    .help("Ubah koneksi USB ke ADB TCP/IP port 5555 secara otomatis")
                }
                .padding(8)
            }

            // Quick Feature Toggles
            GroupBox("Opsi Cepat Favorit") {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 10) {
                    Toggle("Wi-Fi Otomatis (--wireless)", isOn: $vm.wireless)
                    Toggle("Fullscreen (-f)", isOn: $vm.fullscreen)
                    Toggle("Matikan Layar HP (-S)", isOn: $vm.screenOff)
                    Toggle("Tampilkan Sentuhan (-t)", isOn: $vm.showTouches)
                    Toggle("Jaga HP Menyala (-w)", isOn: $vm.stayAwake)
                    Toggle("Duplikasi Audio (--audio-dup)", isOn: $vm.audioDup)
                    Toggle("Selalu di Atas", isOn: $vm.alwaysOnTop)
                    Toggle("Tanpa Bingkai", isOn: $vm.borderless)
                    Toggle("Rekam Sesi ke File", isOn: $vm.recordEnabled)
                    Toggle("Auto-Heal Sesi Putus", isOn: $vm.autoRecoverSession)
                        .help("Otomatis pulihkan koneksi ADB & buka ulang scrcpy/DeX jika terputus mendadak")
                    Toggle("Auto-Reconnect Wi-Fi", isOn: $vm.autoReconnectWifi)
                        .help("Otomatis sambungkan kembali IP Wi-Fi terakhir saat aplikasi dibuka atau terputus")
                }
                .padding(8)
            }

            HStack {
                Text("Pilih Mode Profil Mirroring")
                    .font(.system(size: 15, weight: .bold))
                Spacer()
                Button {
                    vm.profile = "desktop"
                    vm.selectedSection = .virtualDesktop
                } label: {
                    Label("Buka Workspace DeX Multi-Window →", systemImage: "macwindow.on.rectangle")
                        .font(.system(size: 12, weight: .semibold))
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(allProfiles) { item in
                    let isSelected = vm.profile == item.id
                    Button {
                        vm.profile = item.id
                        if item.id == "desktop" {
                            vm.selectedSection = .virtualDesktop
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: item.icon)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(isSelected ? .white : .accentColor)
                                Spacer()
                                Text(item.badge)
                                    .font(.system(size: 10, weight: .bold))
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 2)
                                    .background(isSelected ? Color.white.opacity(0.25) : Color.accentColor.opacity(0.15))
                                    .foregroundStyle(isSelected ? .white : .accentColor)
                                    .clipShape(Capsule())
                            }
                            Text(item.title)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(isSelected ? .white : .primary)
                            Text(item.subtitle)
                                .font(.system(size: 11.5))
                                .foregroundStyle(isSelected ? .white.opacity(0.9) : .secondary)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, minHeight: 92, alignment: .topLeading)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(isSelected ? Color.accentColor : Color(nsColor: .controlBackgroundColor))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isSelected ? Color.accentColor : Color.secondary.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            // Custom Saved Presets
            GroupBox("Preset Kustom Anda") {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        TextField("Nama preset baru (mis. Main Genshin 60fps)...", text: $vm.customPresetName)
                            .textFieldStyle(.roundedBorder)
                        Button {
                            vm.saveCurrentAsCustomPreset()
                        } label: {
                            Label("Simpan Konfigurasi Saat Ini", systemImage: "plus.circle.fill")
                        }
                        .disabled(vm.customPresetName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }

                    if vm.savedPresets.isEmpty {
                        Text("Belum ada preset kustom. Atur opsi sesuai keinginan lalu simpan di atas.")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(vm.savedPresets) { preset in
                                    HStack(spacing: 6) {
                                        Button {
                                            vm.applyCustomPreset(preset)
                                        } label: {
                                            Label(preset.name, systemImage: "bookmark.fill")
                                        }
                                        Button(role: .destructive) {
                                            vm.deleteCustomPreset(preset)
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.accentColor.opacity(0.12))
                                    .clipShape(Capsule())
                                }
                            }
                        }
                    }
                }
                .padding(8)
            }
        }
    }
}

// MARK: - 2. Single-Window Samsung DeX Desktop Environment (Semua App di Dalam 1 Jendela DeX!)

struct VirtualDesktopSectionView: View {
    @ObservedObject var vm: ScrcpyPlusViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Interactive DeX Desktop Canvas right inside the section!
            DeXDesktopCanvasView(vm: vm)
                .frame(height: 470)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.18), radius: 8, y: 3)

            // Single-Window DeX Configuration Bar
            GroupBox("Pengaturan Mode Samsung DeX (Jendela Tunggal & Mode Landscape)") {
                VStack(alignment: .leading, spacing: 12) {
                    // Row 1: Orientation Mode Selector (Landscape / Portrait / Auto)
                    HStack(spacing: 10) {
                        Label("Mode Orientasi DeX:", systemImage: "rectangle.landscape.rotate")
                            .font(.system(size: 12, weight: .bold))

                        Button {
                            vm.setDeXOrientation("landscape")
                        } label: {
                            Label("Landscape (16:9 Horizontal Terkunci)", systemImage: "laptopcomputer")
                                .font(.system(size: 11.5, weight: vm.dexOrientationMode == "landscape" ? .bold : .regular))
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(vm.dexOrientationMode == "landscape" ? .accentColor : .secondary)
                        .controlSize(.small)

                        Button {
                            vm.setDeXOrientation("landscape-reverse")
                        } label: {
                            Label("Landscape 180°", systemImage: "rectangle.landscape.rotate")
                                .font(.system(size: 11.5, weight: vm.dexOrientationMode == "landscape-reverse" ? .bold : .regular))
                        }
                        .buttonStyle(.bordered)
                        .tint(vm.dexOrientationMode == "landscape-reverse" ? .accentColor : .secondary)
                        .controlSize(.small)

                        Button {
                            vm.setDeXOrientation("portrait")
                        } label: {
                            Label("Portrait (Vertikal 9:16)", systemImage: "iphone")
                                .font(.system(size: 11.5, weight: vm.dexOrientationMode == "portrait" ? .bold : .regular))
                        }
                        .buttonStyle(.bordered)
                        .tint(vm.dexOrientationMode == "portrait" ? .accentColor : .secondary)
                        .controlSize(.small)

                        Button {
                            vm.setDeXOrientation("auto")
                        } label: {
                            Label("Otomatis (Ikuti App)", systemImage: "arrow.triangle.2.circlepath")
                                .font(.system(size: 11.5, weight: vm.dexOrientationMode == "auto" ? .bold : .regular))
                        }
                        .buttonStyle(.bordered)
                        .tint(vm.dexOrientationMode == "auto" ? .accentColor : .secondary)
                        .controlSize(.small)
                    }

                    Divider()

                    // Row 2: Resolution Presets
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            Text("Resolusi DeX:")
                                .font(.system(size: 12, weight: .semibold))
                            ForEach(virtualDesktopPresets) { preset in
                                let isCurrent = vm.dexDisplaySpec == preset.spec
                                Button {
                                    vm.applyDeXPreset(preset)
                                } label: {
                                    Text("\(preset.title) (\(preset.spec))")
                                        .font(.system(size: 11.5, weight: isCurrent ? .bold : .regular))
                                }
                                .buttonStyle(.bordered)
                                .tint(isCurrent ? .accentColor : .secondary)
                                .controlSize(.small)
                            }
                        }
                    }

                    Divider()

                    // Row 3: Live DPI / Zoom Slider (Real-Time without Restart!)
                    HStack(spacing: 12) {
                        Label("Live Zoom / Skala DPI DeX:", systemImage: "plus.magnifyingglass")
                            .font(.system(size: 12, weight: .bold))
                        Slider(
                            value: $vm.dexLiveDPI,
                            in: 120...320,
                            step: 10
                        ) {
                            Text("DPI")
                        } onEditingChanged: { editing in
                            if !editing {
                                vm.applyLiveDeXDPI(Int(vm.dexLiveDPI))
                            }
                        }
                        .frame(width: 180)

                        Text("\(Int(vm.dexLiveDPI)) DPI")
                            .font(.system(size: 11.5, weight: .bold, design: .monospaced))
                            .frame(width: 60)

                        ForEach([("Kecil PC (130)", 130), ("Standar (160)", 160), ("Medium (200)", 200), ("Besar (250)", 250)], id: \.1) { item in
                            Button(item.0) {
                                vm.applyLiveDeXDPI(item.1)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.mini)
                        }
                    }

                    Divider()

                    // Row 4: Hybrid Window Mode + Split-Screen + Workspace Bundles
                    HStack(spacing: 16) {
                        Toggle("Mode Hybrid: Buka Klik Baru di Jendela Terpisah (+Window)", isOn: $vm.dexOpenInNewWindow)
                            .help("Jika dicentang, klik aplikasi akan membuka jendela mandiri baru. Jika tidak dicentang, semua aplikasi dibuka di dalam 1 jendela utama DeX.")
                        Toggle("Bebas Layar Hitam (--no-vd-system-decorations)", isOn: $vm.dexNoSystemDecorations)
                        Toggle("Mode Freeform Multi-App", isOn: $vm.dexFreeformMode)
                        Spacer()
                        Button {
                            vm.takeInstantScreenshot(fromDeXDisplay: true)
                        } label: {
                            Label("Screenshot DeX (Auto-Copy)", systemImage: "camera.on.rectangle.fill")
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)

                        Button {
                            vm.showFloatingDeXTaskbar()
                        } label: {
                            Label("Floating Taskbar", systemImage: "dock.rectangle")
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    }
                    .font(.system(size: 12))

                    Divider()

                    // Row 5: 1-Click Workspace Macros & Split-Screen Pair Launcher
                    HStack(spacing: 10) {
                        Label("Paket Workspace 1-Klik:", systemImage: "square.grid.2x2.fill")
                            .font(.system(size: 12, weight: .bold))
                        ForEach(dexWorkspaceBundles) { bundle in
                            Button {
                                vm.launchDeXWorkspaceBundle(bundle)
                            } label: {
                                Label(bundle.title, systemImage: bundle.icon)
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            .buttonStyle(.bordered)
                            .tint(bundle.color)
                            .controlSize(.small)
                            .help(bundle.subtitle)
                        }
                        Spacer()
                        Button {
                            vm.launchSplitScreenDeX()
                        } label: {
                            Label("Split-Screen (Chrome + WA)", systemImage: "rectangle.split.2x1.fill")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                        .help("Buka 2 aplikasi sekaligus dalam mode Multi-App Freeform di dalam layar Landscape DeX")
                    }
                }
                .padding(8)
            }
        }
        .onAppear {
            if vm.installedApps.isEmpty && !vm.isLoadingApps {
                vm.loadInstalledApps()
            }
        }
    }
}

struct DeXDesktopCanvasView: View {
    @ObservedObject var vm: ScrcpyPlusViewModel

    let desktopGridCols = [
        GridItem(.adaptive(minimum: 98, maximum: 115), spacing: 14)
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            // 1. DeX Desktop Wallpaper Gradient
            LinearGradient(
                colors: [
                    Color(red: 0.07, green: 0.11, blue: 0.22),
                    Color(red: 0.12, green: 0.18, blue: 0.34),
                    Color(red: 0.08, green: 0.24, blue: 0.36)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 0) {
                // 2. DeX Top Desktop Header & Search Bar
                HStack(spacing: 14) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles.tv.fill")
                            .foregroundStyle(.cyan)
                            .font(.system(size: 16, weight: .bold))
                        Text(vm.isDeXSessionRunning
                             ? "Samsung DeX Aktif (Display #\(vm.activeDeXDisplayID)) — \(vm.telemetry.model)"
                             : "Samsung DeX Single-Window — \(vm.telemetry.manufacturer) \(vm.telemetry.model)")
                            .font(.system(size: 13.5, weight: .bold))
                            .foregroundStyle(.white)
                    }

                    Spacer()

                    // Search Bar on Desktop
                    HStack(spacing: 6) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.white.opacity(0.7))
                            .font(.system(size: 12))
                        TextField("Cari aplikasi untuk dibuka di dalam jendela DeX...", text: $vm.dexSearchQuery)
                            .textFieldStyle(.plain)
                            .foregroundStyle(.white)
                            .font(.system(size: 12))
                        if !vm.dexSearchQuery.isEmpty {
                            Button {
                                vm.dexSearchQuery = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .frame(width: 300)
                    .background(Color.white.opacity(0.14))
                    .clipShape(Capsule())

                    Button {
                        vm.toggleDeXLandscapePortrait()
                    } label: {
                        Label(
                            vm.dexOrientationMode == "landscape" ? "Mode: Landscape 16:9" : (vm.dexOrientationMode == "portrait" ? "Mode: Portrait 9:16" : "Mode: \(vm.dexOrientationMode.capitalized)"),
                            systemImage: vm.dexOrientationMode == "portrait" ? "iphone" : "laptopcomputer"
                        )
                        .font(.system(size: 11.5, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 5)
                        .background(vm.dexOrientationMode == "landscape" ? Color.cyan.opacity(0.35) : Color.orange.opacity(0.35))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .help("Klik untuk berganti antara Mode Landscape (Horizontal) dan Portrait (Vertikal)")

                    Button {
                        vm.loadInstalledApps()
                    } label: {
                        Label(vm.isLoadingApps ? "Memuat..." : "Refresh App", systemImage: "arrow.clockwise")
                            .font(.system(size: 11.5, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.white.opacity(0.15))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 18)
                .padding(.top, 14)
                .padding(.bottom, 8)

                // Subtitle instruction banner
                HStack(spacing: 6) {
                    Image(systemName: vm.isDeXSessionRunning ? "checkmark.circle.fill" : "info.circle.fill")
                        .foregroundStyle(vm.isDeXSessionRunning ? .green : .cyan)
                    Text(vm.isDeXSessionRunning
                         ? "Jendela Tunggal DeX sedang berjalan! Klik aplikasi mana pun di bawah atau di Floating Taskbar untuk membukanya DI DALAM jendela DeX yang sama tanpa membuat jendela baru."
                         : "Klik aplikasi pertama di bawah untuk membuka 1 Jendela Samsung DeX. Aplikasi berikutnya akan langsung terbuka di dalam jendela DeX tersebut (tanpa buka jendela baru!).")
                        .font(.system(size: 11.5))
                        .foregroundStyle(.white.opacity(0.9))
                    Spacer()
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 8)

                // 3. Desktop Icons Area (Scrollable Grid of Installed Apps + Quick Shortcuts)
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if vm.dexSearchQuery.isEmpty {
                            Text("Aplikasi Populer & Cepat (Buka di Dalam Jendela DeX)")
                                .font(.system(size: 11.5, weight: .bold))
                                .foregroundStyle(.white.opacity(0.7))
                                .padding(.horizontal, 4)

                            LazyVGrid(columns: desktopGridCols, spacing: 12) {
                                ForEach(virtualDesktopQuickApps) { item in
                                    DeXDesktopIconButton(
                                        title: item.title,
                                        subtitle: vm.dexOpenInNewWindow ? "+Window" : "In-DeX",
                                        icon: item.icon,
                                        color: item.color
                                    ) {
                                        vm.launchDeXApp(
                                            appName: item.title,
                                            packageQuery: item.query,
                                            icon: item.icon,
                                            preferPortrait: item.preferPortrait
                                        )
                                    }
                                    .contextMenu {
                                        Button("Buka di Jendela Utama DeX (1 Jendela)") {
                                            let old = vm.dexOpenInNewWindow
                                            vm.dexOpenInNewWindow = false
                                            vm.launchDeXApp(appName: item.title, packageQuery: item.query, icon: item.icon)
                                            vm.dexOpenInNewWindow = old
                                        }
                                        Button("Pisah ke Jendela Mandiri Baru (+Window)") {
                                            vm.spawnDetachedDeXWindow(appName: item.title, packageQuery: item.query, icon: item.icon, isPiP: false)
                                        }
                                        Button("Buka sebagai Picture-in-Picture (PiP Melayang)") {
                                            vm.spawnDetachedDeXWindow(appName: item.title, packageQuery: item.query, icon: item.icon, isPiP: true)
                                        }
                                    }
                                }
                            }
                        }

                        if !vm.dexFilteredApps.isEmpty {
                            HStack {
                                Text("Semua Aplikasi di \(vm.telemetry.model) (\(vm.dexFilteredApps.count))")
                                    .font(.system(size: 11.5, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.7))
                                Spacer()
                                Toggle("App Sistem", isOn: $vm.showSystemApps)
                                    .toggleStyle(.checkbox)
                                    .font(.system(size: 11))
                                    .foregroundStyle(.white.opacity(0.8))
                            }
                            .padding(.horizontal, 4)
                            .padding(.top, 4)

                            LazyVGrid(columns: desktopGridCols, spacing: 12) {
                                ForEach(vm.dexFilteredApps) { app in
                                    DeXDesktopIconButton(
                                        title: app.appName,
                                        subtitle: vm.activeDeXAppPackage == app.packageName ? "Aktif" : "",
                                        icon: app.symbolName,
                                        color: app.accentColor
                                    ) {
                                        vm.launchDeXApp(
                                            appName: app.appName,
                                            packageQuery: app.packageName,
                                            icon: app.symbolName
                                        )
                                    }
                                    .contextMenu {
                                        Button("Buka di Jendela Utama DeX (1 Jendela)") {
                                            let old = vm.dexOpenInNewWindow
                                            vm.dexOpenInNewWindow = false
                                            vm.launchDeXApp(appName: app.appName, packageQuery: app.packageName, icon: app.symbolName)
                                            vm.dexOpenInNewWindow = old
                                        }
                                        Button("Pisah ke Jendela Mandiri Baru (+Window)") {
                                            vm.spawnDetachedDeXWindow(appName: app.appName, packageQuery: app.packageName, icon: app.symbolName, isPiP: false)
                                        }
                                        Button("Buka sebagai Picture-in-Picture (PiP Melayang)") {
                                            vm.spawnDetachedDeXWindow(appName: app.appName, packageQuery: app.packageName, icon: app.symbolName, isPiP: true)
                                        }
                                    }
                                }
                            }
                        } else if vm.isLoadingApps {
                            HStack(spacing: 10) {
                                ProgressView().controlSize(.small)
                                Text("Sedang mengambil daftar aplikasi dari HP Anda...")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.white.opacity(0.8))
                            }
                            .padding(20)
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 68)
                }
            }

            // 4. Samsung DeX Bottom Taskbar (In-App Switcher inside Single DeX Window)
            HStack(spacing: 10) {
                // Start / Apps Button
                Button {
                    vm.startSingleWindowDeXSession()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "circle.grid.3x3.fill")
                            .font(.system(size: 14, weight: .bold))
                        Text(vm.isDeXSessionRunning ? "DeX Aktif" : "Start DeX")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(vm.isDeXSessionRunning ? Color.green : Color.accentColor)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                // In-DeX Display Navigation Buttons (Back & Recent on Virtual Display!)
                HStack(spacing: 6) {
                    Button {
                        vm.sendDeXKeyevent("4", label: "Back")
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.backward")
                            Text("Back DeX")
                        }
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(Color.white.opacity(0.14))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .help("Kirim tombol Back ke dalam Jendela DeX")

                    Button {
                        vm.sendDeXKeyevent("187", label: "Recent Apps")
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "square.stack.3d.up.fill")
                            Text("Recent DeX")
                        }
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(Color.white.opacity(0.14))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .help("Tampilkan Multitasking / Recent Apps di dalam Jendela DeX")

                    Button {
                        vm.setDeXOrientation("landscape")
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "laptopcomputer")
                            Text("Landscape")
                        }
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(vm.dexOrientationMode == "landscape" ? Color.cyan.opacity(0.55) : Color.white.opacity(0.14))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .help("Kunci tampilan DeX ke Mode Landscape (Horizontal)")

                    Button {
                        vm.setDeXOrientation("portrait")
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "iphone")
                            Text("Portrait")
                        }
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(vm.dexOrientationMode == "portrait" ? Color.orange.opacity(0.55) : Color.white.opacity(0.14))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .help("Ubah tampilan DeX ke Mode Portrait (Vertikal)")
                }

                Divider()
                    .frame(height: 22)
                    .background(Color.white.opacity(0.3))

                // Running Apps Switcher Pills inside the Single DeX Window!
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        if vm.dexRunningApps.isEmpty {
                            Text("Klik ikon di atas — aplikasi akan dibuka & diganti di dalam 1 Jendela DeX")
                                .font(.system(size: 11.5))
                                .foregroundStyle(.white.opacity(0.65))
                        } else {
                            ForEach(vm.dexRunningApps) { app in
                                let isFocused = vm.activeDeXAppPackage == app.resolvedPackage
                                HStack(spacing: 6) {
                                    Button {
                                        // Switch to this app inside the existing single DeX window!
                                        vm.launchDeXApp(
                                            appName: app.appName,
                                            packageQuery: app.resolvedPackage,
                                            icon: app.icon
                                        )
                                    } label: {
                                        HStack(spacing: 6) {
                                            Circle()
                                                .fill(isFocused ? Color.green : Color.cyan.opacity(0.7))
                                                .frame(width: 7, height: 7)
                                            Image(systemName: app.icon)
                                                .font(.system(size: 11))
                                                .foregroundStyle(.white)
                                            Text(app.appName)
                                                .font(.system(size: 11.5, weight: isFocused ? .bold : .medium))
                                                .foregroundStyle(.white)
                                                .lineLimit(1)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                    .help("Tampilkan \(app.appName) di dalam Jendela DeX")

                                    Button {
                                        vm.removeDeXAppFromTaskbar(app)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 11.5))
                                            .foregroundStyle(.white.opacity(0.65))
                                    }
                                    .buttonStyle(.plain)
                                    .help("Hapus dari daftar Taskbar DeX")
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(isFocused ? Color.accentColor.opacity(0.85) : Color.white.opacity(0.18))
                                .clipShape(Capsule())
                            }

                            if vm.isDeXSessionRunning {
                                Button {
                                    vm.closeAllDeXWindows()
                                } label: {
                                    Text("Tutup DeX")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundStyle(.red)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.white.opacity(0.14))
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                Spacer()

                // System Tray (Battery, Audio/Volume, Screenshot)
                HStack(spacing: 10) {
                    Button { vm.sendKeyevent("25", label: "Vol -") } label: {
                        Image(systemName: "speaker.wave.1.fill").foregroundStyle(.white.opacity(0.85))
                    }
                    .buttonStyle(.plain)
                    .help("Volume Turun")

                    Button { vm.sendKeyevent("24", label: "Vol +") } label: {
                        Image(systemName: "speaker.wave.3.fill").foregroundStyle(.white.opacity(0.85))
                    }
                    .buttonStyle(.plain)
                    .help("Volume Naik")

                    Button { vm.takeInstantScreenshot() } label: {
                        Image(systemName: "camera.viewfinder").foregroundStyle(.white.opacity(0.85))
                    }
                    .buttonStyle(.plain)
                    .help("Screenshot")

                    HStack(spacing: 4) {
                        Image(systemName: "battery.75percent")
                            .foregroundStyle(.green)
                        Text("\(vm.telemetry.batteryLevel)%")
                            .font(.system(size: 11.5, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(.ultraThinMaterial)
            .environment(\.colorScheme, .dark)
        }
    }
}

// MARK: - Floating Samsung DeX Taskbar & App Drawer (Docks Below the Single DeX Window)

struct FloatingDeXTaskbarView: View {
    @ObservedObject var vm: ScrcpyPlusViewModel

    var body: some View {
        HStack(spacing: 10) {
            // 1. DeX Start Menu / App Drawer Button
            Button {
                vm.toggleFloatingDeXStartMenu()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "circle.grid.3x3.fill")
                        .font(.system(size: 14, weight: .bold))
                    Text("DeX Apps")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(vm.showDeXStartMenu ? Color.cyan : Color.accentColor)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .help("Buka laci aplikasi (App Drawer) untuk mengganti aplikasi di dalam Jendela DeX")

            // 2. DeX Display Navigation (Back & Recent inside DeX Display)
            HStack(spacing: 5) {
                Button {
                    vm.sendDeXKeyevent("4", label: "Back")
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                        .background(Color.white.opacity(0.15))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .help("Back di dalam Jendela DeX")

                Button {
                    vm.sendDeXKeyevent("187", label: "Recent")
                } label: {
                    Image(systemName: "square.stack.3d.up.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                        .background(Color.white.opacity(0.15))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .help("Recent Apps / Multitasking di dalam Jendela DeX")

                Button {
                    vm.setDeXOrientation("landscape")
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "laptopcomputer")
                        Text("Landscape")
                    }
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 6)
                    .background(vm.dexOrientationMode == "landscape" ? Color.cyan.opacity(0.6) : Color.white.opacity(0.15))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .help("Kunci Jendela DeX ke Mode Landscape (Horizontal)")

                Button {
                    vm.setDeXOrientation("portrait")
                } label: {
                    Image(systemName: "iphone")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                        .background(vm.dexOrientationMode == "portrait" ? Color.orange.opacity(0.6) : Color.white.opacity(0.15))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .help("Ubah Jendela DeX ke Mode Portrait (Vertikal)")
            }

            Divider()
                .frame(height: 24)
                .background(Color.white.opacity(0.25))

            // 3. Running DeX Apps Switcher (Click to bring app to front inside the same DeX window!)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) {
                    ForEach(vm.dexRunningApps) { app in
                        let isFocused = vm.activeDeXAppPackage == app.resolvedPackage
                        Button {
                            vm.launchDeXApp(
                                appName: app.appName,
                                packageQuery: app.resolvedPackage,
                                icon: app.icon
                            )
                        } label: {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(isFocused ? Color.green : Color.cyan)
                                    .frame(width: 7, height: 7)
                                Image(systemName: app.icon)
                                    .font(.system(size: 11.5, weight: .semibold))
                                    .foregroundStyle(.white)
                                Text(app.appName)
                                    .font(.system(size: 11.5, weight: isFocused ? .bold : .medium))
                                    .foregroundStyle(.white)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, 11)
                            .padding(.vertical, 6)
                            .background(isFocused ? Color.accentColor : Color.white.opacity(0.16))
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .help("Pindah ke \(app.appName) di dalam Jendela DeX")
                    }

                    // Quick shortcuts right on the dock
                    ForEach(virtualDesktopQuickApps.prefix(4)) { quick in
                        Button {
                            vm.launchDeXApp(appName: quick.title, packageQuery: quick.query, icon: quick.icon)
                        } label: {
                            Image(systemName: quick.icon)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.9))
                                .frame(width: 28, height: 28)
                                .background(quick.color.opacity(0.65))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .help("Buka \(quick.title) di Jendela DeX")
                    }
                }
            }

            Spacer()

            // 4. Freeform toggle & Close DeX
            Toggle("Freeform", isOn: $vm.dexFreeformMode)
                .toggleStyle(.checkbox)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.white.opacity(0.9))
                .help("Buka aplikasi dalam jendela mengambang (Freeform) di dalam layar DeX")

            Button {
                vm.closeAllDeXWindows()
            } label: {
                Image(systemName: "power.circle.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
            .help("Matikan Sesi Samsung DeX")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(red: 0.08, green: 0.11, blue: 0.18).opacity(0.94))
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color.white.opacity(0.22), lineWidth: 1)
                )
        )
        .padding(4)
    }
}

struct FloatingDeXStartMenuView: View {
    @ObservedObject var vm: ScrcpyPlusViewModel

    let gridCols = [
        GridItem(.adaptive(minimum: 95, maximum: 115), spacing: 12)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Samsung DeX App Launcher (Buka di Jendela DeX #\(vm.activeDeXDisplayID))", systemImage: "sparkles.tv.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
                Button {
                    vm.toggleFloatingDeXStartMenu()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(.white.opacity(0.75))
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.white.opacity(0.7))
                TextField("Cari aplikasi Android...", text: $vm.dexSearchQuery)
                    .textFieldStyle(.plain)
                    .foregroundStyle(.white)
                    .font(.system(size: 12.5))
                Toggle("App Sistem", isOn: $vm.showSystemApps)
                    .toggleStyle(.checkbox)
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.85))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(Color.white.opacity(0.14))
            .clipShape(RoundedRectangle(cornerRadius: 8))

            ScrollView {
                LazyVGrid(columns: gridCols, spacing: 12) {
                    ForEach(vm.dexFilteredApps) { app in
                        DeXDesktopIconButton(
                            title: app.appName,
                            subtitle: vm.activeDeXAppPackage == app.packageName ? "Aktif" : "",
                            icon: app.symbolName,
                            color: app.accentColor
                        ) {
                            vm.launchDeXApp(
                                appName: app.appName,
                                packageQuery: app.packageName,
                                icon: app.symbolName
                            )
                        }
                    }
                }
                .padding(.vertical, 6)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(red: 0.08, green: 0.12, blue: 0.22).opacity(0.96))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.22), lineWidth: 1)
                )
        )
        .padding(4)
    }
}

struct DeXDesktopIconButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.95), color.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                        .shadow(color: .black.opacity(0.25), radius: 4, y: 2)

                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                }

                Text(title)
                    .font(.system(size: 11.5, weight: .medium))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .frame(maxWidth: 96)

                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.system(size: 9.5, weight: .semibold))
                        .foregroundStyle(.cyan.opacity(0.9))
                }
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 4)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.05))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 3. Video, Display & Camera Section

struct VideoCameraSectionView: View {
    @ObservedObject var vm: ScrcpyPlusViewModel

    let twoCols = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            GroupBox("Kualitas Video & Rendering") {
                LazyVGrid(columns: twoCols, alignment: .leading, spacing: 12) {
                    FormField(label: "Video Codec") {
                        Picker("", selection: $vm.videoCodec) {
                            Text("Default (H.264)").tag("default")
                            Text("H.264 (Paling Kompatibel)").tag("h264")
                            Text("H.265 / HEVC (Tajam & Efisien)").tag("h265")
                            Text("AV1 (Generasi Baru)").tag("av1")
                        }
                        .labelsHidden()
                    }

                    FormField(label: "Resolusi Maksimum (--max-size)") {
                        Picker("", selection: $vm.maxSize) {
                            Text("Asli (Tanpa Batas)").tag("default")
                            Text("720p (Sangat Cepat)").tag("720")
                            Text("1024p").tag("1024")
                            Text("1080p (Full HD)").tag("1080")
                            Text("1280p").tag("1280")
                            Text("1440p (2K QHD)").tag("1440")
                            Text("1920p").tag("1920")
                            Text("2560p (4K)").tag("2560")
                        }
                        .labelsHidden()
                    }

                    FormField(label: "Bitrate Video (-b)") {
                        TextField("mis. 12M, 20M, 30M", text: $vm.bitrate)
                            .textFieldStyle(.roundedBorder)
                    }

                    FormField(label: "Batas Frame Rate (--max-fps)") {
                        TextField("mis. 30, 60, 120", text: $vm.fps)
                            .textFieldStyle(.roundedBorder)
                    }

                    FormField(label: "Orientasi Tampilan (--orientation)") {
                        Picker("", selection: $vm.orientation) {
                            Text("Default").tag("default")
                            Text("0° (Normal)").tag("0")
                            Text("90° (Putar Kanan)").tag("90")
                            Text("180° (Terbalik)").tag("180")
                            Text("270° (Putar Kiri)").tag("270")
                            Text("Flip Horizontal 0°").tag("flip0")
                            Text("Flip Horizontal 90°").tag("flip90")
                            Text("Flip Horizontal 180°").tag("flip180")
                            Text("Flip Horizontal 270°").tag("flip270")
                        }
                        .labelsHidden()
                    }

                    FormField(label: "Render Driver") {
                        Picker("", selection: $vm.renderDriver) {
                            Text("Otomatis").tag("default")
                            Text("Metal (macOS Native)").tag("metal")
                            Text("OpenGL").tag("opengl")
                            Text("OpenGL ES 2").tag("opengles2")
                            Text("Software").tag("software")
                        }
                        .labelsHidden()
                    }

                    FormField(label: "Buffer Video (ms)") {
                        TextField("Default: 0", text: $vm.videoBuffer)
                            .textFieldStyle(.roundedBorder)
                    }

                    FormField(label: "Crop Layar (W:H:X:Y)") {
                        TextField("mis. 1080:1920:0:0", text: $vm.crop)
                            .textFieldStyle(.roundedBorder)
                    }

                    FormField(label: "Sudut Rotasi Kustom (--angle)") {
                        TextField("mis. 15, -15", text: $vm.angle)
                            .textFieldStyle(.roundedBorder)
                    }

                    FormField(label: "Target Display ID (--display-id)") {
                        TextField("Default: 0", text: $vm.displayId)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                .padding(10)
            }

            GroupBox("Mode Kamera HP / Webcam (Android 12+)") {
                VStack(alignment: .leading, spacing: 12) {
                    LazyVGrid(columns: twoCols, alignment: .leading, spacing: 12) {
                        FormField(label: "Sumber Video (--video-source)") {
                            Picker("", selection: $vm.videoSource) {
                                Text("Default (Layar HP)").tag("default")
                                Text("Layar HP (display)").tag("display")
                                Text("Kamera HP (camera)").tag("camera")
                            }
                            .labelsHidden()
                        }

                        FormField(label: "Arah Kamera (--camera-facing)") {
                            Picker("", selection: $vm.cameraFacing) {
                                Text("Default").tag("default")
                                Text("Kamera Belakang (back)").tag("back")
                                Text("Kamera Depan / Selfie (front)").tag("front")
                                Text("Kamera Eksternal (external)").tag("external")
                            }
                            .labelsHidden()
                        }

                        FormField(label: "Ukuran Kamera (WxH)") {
                            TextField("mis. 1920x1080", text: $vm.cameraSize)
                                .textFieldStyle(.roundedBorder)
                        }

                        FormField(label: "FPS Kamera (--camera-fps)") {
                            TextField("mis. 30, 60", text: $vm.cameraFps)
                                .textFieldStyle(.roundedBorder)
                        }

                        FormField(label: "Camera ID Spesifik") {
                            TextField("mis. 0, 1", text: $vm.cameraId)
                                .textFieldStyle(.roundedBorder)
                        }

                        FormField(label: "Rasio Aspek (--camera-ar)") {
                            TextField("mis. 16:9, 4:3, sensor", text: $vm.cameraAr)
                                .textFieldStyle(.roundedBorder)
                        }
                    }

                    Divider()

                    HStack {
                        Toggle("Mode Kamera High-Speed (--camera-high-speed)", isOn: $vm.cameraHighSpeed)
                        Spacer()
                        Button("Cek Daftar Kamera HP") {
                            vm.runUtilityCommand(["--list-cameras"], status: "Memeriksa kamera HP...", switchToLogs: true)
                        }
                        Button("Cek Ukuran Kamera") {
                            vm.runUtilityCommand(["--list-camera-sizes"], status: "Memeriksa ukuran kamera...", switchToLogs: true)
                        }
                    }
                }
                .padding(10)
            }
        }
    }
}

// MARK: - Reusable FormField Component

struct FormField<Content: View>: View {
    let label: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
            content()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - 4. Audio & Recording Section

struct AudioRecordSectionView: View {
    @ObservedObject var vm: ScrcpyPlusViewModel

    let twoCols = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            GroupBox("Streaming & Sumber Audio") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 24) {
                        Toggle("Matikan Audio (--no-audio)", isOn: $vm.noAudio)
                        Toggle("Duplikasi Audio di HP & Mac (--audio-dup)", isOn: $vm.audioDup)
                        Toggle("Wajibkan Audio Aktif (--require-audio)", isOn: $vm.requireAudio)
                    }

                    LazyVGrid(columns: twoCols, alignment: .leading, spacing: 12) {
                        FormField(label: "Sumber Audio (--audio-source)") {
                            Picker("", selection: $vm.audioSource) {
                                Text("Default (output)").tag("default")
                                Text("Output Sistem Penuh (output)").tag("output")
                                Text("Playback Aplikasi (playback)").tag("playback")
                                Text("Mikrofon HP (mic)").tag("mic")
                                Text("Mikrofon Raw (mic-unprocessed)").tag("mic-unprocessed")
                                Text("Mikrofon Camcorder (mic-camcorder)").tag("mic-camcorder")
                                Text("Mikrofon Voice Recognition").tag("mic-voice-recognition")
                                Text("Mikrofon Voice Communication").tag("mic-voice-communication")
                                Text("Panggilan Suara (voice-call)").tag("voice-call")
                                Text("Panggilan Uplink (voice-call-uplink)").tag("voice-call-uplink")
                                Text("Panggilan Downlink (voice-call-downlink)").tag("voice-call-downlink")
                                Text("Live Performance / Karaoke (voice-performance)").tag("voice-performance")
                            }
                            .labelsHidden()
                        }

                        FormField(label: "Audio Codec (--audio-codec)") {
                            Picker("", selection: $vm.audioCodec) {
                                Text("Default (Opus)").tag("default")
                                Text("Opus (Latensi Rendah)").tag("opus")
                                Text("AAC").tag("aac")
                                Text("FLAC (Lossless)").tag("flac")
                                Text("RAW (PCM Tanpa Kompresi)").tag("raw")
                            }
                            .labelsHidden()
                        }

                        FormField(label: "Bitrate Audio (--audio-bit-rate)") {
                            TextField("Default: 128K (mis. 256K)", text: $vm.audioBitrate)
                                .textFieldStyle(.roundedBorder)
                        }

                        FormField(label: "Buffer Audio (ms)") {
                            TextField("Default: 50", text: $vm.audioBuffer)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                }
                .padding(10)
            }

            GroupBox("Perekaman Layar & Audio") {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Aktifkan Perekaman Saat Mulai (--record)", isOn: $vm.recordEnabled)
                        .font(.system(size: 13, weight: .semibold))

                    HStack(spacing: 20) {
                        Text("Format File Rekaman:")
                        Picker("", selection: $vm.recordFormat) {
                            Text("MP4 Video (.mp4)").tag("mp4")
                            Text("Matroska Video (.mkv)").tag("mkv")
                            Text("M4A Audio (.m4a)").tag("m4a")
                            Text("MKA Audio (.mka)").tag("mka")
                            Text("Opus Audio (.opus)").tag("opus")
                            Text("AAC Audio (.aac)").tag("aac")
                            Text("FLAC Lossless Audio (.flac)").tag("flac")
                            Text("WAV Audio (.wav)").tag("wav")
                        }
                        .labelsHidden()
                        .frame(width: 230)

                        Toggle("Rekam Tanpa Playback Lokal di Mac (-N)", isOn: $vm.noPlayback)
                    }
                }
                .padding(10)
            }

            GroupBox("Argumen Kustom Tambahan (Extra scrcpy Flags)") {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Tambahkan flag scrcpy lanjutan yang akan diteruskan langsung ke binary scrcpy:")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                    TextField("mis. --video-codec-options=i-frame-interval=2 --pause-on-exit=if-error", text: $vm.extraArgs)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(10)
            }
        }
    }
}

// MARK: - 5. Input, HID & Window Section

struct InputWindowSectionView: View {
    @ObservedObject var vm: ScrcpyPlusViewModel

    let twoCols = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            GroupBox("Perilaku Jendela & Daya Perangkat") {
                VStack(alignment: .leading, spacing: 12) {
                    LazyVGrid(columns: twoCols, alignment: .leading, spacing: 10) {
                        Toggle("Fullscreen Saat Mulai (-f)", isOn: $vm.fullscreen)
                        Toggle("Mode Jendela Desktop (--windowed)", isOn: $vm.windowed)
                        Toggle("Jendela Tanpa Bingkai (--borderless)", isOn: $vm.borderless)
                        Toggle("Selalu di Atas Jendela Lain (--always-on-top)", isOn: $vm.alwaysOnTop)
                        Toggle("Matikan Layar HP Saat Mirroring (-S)", isOn: $vm.screenOff)
                        Toggle("Matikan Layar HP Saat Keluar (--power-off-on-close)", isOn: $vm.powerOffOnClose)
                        Toggle("Jaga HP Tetap Menyala (-w)", isOn: $vm.stayAwake)
                        Toggle("Cegah Screensaver Mac (--disable-screensaver)", isOn: $vm.disableScreensaver)
                        Toggle("Nonaktifkan Kontrol Input (-n / Read-Only)", isOn: $vm.noControl)
                        Toggle("Tampilkan Indikator Sentuhan (-t)", isOn: $vm.showTouches)
                        Toggle("Tampilkan FPS di Log Konsol (--print-fps)", isOn: $vm.printFps)
                        Toggle("Tanpa Video / Audio Saja (--no-video)", isOn: $vm.noVideo)
                    }

                    Divider()

                    LazyVGrid(columns: twoCols, alignment: .leading, spacing: 12) {
                        FormField(label: "Judul Jendela (--window-title)") {
                            TextField("Default: Model Perangkat", text: $vm.windowTitle)
                                .textFieldStyle(.roundedBorder)
                        }

                        FormField(label: "Buka App Saat Mulai (--start-app)") {
                            TextField("mis. ?chrome atau +com.pkg", text: $vm.startApp)
                                .textFieldStyle(.roundedBorder)
                        }

                        FormField(label: "Posisi Jendela (X / Y)") {
                            HStack {
                                TextField("X (auto)", text: $vm.windowX).textFieldStyle(.roundedBorder)
                                TextField("Y (auto)", text: $vm.windowY).textFieldStyle(.roundedBorder)
                            }
                        }

                        FormField(label: "Ukuran Jendela (Lebar × Tinggi)") {
                            HStack {
                                TextField("Lebar", text: $vm.windowWidth).textFieldStyle(.roundedBorder)
                                TextField("Tinggi", text: $vm.windowHeight).textFieldStyle(.roundedBorder)
                            }
                        }

                        FormField(label: "Batas Waktu Sesi (detik)") {
                            TextField("Kosongkan = Tanpa batas", text: $vm.timeLimit)
                                .textFieldStyle(.roundedBorder)
                        }

                        FormField(label: "Timeout Layar HP (detik)") {
                            TextField("mis. 60", text: $vm.screenOffTimeout)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                }
                .padding(10)
            }

            GroupBox("Periferal Input: Keyboard, Mouse, Gamepad & USB OTG") {
                VStack(alignment: .leading, spacing: 12) {
                    LazyVGrid(columns: twoCols, alignment: .leading, spacing: 12) {
                        FormField(label: "Mode Keyboard (--keyboard)") {
                            Picker("", selection: $vm.keyboardMode) {
                                Text("Default (SDK)").tag("default")
                                Text("SDK Android Standar (sdk)").tag("sdk")
                                Text("UHID Keyboard Fisik (uhid)").tag("uhid")
                                Text("AOA USB Fisik (aoa)").tag("aoa")
                                Text("Nonaktif (disabled)").tag("disabled")
                            }
                            .labelsHidden()
                        }

                        FormField(label: "Mode Mouse (--mouse)") {
                            Picker("", selection: $vm.mouseMode) {
                                Text("Default (SDK)").tag("default")
                                Text("SDK Android Standar (sdk)").tag("sdk")
                                Text("UHID Mouse Fisik (uhid)").tag("uhid")
                                Text("AOA USB Fisik (aoa)").tag("aoa")
                                Text("Nonaktif (disabled)").tag("disabled")
                            }
                            .labelsHidden()
                        }

                        FormField(label: "Mode Gamepad (--gamepad)") {
                            Picker("", selection: $vm.gamepadMode) {
                                Text("Default (Nonaktif)").tag("default")
                                Text("UHID Gamepad Fisik (uhid)").tag("uhid")
                                Text("AOA USB Gamepad (aoa)").tag("aoa")
                                Text("Nonaktif (disabled)").tag("disabled")
                            }
                            .labelsHidden()
                        }

                        FormField(label: "Tombol Modifier Shortcut (--shortcut-mod)") {
                            Picker("", selection: $vm.shortcutMod) {
                                Text("Default (Option / Command)").tag("default")
                                Text("Left Alt + Left Super (lalt,lsuper)").tag("lalt,lsuper")
                                Text("Left Ctrl + Left Super (lctrl,lsuper)").tag("lctrl,lsuper")
                                Text("Hanya Left Option (lalt)").tag("lalt")
                                Text("Hanya Left Command (lsuper)").tag("lsuper")
                            }
                            .labelsHidden()
                        }
                    }

                    Divider()

                    LazyVGrid(columns: twoCols, alignment: .leading, spacing: 10) {
                        Toggle("Mode USB OTG Tanpa Video (--otg)", isOn: $vm.otgMode)
                        Toggle("Injeksi Karakter sebagai Teks (--prefer-text)", isOn: $vm.preferText)
                        Toggle("Raw Key Events untuk Game (--raw-key-events)", isOn: $vm.rawKeyEvents)
                        Toggle("Hindari Pengulangan Tombol (--no-key-repeat)", isOn: $vm.noKeyRepeat)
                        Toggle("Legacy Paste via Key Events (--legacy-paste)", isOn: $vm.legacyPaste)
                        Toggle("Matikan Sinkronisasi Clipboard Otomatis", isOn: $vm.noClipboardSync)
                        Toggle("Abaikan Gerakan Hover Mouse (--no-mouse-hover)", isOn: $vm.noMouseHover)
                    }
                }
                .padding(10)
            }
        }
    }
}

// MARK: - 6. App Manager Section

struct AppManagerSectionView: View {
    @ObservedObject var vm: ScrcpyPlusViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                TextField("Cari nama aplikasi atau package (mis. whatsapp, chrome, game)...", text: $vm.appSearchQuery)
                    .textFieldStyle(.roundedBorder)

                Toggle("Tampilkan App Sistem", isOn: $vm.showSystemApps)

                Button {
                    vm.loadInstalledApps()
                } label: {
                    Label(vm.isLoadingApps ? "Memuat..." : "Muat Daftar Aplikasi HP", systemImage: "arrow.triangle.2.circlepath")
                }
                .buttonStyle(.borderedProminent)
                .disabled(vm.isLoadingApps)
            }

            if vm.installedApps.isEmpty {
                GroupBox {
                    VStack(spacing: 10) {
                        Image(systemName: "apps.iphone")
                            .font(.system(size: 36))
                            .foregroundStyle(.secondary)
                        Text("Klik 'Muat Daftar Aplikasi HP' untuk mengambil semua aplikasi yang ter-install di perangkat Android Anda.")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(32)
                }
            } else {
                Text("Menampilkan \(vm.filteredApps.count) aplikasi")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)

                LazyVStack(spacing: 6) {
                    ForEach(vm.filteredApps) { app in
                        HStack {
                            Image(systemName: app.symbolName)
                                .foregroundStyle(app.accentColor)
                                .font(.system(size: 16))
                                .frame(width: 24)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(app.appName)
                                    .font(.system(size: 13, weight: .semibold))
                                Text(app.packageName)
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button {
                                vm.launchSpecificApp(app, inVirtualDisplay: false)
                            } label: {
                                Label("Mirror", systemImage: "play.fill")
                            }
                            .controlSize(.small)

                            Button {
                                vm.spawnDetachedDeXWindow(appName: app.appName, packageQuery: app.packageName, icon: app.symbolName, isPiP: true)
                            } label: {
                                Label("PiP", systemImage: "pip.enter")
                            }
                            .controlSize(.small)
                            .help("Buka sebagai jendela kecil mengambang Always-on-Top")

                            Button {
                                vm.spawnDetachedDeXWindow(appName: app.appName, packageQuery: app.packageName, icon: app.symbolName, isPiP: false)
                            } label: {
                                Label("+Window Baru", systemImage: "macwindow.badge.plus")
                            }
                            .controlSize(.small)
                            .help("Pisah ke jendela DeX mandiri baru")

                            Button {
                                let old = vm.dexOpenInNewWindow
                                vm.dexOpenInNewWindow = false
                                vm.launchSpecificApp(app, inVirtualDisplay: true)
                                vm.dexOpenInNewWindow = old
                            } label: {
                                Label("Buka di Jendela DeX", systemImage: "sparkles.tv.fill")
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(nsColor: .controlBackgroundColor))
                        )
                    }
                }
            }
        }
    }
}

// MARK: - 7. Remote Control & File Drop Section

struct RemoteFilesSectionView: View {
    @ObservedObject var vm: ScrcpyPlusViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                GroupBox("Remote Navigasi & Media Android") {
                    VStack(spacing: 12) {
                        HStack(spacing: 10) {
                            Button { vm.sendKeyevent("3", label: "Home") } label: { Label("Home", systemImage: "house.fill").frame(width: 90) }
                            Button { vm.sendKeyevent("4", label: "Back") } label: { Label("Back", systemImage: "chevron.backward").frame(width: 90) }
                            Button { vm.sendKeyevent("187", label: "Recent") } label: { Label("Recent", systemImage: "square.stack.3d.up.fill").frame(width: 90) }
                        }
                        HStack(spacing: 10) {
                            Button { vm.sendKeyevent("83", label: "Notifikasi") } label: { Label("Notifikasi", systemImage: "bell.badge.fill").frame(width: 90) }
                            Button { vm.sendKeyevent("26", label: "Power") } label: { Label("Power", systemImage: "power").frame(width: 90) }
                            Button { vm.sendKeyevent("223", label: "Sleep") } label: { Label("Lock", systemImage: "lock.fill").frame(width: 90) }
                        }

                        Divider()

                        VStack(spacing: 6) {
                            Button { vm.sendKeyevent("19", label: "Atas") } label: { Image(systemName: "chevron.up").frame(width: 44, height: 24) }
                            HStack(spacing: 6) {
                                Button { vm.sendKeyevent("21", label: "Kiri") } label: { Image(systemName: "chevron.left").frame(width: 44, height: 24) }
                                Button { vm.sendKeyevent("23", label: "OK") } label: { Text("OK").frame(width: 44, height: 24) }
                                Button { vm.sendKeyevent("22", label: "Kanan") } label: { Image(systemName: "chevron.right").frame(width: 44, height: 24) }
                            }
                            Button { vm.sendKeyevent("20", label: "Bawah") } label: { Image(systemName: "chevron.down").frame(width: 44, height: 24) }
                        }

                        Divider()

                        HStack(spacing: 8) {
                            Button { vm.sendKeyevent("88", label: "Prev") } label: { Image(systemName: "backward.fill") }
                            Button { vm.sendKeyevent("85", label: "Play/Pause") } label: { Image(systemName: "playpause.fill") }
                            Button { vm.sendKeyevent("87", label: "Next") } label: { Image(systemName: "forward.fill") }
                            Button { vm.sendKeyevent("164", label: "Mute") } label: { Image(systemName: "speaker.slash.fill") }
                            Button { vm.sendKeyevent("220", label: "Redup") } label: { Image(systemName: "sun.min.fill") }
                            Button { vm.sendKeyevent("221", label: "Terang") } label: { Image(systemName: "sun.max.fill") }
                        }
                    }
                    .padding(10)
                }

                VStack(alignment: .leading, spacing: 14) {
                    GroupBox("Install APK & Transfer File Cepat") {
                        VStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [6]))
                                    .foregroundStyle(vm.isDropTargeted ? Color.accentColor : Color.secondary.opacity(0.4))
                                    .background(vm.isDropTargeted ? Color.accentColor.opacity(0.1) : Color.clear)

                                VStack(spacing: 6) {
                                    Image(systemName: "arrow.down.doc.fill")
                                        .font(.system(size: 26))
                                        .foregroundStyle(Color.accentColor)
                                    Text("Tarik & Lepas (Drag & Drop) file .APK atau file apa pun ke sini")
                                        .font(.system(size: 12.5, weight: .semibold))
                                    Text("File .apk otomatis di-install; file lainnya dikirim ke /sdcard/Download/")
                                        .font(.system(size: 11))
                                        .foregroundStyle(.secondary)
                                }
                                .padding(16)
                            }
                            .frame(height: 110)
                            .onDrop(of: [.fileURL], isTargeted: $vm.isDropTargeted) { providers in
                                for provider in providers {
                                    _ = provider.loadObject(ofClass: URL.self) { url, _ in
                                        if let url = url {
                                            Task { @MainActor in
                                                vm.handleDroppedFiles([url])
                                            }
                                        }
                                    }
                                }
                                return true
                            }

                            HStack {
                                Button {
                                    vm.promptInstallAPK()
                                } label: {
                                    Label("Pilih & Install APK...", systemImage: "shippingbox.fill")
                                }

                                Button {
                                    vm.promptPushFile()
                                } label: {
                                    Label("Kirim File ke Download...", systemImage: "folder.badge.plus")
                                }
                            }
                        }
                        .padding(8)
                    }

                    GroupBox("Injeksi Teks & Sinkronisasi Clipboard 2 Arah") {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                TextField("Ketik teks/password untuk dikirim ke HP...", text: $vm.remoteTextToSend)
                                    .textFieldStyle(.roundedBorder)
                                    .onSubmit {
                                        vm.sendRemoteText()
                                    }
                                Button("Kirim Teks") {
                                    vm.sendRemoteText()
                                }
                                .buttonStyle(.borderedProminent)

                                Button {
                                    vm.syncMacClipboardToPhone()
                                } label: {
                                    Label("Paste Clipboard Mac → HP", systemImage: "doc.on.clipboard.fill")
                                }
                            }

                            if !vm.clipboardHistory.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 6) {
                                        Text("Riwayat:")
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundStyle(.secondary)
                                        ForEach(vm.clipboardHistory, id: \.self) { clip in
                                            Button {
                                                vm.remoteTextToSend = clip
                                                vm.sendRemoteText()
                                            } label: {
                                                Text(clip)
                                                    .lineLimit(1)
                                                    .frame(maxWidth: 160)
                                                    .font(.system(size: 11))
                                            }
                                            .buttonStyle(.bordered)
                                            .controlSize(.mini)
                                            .help("Klik untuk mengirim ulang ke HP")
                                        }
                                    }
                                }
                            }

                            Divider()

                            HStack(spacing: 8) {
                                Text("Macro Cepat:")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(.secondary)
                                Button("Wake & Unlock") { vm.runQuickMacro("wake_unlock") }
                                Button("Scroll Bawah") { vm.runQuickMacro("scroll_down") }
                                Button("Scroll Atas") { vm.runQuickMacro("scroll_up") }
                                Button("Quick Settings") { vm.runQuickMacro("quick_settings") }
                            }
                            .controlSize(.small)
                        }
                        .padding(8)
                    }
                }
            }

            // 2-Way File Manager (Browse & Pull Files/Photos from Android to Mac!)
            GroupBox("File Explorer Android 2 Arah (Unduh Foto Kamera & File HP → Mac)") {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Text("Folder HP:")
                            .font(.system(size: 12, weight: .semibold))
                        ForEach([
                            ("Download", "/sdcard/Download"),
                            ("Kamera (DCIM)", "/sdcard/DCIM/Camera"),
                            ("Screenshots", "/sdcard/Pictures/Screenshots"),
                            ("Documents", "/sdcard/Documents"),
                            ("Pictures", "/sdcard/Pictures")
                        ], id: \.1) { folder in
                            Button(folder.0) {
                                vm.loadAndroidFiles(dir: folder.1)
                            }
                            .buttonStyle(.bordered)
                            .tint(vm.currentAndroidDir == folder.1 ? .accentColor : .secondary)
                            .controlSize(.small)
                        }
                        Spacer()
                        Button {
                            vm.loadAndroidFiles()
                        } label: {
                            Label(vm.isLoadingFiles ? "Memuat..." : "Muat Isi Folder", systemImage: "arrow.clockwise")
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    }

                    if vm.androidFiles.isEmpty {
                        Text("Klik salah satu tombol folder di atas (mis. Download atau Kamera) untuk melihat & mengunduh file dari HP ke Mac.")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 6)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 4) {
                                ForEach(vm.androidFiles) { file in
                                    HStack {
                                        Image(systemName: file.isDirectory ? "folder.fill" : "doc.fill")
                                            .foregroundStyle(file.isDirectory ? .orange : .accentColor)
                                        Text(file.name)
                                            .font(.system(size: 12, weight: .medium))
                                            .lineLimit(1)
                                        Spacer()
                                        if file.isDirectory {
                                            Button("Buka Folder") {
                                                vm.loadAndroidFiles(dir: file.fullPath)
                                            }
                                            .controlSize(.mini)
                                        } else {
                                            Button {
                                                vm.pullAndroidFile(file)
                                            } label: {
                                                Label("Download ke Mac (Pull)", systemImage: "arrow.down.circle.fill")
                                            }
                                            .buttonStyle(.borderedProminent)
                                            .controlSize(.small)
                                        }
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(RoundedRectangle(cornerRadius: 6).fill(Color(nsColor: .controlBackgroundColor)))
                                }
                            }
                        }
                        .frame(maxHeight: 170)
                    }
                }
                .padding(8)
            }

            GroupBox("Tangkapan Layar (Screenshot) Instan + Auto-Copy Clipboard") {
                HStack(spacing: 16) {
                    if let img = vm.lastScreenshotImage {
                        Image(nsImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.secondary.opacity(0.1))
                            .frame(width: 100, height: 120)
                            .overlay(Image(systemName: "photo").font(.title).foregroundStyle(.secondary))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text(vm.lastScreenshotPath.isEmpty ? "Screenshot otomatis disimpan ke Desktop & disalin ke Clipboard Mac (siap Cmd+V)" : vm.lastScreenshotPath)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundStyle(.secondary)

                        HStack {
                            Button {
                                vm.takeInstantScreenshot(fromDeXDisplay: false)
                            } label: {
                                Label("Screenshot Layar HP", systemImage: "camera.fill")
                            }
                            .buttonStyle(.borderedProminent)

                            Button {
                                vm.takeInstantScreenshot(fromDeXDisplay: true)
                            } label: {
                                Label("Screenshot Layar DeX", systemImage: "macwindow")
                            }
                            .buttonStyle(.bordered)

                            if !vm.lastScreenshotPath.isEmpty {
                                Button("Tampilkan di Finder") {
                                    NSWorkspace.shared.selectFile(vm.lastScreenshotPath, inFileViewerRootedAtPath: "")
                                }
                            }
                        }
                    }
                    Spacer()
                }
                .padding(8)
            }
        }
    }
}

// MARK: - 8. Wireless & Pairing Section

struct WirelessSectionView: View {
    @ObservedObject var vm: ScrcpyPlusViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            GroupBox("Koneksi ADB TCP/IP (Wi-Fi)") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Hubungkan perangkat tanpa kabel USB melalui jaringan Wi-Fi yang sama.")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)

                    HStack(spacing: 12) {
                        Text("IP:Port Perangkat:")
                        TextField("mis. 192.168.1.15:5555", text: $vm.tcpipAddress)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 220)

                        Button {
                            vm.connectWifiIP()
                        } label: {
                            Label("Connect IP", systemImage: "link")
                        }
                        .buttonStyle(.borderedProminent)

                        Button {
                            vm.bridgeUsbToWifi()
                        } label: {
                            Label("Auto USB → Wi-Fi (5555)", systemImage: "wifi")
                        }

                        Button(role: .destructive) {
                            vm.disconnectAllWifi()
                        } label: {
                            Label("Disconnect Semua", systemImage: "xmark.circle")
                        }
                    }

                    Divider()

                    // Local Network (LAN / mDNS / ARP Port 5555) Scanner
                    HStack(spacing: 12) {
                        Button {
                            vm.scanLocalWifiDevices()
                        } label: {
                            Label(vm.isScanningLan ? "Memindai LAN..." : "Scan Jaringan Lokal (LAN & mDNS)", systemImage: "dot.radiowaves.left.and.right")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.teal)
                        .disabled(vm.isScanningLan)

                        Text("IP Wi-Fi Mac: \(vm.macLocalIP)  •  IP Wi-Fi HP: \(vm.telemetry.ipAddress)")
                            .font(.system(size: 11.5, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }

                    if !vm.discoveredLanDevices.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Perangkat Terdeteksi di Jaringan Lokal (Klik untuk Connect):")
                                .font(.system(size: 11.5, weight: .bold))
                                .foregroundStyle(.teal)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(vm.discoveredLanDevices, id: \.self) { item in
                                        let hostOnly = item.split(whereSeparator: { $0.isWhitespace }).first.map(String.init) ?? item
                                        Button {
                                            vm.tcpipAddress = hostOnly
                                            vm.connectWifiIP()
                                        } label: {
                                            Label(item, systemImage: "antenna.radiowaves.left.and.right.circle.fill")
                                                .font(.system(size: 11.5, weight: .medium, design: .monospaced))
                                        }
                                        .buttonStyle(.borderedProminent)
                                        .tint(.teal)
                                        .controlSize(.small)
                                    }
                                }
                            }
                        }
                    }

                    Toggle("Auto-Reconnect Wi-Fi Otomatis saat aplikasi dibuka (Zero-Touch Wireless)", isOn: $vm.autoReconnectWifi)
                        .font(.system(size: 12, weight: .medium))

                    if !vm.savedWifiHosts.isEmpty {
                        HStack(spacing: 8) {
                            Text("Perangkat Wi-Fi Tersimpan:")
                                .font(.system(size: 11.5, weight: .semibold))
                                .foregroundStyle(.secondary)
                            ForEach(vm.savedWifiHosts, id: \.self) { host in
                                Button {
                                    vm.tcpipAddress = host
                                    vm.connectWifiIP()
                                } label: {
                                    Label(host, systemImage: "wifi.circle.fill")
                                        .font(.system(size: 11, design: .monospaced))
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                            }
                        }
                    }
                }
                .padding(10)
            }

            GroupBox("Wireless Debugging Pairing (Android 11+)") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Buka Pengaturan Developer Options → Wireless Debugging → Pair device with pairing code di HP Anda, lalu masukkan IP:Port & 6 digit kode di bawah:")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)

                    HStack(spacing: 12) {
                        Text("IP:Port Pairing:")
                        TextField("mis. 192.168.1.15:39123", text: $vm.pairAddress)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 200)

                        Text("Kode Pairing 6 Digit:")
                        TextField("mis. 482910", text: $vm.pairCode)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 120)

                        Button {
                            vm.pairDevice()
                        } label: {
                            Label("Pair Perangkat", systemImage: "checkmark.shield.fill")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(10)
            }
        }
        .onAppear {
            if vm.discoveredLanDevices.isEmpty {
                vm.scanLocalWifiDevices()
            }
        }
    }
}

// MARK: - 9. Logs & Diagnostic Tools Section

struct LogsToolsSectionView: View {
    @ObservedObject var vm: ScrcpyPlusViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Button {
                    vm.runSystemDoctor()
                } label: {
                    Label("Doctor & Auto-Fix ADB", systemImage: "stethoscope")
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)

                Button("Info Perangkat") { vm.runUtilityCommand(["--device-info"], status: "Memuat info perangkat") }
                Button("Status ADB") { vm.runUtilityCommand(["--status"], status: "Memeriksa status ADB") }
                Button("Daftar Kamera") { vm.runUtilityCommand(["--list-cameras"], status: "Memuat daftar kamera") }
                Button("Ukuran Kamera") { vm.runUtilityCommand(["--list-camera-sizes"], status: "Memuat ukuran kamera") }
                Button("Daftar Layar") { vm.runUtilityCommand(["--list-displays"], status: "Memuat daftar layar") }
                Button("Daftar Encoder") { vm.runUtilityCommand(["--list-encoders"], status: "Memuat daftar encoder") }

                Spacer()

                Button("Salin Log") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(vm.logText, forType: .string)
                    vm.statusMessage = "Log disalin ke clipboard"
                }

                Button("Bersihkan") {
                    vm.logText = ""
                }
            }
            .controlSize(.small)

            ScrollViewReader { proxy in
                ScrollView {
                    Text(vm.logText)
                        .font(.system(size: 11.5, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                        .padding(10)
                        .id("logBottom")
                }
                .frame(minHeight: 430)
                .background(Color(nsColor: .textBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.25)))
                .onChange(of: vm.logText) { _, _ in
                    proxy.scrollTo("logBottom", anchor: .bottom)
                }
            }
        }
    }
}

// MARK: - 10. How-To Guide & Developer Info Section

struct HowToStepItem: Identifiable {
    let id = UUID()
    let number: String
    let title: String
    let icon: String
    let color: Color
    let points: [String]
}

struct ShortcutGuideItem: Identifiable {
    let id = UUID()
    let keys: String
    let action: String
}

struct HowToAboutSectionView: View {
    @ObservedObject var vm: ScrcpyPlusViewModel

    let guideSteps: [HowToStepItem] = [
        HowToStepItem(
            number: "1",
            title: "Persiapan Awal di HP Android (Wajib Sekali Saja)",
            icon: "iphone.badge.play",
            color: .blue,
            points: [
                "Buka Pengaturan (Settings) → Tentang Ponsel (About Phone) → Ketuk 'Nomor Bentukan' (Build Number) 7 kali hingga muncul pesan Developer Options aktif.",
                "Masuk ke System → Developer Options (Opsi Pengembang) → Aktifkan 'USB Debugging'.",
                "Penting untuk kontrol penuh & DeX: Aktifkan juga 'USB debugging (Security settings)' / 'Disable permission monitoring' (jika ada di HP Anda) agar injeksi mouse, keyboard, dan peluncuran aplikasi di Virtual Display berjalan mulus.",
                "Saat menghubungkan kabel USB pertama kali ke Mac, centang 'Always allow from this computer' pada layar HP lalu ketuk Allow."
            ]
        ),
        HowToStepItem(
            number: "2",
            title: "Cara Koneksi Tanpa Kabel (Wi-Fi ADB & Jaringan Lokal)",
            icon: "wifi.router.fill",
            color: .teal,
            points: [
                "Pastikan Mac dan HP Android terhubung ke jaringan Wi-Fi atau Hotspot yang sama.",
                "Cara Paling Mudah (Auto USB → Wi-Fi): Colokkan kabel USB sebentar, klik tombol 'Aktifkan Wi-Fi' di Dashboard (atau 'Auto USB → Wi-Fi (5555)' di menu Wi-Fi & Pairing ADB). Setelah status terhubung, cabut kabel USB!",
                "Scan Jaringan Lokal (Tanpa USB): Buka menu 'Wi-Fi & Pairing ADB' lalu klik 'Scan Jaringan Lokal (LAN & mDNS)'. Klik tombol IP perangkat yang muncul untuk langsung terhubung.",
                "Jika muncul pesan 'No route to host' atau perangkat offline, klik tombol 'Doctor' di bagian atas untuk memperbaiki daemon ADB dan tabel ARP secara otomatis."
            ]
        ),
        HowToStepItem(
            number: "3",
            title: "Cara Menggunakan Mode Samsung DeX (Jendela Tunggal Landscape & Multi-App)",
            icon: "macwindow.on.rectangle",
            color: .purple,
            points: [
                "Buka menu 'DeX Desktop Workspace' lalu pilih orientasi 'Landscape (16:9 Horizontal Terkunci)' dan resolusi kanvas (mis. Full HD 1920x1080 atau Ultrawide 2560x1080).",
                "Klik 'Start DeX (1 Jendela)' atau klik ikon aplikasi apa saja di kanvas DeX / App Drawer. Jendela Desktop Android dan Floating DeX Taskbar akan terbuka.",
                "Berpindah Aplikasi di 1 Jendela: Klik aplikasi lain di Dock DeX, Start Menu, atau Floating DeX Taskbar — aplikasi akan langsung terbuka di dalam jendela DeX yang sama tanpa membuka jendela macOS baru!",
                "Multitasking & Split-Screen: Gunakan 'Paket Workspace 1-Klik' atau 'Split-Screen 2 Aplikasi' untuk menjalankan beberapa aplikasi berdampingan, atau aktifkan toggle 'Buka App di Jendela Mandiri Baru' jika ingin memisahkan aplikasi tertentu (mis. YouTube PiP)."
            ]
        ),
        HowToStepItem(
            number: "4",
            title: "Kamera / Webcam, Rekaman, & Transfer File 2 Arah (Mac ⇄ Android)",
            icon: "camera.aperture",
            color: .orange,
            points: [
                "Mode Kamera / Webcam (Android 12+): Pilih profil 'Camera / Webcam' di Dashboard atau atur di menu 'Video, Layar & Kamera' untuk menjadikan kamera HP sebagai webcam HD berkecepatan tinggi.",
                "Mode Layar Mati (Private Screen): Centang 'Matikan Layar HP (-S)' agar layar fisik HP mati dan hemat baterai sementara layar tetap tampil penuh di Mac.",
                "Install APK & Kirim File (Drag & Drop): Buka menu 'Remote & Kirim File', tarik file .apk atau dokumen dari Finder ke area Drop Zone untuk langsung meng-install atau mengirim ke /sdcard/Download/.",
                "Download File dari HP ke Mac (Pull) & Clipboard: Gunakan 'File Explorer Android 2 Arah' untuk mengunduh foto/dokumen dari HP ke folder Downloads Mac, atau gunakan 'Sinkronisasi Clipboard' untuk bertukar teks dengan cepat."
            ]
        )
    ]

    let shortcuts: [ShortcutGuideItem] = [
        ShortcutGuideItem(keys: "Option (⌥) + F", action: "Beralih mode Fullscreen / Jendela"),
        ShortcutGuideItem(keys: "Option (⌥) + H", action: "Tombol Home Android"),
        ShortcutGuideItem(keys: "Option (⌥) + B", action: "Tombol Back (Kembali)"),
        ShortcutGuideItem(keys: "Option (⌥) + S", action: "Tombol Recent Apps / App Switcher"),
        ShortcutGuideItem(keys: "Option (⌥) + P", action: "Tombol Power (Nyalakan/Matikan layar)"),
        ShortcutGuideItem(keys: "Option (⌥) + O", action: "Matikan layar fisik HP saja (Mirror tetap jalan)"),
        ShortcutGuideItem(keys: "Option (⌥) + Shift + O", action: "Nyalakan kembali layar fisik HP"),
        ShortcutGuideItem(keys: "Option (⌥) + R", action: "Putar orientasi layar scrcpy"),
        ShortcutGuideItem(keys: "Option (⌥) + G", action: "Ubah ukuran jendela ke 1:1 piksel asli"),
        ShortcutGuideItem(keys: "Option (⌥) + ↑ / ↓", action: "Perbesar / Perkecil Volume HP")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            // Developer Info Hero Card
            GroupBox {
                HStack(spacing: 18) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .indigo, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 68, height: 68)
                        Image(systemName: "person.crop.circle.badge.checkmark")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.white)
                    }

                    VStack(alignment: .leading, spacing: 5) {
                        HStack(spacing: 8) {
                            Text("Informasi Developer & Pembuat")
                                .font(.system(size: 11, weight: .bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.accentColor.opacity(0.15))
                                .foregroundStyle(Color.accentColor)
                                .clipShape(Capsule())

                            Text("scrcpy-plus v3.0 (macOS SwiftUI & DeX Edition)")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.secondary)
                        }

                        Text("Subuh Kurniawan")
                            .font(.system(size: 20, weight: .bold))

                        HStack(spacing: 6) {
                            Image(systemName: "envelope.fill")
                                .foregroundStyle(.secondary)
                            Text("kurrniawansubuh@gmail.com")
                                .font(.system(size: 13.5, weight: .semibold, design: .monospaced))
                                .textSelection(.enabled)
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 8) {
                        Button {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString("kurrniawansubuh@gmail.com", forType: .string)
                            vm.statusMessage = "Alamat email developer (kurrniawansubuh@gmail.com) disalin ke Clipboard"
                        } label: {
                            Label("Salin Email", systemImage: "doc.on.doc.fill")
                        }
                        .buttonStyle(.bordered)

                        Button {
                            if let url = URL(string: "mailto:kurrniawansubuh@gmail.com?subject=Feedback%20scrcpy-plus%20v3") {
                                NSWorkspace.shared.open(url)
                            }
                        } label: {
                            Label("Hubungi Developer", systemImage: "paperplane.fill")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(12)
            }

            // Quick Action Bar inside How-To
            HStack(spacing: 10) {
                Text("Panduan Lengkap Penggunaan (How-To Guide)")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
                Button {
                    vm.runSystemDoctor()
                } label: {
                    Label("Jalankan Doctor & Auto-Fix ADB", systemImage: "stethoscope")
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .controlSize(.small)

                Button {
                    vm.selectedSection = .wireless
                    vm.scanLocalWifiDevices()
                } label: {
                    Label("Scan Wi-Fi Lokal", systemImage: "wifi")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }

            // Step-by-Step Guide Cards
            ForEach(guideSteps) { step in
                GroupBox {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 10) {
                            Text(step.number)
                                .font(.system(size: 13, weight: .heavy))
                                .foregroundStyle(.white)
                                .frame(width: 26, height: 26)
                                .background(Circle().fill(step.color))

                            Image(systemName: step.icon)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(step.color)

                            Text(step.title)
                                .font(.system(size: 14, weight: .bold))
                        }

                        Divider()

                        VStack(alignment: .leading, spacing: 7) {
                            ForEach(step.points, id: \.self) { point in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 12))
                                        .foregroundStyle(step.color)
                                        .padding(.top, 2)
                                    Text(point)
                                        .font(.system(size: 12.5))
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                    .padding(10)
                }
            }

            // Keyboard Shortcuts Reference Table
            GroupBox("Pintasan Keyboard (Keyboard Shortcuts saat Jendela scrcpy / DeX Aktif)") {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 8) {
                    ForEach(shortcuts) { item in
                        HStack {
                            Text(item.keys)
                                .font(.system(size: 11.5, weight: .bold, design: .monospaced))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(RoundedRectangle(cornerRadius: 6).fill(Color.accentColor.opacity(0.14)))
                            Text(item.action)
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding(4)
                    }
                }
                .padding(8)
            }
        }
    }
}

// MARK: - App Entry & MenuBarExtra

@main
struct ScrcpyPlusSwiftApp: App {
    @StateObject private var vm = ScrcpyPlusViewModel()

    init() {
        NSApplication.shared.setActivationPolicy(.regular)
    }

    var body: some Scene {
        WindowGroup("scrcpy-plus v3") {
            MainWindowView(vm: vm)
                .onAppear {
                    let iconPath = (vm.workspacePath as NSString).appendingPathComponent("icon.png")
                    if let icon = NSImage(contentsOfFile: iconPath) {
                        NSApplication.shared.applicationIconImage = icon
                    }
                    NSApplication.shared.activate(ignoringOtherApps: true)
                }
        }
        .windowResizability(.contentMinSize)

        MenuBarExtra("scrcpy-plus", systemImage: (vm.isRunning || vm.isDeXSessionRunning) ? "iphone.radiowaves.left.and.right" : "iphone") {
            Text(vm.isDeXSessionRunning ? "Samsung DeX Aktif (Display #\(vm.activeDeXDisplayID))" : (vm.isRunning ? "Status: Sedang Berjalan (\(vm.profile))" : "Status: Siap"))
            Divider()
            Button("Start Samsung DeX (1 Jendela)") {
                vm.startSingleWindowDeXSession()
            }
            Button(vm.isRunning ? "Restart scrcpy" : "Start scrcpy") {
                vm.startScrcpy()
            }
            if vm.isRunning || vm.isDeXSessionRunning {
                Button("Stop Semua Sesi") {
                    vm.stopScrcpy()
                }
            }
            Divider()
            Menu("Pilih Profil Cepat") {
                ForEach(allProfiles) { p in
                    Button {
                        vm.profile = p.id
                        vm.startScrcpy()
                    } label: {
                        Text("\(p.title) — \(p.badge)")
                    }
                }
            }
            Button("Ambil Screenshot ke Desktop") {
                vm.takeInstantScreenshot()
            }
            Button("Refresh Perangkat ADB") {
                vm.refreshDevices()
            }
            Divider()
            Text("Developer: Subuh Kurniawan")
            Text("kurrniawansubuh@gmail.com")
            Divider()
            Button("Keluar scrcpy-plus") {
                vm.stopScrcpy()
                NSApplication.shared.terminate(nil)
            }
        }
    }
}
