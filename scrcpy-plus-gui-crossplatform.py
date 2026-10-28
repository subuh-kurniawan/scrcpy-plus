#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
scrcpy-plus v3 — Cross-Platform GUI Control Center (Windows & Linux Edition)
=============================================================================
Full-featured GUI launcher for scrcpy 3.x & ADB on Windows 10/11 and Linux.
Includes:
  - Single-Window Samsung DeX Desktop Engine + Floating Always-on-Top DeX Taskbar
  - DeX Landscape Lock (1920x1080 / 1280x800 / 2560x1080) & Live DPI Scaling
  - 1-Click DeX Workspace Bundles, Split-Screen Freeform & Picture-in-Picture (PiP)
  - Self-Healing Session Watchdog & 1-Click System/ADB Doctor
  - 5-Stage Android 11-15 wlan0 Wi-Fi IP Detector + Local LAN/mDNS/Port 5555 Scanner
  - 2-Way Android File Explorer (Push & Pull), APK Installer, Clipboard Sync & History
  - Complete How-To Guide & Developer Info

Developer : Subuh Kurniawan
Email     : kurrniawansubuh@gmail.com
"""

import json
import os
import platform
import re
import shutil
import socket
import subprocess
import sys
import threading
import time
import webbrowser
from datetime import datetime
from pathlib import Path
import tkinter as tk
from tkinter import ttk, filedialog, messagebox

IS_WINDOWS = platform.system().lower().startswith("win")
IS_LINUX = platform.system().lower().startswith("linux")
CREATE_NO_WINDOW = 0x08000000 if IS_WINDOWS else 0

CONFIG_DIR = Path.home() / (".scrcpy-plus" if not IS_WINDOWS else "AppData/Local/scrcpy-plus")
CONFIG_FILE = CONFIG_DIR / "gui-settings.json"


# =====================================================================
# Profiles, DeX Presets, Quick Apps, Workspace Bundles & How-To Data
# =====================================================================

ALL_PROFILES = [
    {"id": "gaming", "title": "Gaming", "badge": "60 FPS", "subtitle": "60 FPS, 20M bitrate, fullscreen & sentuhan aktif"},
    {"id": "desktop", "title": "DeX Desktop Mode", "badge": "Single/Multi", "subtitle": "Mode desktop ala Samsung DeX (semua app di 1 jendela Landscape)"},
    {"id": "productivity", "title": "Productivity", "badge": "Kerja", "subtitle": "Hemat daya, jaga HP menyala (-w), bitrate 8M"},
    {"id": "studio", "title": "Studio H.265", "badge": "H.265", "subtitle": "Visual tajam H.265 15M untuk konten & demo"},
    {"id": "recording", "title": "Recording", "badge": "30M Rec", "subtitle": "Rekam layar & audio otomatis kualitas 30M"},
    {"id": "presentation", "title": "Presentation", "badge": "Demo", "subtitle": "Fullscreen + indikator sentuhan untuk presentasi"},
    {"id": "private", "title": "Private Screen", "badge": "Layar Mati", "subtitle": "Layar fisik HP mati (-S), hanya tampil di PC"},
    {"id": "camera", "title": "Camera / Webcam", "badge": "Kamera", "subtitle": "Mirror kamera HP langsung (Android 12+)"},
    {"id": "audio-only", "title": "Audio Only", "badge": "Audio", "subtitle": "Streaming audio HP ke PC tanpa jendela video"},
    {"id": "low-latency", "title": "Low Latency", "badge": "Cepat", "subtitle": "Ringan & responsif (1024px, 4M, 60 FPS) untuk Wi-Fi"},
    {"id": "windowed", "title": "Windowed", "badge": "Jendela", "subtitle": "Jendela desktop standar 9M bitrate"},
    {"id": "debug", "title": "Debug & FPS", "badge": "Dev", "subtitle": "Tampilkan sentuhan & pantau FPS di konsol"},
    {"id": "otg", "title": "USB OTG", "badge": "HID OTG", "subtitle": "Keyboard & mouse fisik lewat USB tanpa video"},
    {"id": "default", "title": "Default", "badge": "Standar", "subtitle": "Pengaturan standar bawaan scrcpy"},
]

DEX_PRESETS = [
    {"id": "fhd-160", "title": "Landscape Full HD (16:9)", "spec": "1920x1080/160", "w": "1280", "h": "720", "portrait": False},
    {"id": "dex-1280", "title": "Landscape Laptop (16:10)", "spec": "1280x800/180", "w": "1150", "h": "720", "portrait": False},
    {"id": "ultrawide-21-9", "title": "Landscape Ultrawide (21:9)", "spec": "2560x1080/180", "w": "1440", "h": "610", "portrait": False},
    {"id": "qhd-220", "title": "Landscape QHD 2K (16:9)", "spec": "2560x1440/220", "w": "1360", "h": "765", "portrait": False},
    {"id": "hd-140", "title": "Landscape HD Ringan", "spec": "1280x720/140", "w": "1024", "h": "576", "portrait": False},
    {"id": "portrait-320", "title": "Portrait Vertikal (9:16)", "spec": "1080x1920/320", "w": "410", "h": "730", "portrait": True},
]

DEX_QUICK_APPS = [
    ("Chrome", "chrome"),
    ("YouTube", "youtube"),
    ("WhatsApp", "whatsapp"),
    ("Telegram", "telegram"),
    ("Instagram", "instagram"),
    ("Facebook", "facebook"),
    ("CapCut", "capcut"),
    ("Files", "documentsui"),
    ("Gmail", "gm"),
    ("Maps", "maps"),
    ("Kamera", "camera"),
    ("Settings", "com.android.settings"),
]

DEX_WORKSPACE_BUNDLES = [
    {
        "title": "Kerja & Riset",
        "subtitle": "Chrome + Gmail + Files",
        "freeform": True,
        "apps": [("Chrome", "chrome"), ("Gmail", "gm"), ("Files", "documentsui")],
    },
    {
        "title": "Komunikasi & Chat",
        "subtitle": "WhatsApp + Telegram + Chrome",
        "freeform": True,
        "apps": [("WhatsApp", "whatsapp"), ("Telegram", "telegram"), ("Chrome", "chrome")],
    },
    {
        "title": "Hiburan & Media",
        "subtitle": "YouTube + Chrome + Musik",
        "freeform": False,
        "apps": [("YouTube", "youtube"), ("Chrome", "chrome")],
    },
    {
        "title": "Kreator & Sosmed",
        "subtitle": "CapCut + Instagram + Galeri",
        "freeform": True,
        "apps": [("CapCut", "capcut"), ("Instagram", "instagram")],
    },
]


# =====================================================================
# Cross-Platform Process & Network Utilities
# =====================================================================

def find_binary(name: str, workspace: Path) -> str:
    exe_name = f"{name}.exe" if IS_WINDOWS else name
    candidate = workspace / exe_name
    if candidate.is_file():
        return str(candidate)
    candidate_plain = workspace / name
    if candidate_plain.is_file():
        return str(candidate_plain)
    found = shutil.which(exe_name) or shutil.which(name)
    return found if found else exe_name


def run_capture(args: list, timeout: float = 8.0, cwd: str = None) -> str:
    try:
        proc = subprocess.run(
            args,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=timeout,
            cwd=cwd,
            creationflags=CREATE_NO_WINDOW,
        )
        return proc.stdout or ""
    except subprocess.TimeoutExpired:
        return "[Timeout]"
    except Exception as exc:
        return f"Error: {exc}"


def get_pc_local_ip() -> str:
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
            s.settimeout(0.5)
            s.connect(("8.8.8.8", 80))
            ip = s.getsockname()[0]
            if ip and not ip.startswith("127."):
                return ip
    except Exception:
        pass
    try:
        hostname = socket.gethostname()
        for addr in socket.gethostbyname_ex(hostname)[2]:
            if not addr.startswith("127."):
                return addr
    except Exception:
        pass
    return "-"


# =====================================================================
# Main Application Window
# =====================================================================

class ScrcpyPlusCrossPlatformGUI(tk.Tk):
    def __init__(self):
        super().__init__()
        self.workspace_dir = Path(__file__).resolve().parent
        self.adb_bin = find_binary("adb", self.workspace_dir)
        self.scrcpy_bin = find_binary("scrcpy", self.workspace_dir)

        os_label = "Windows" if IS_WINDOWS else ("Linux" if IS_LINUX else platform.system())
        self.title(f"scrcpy-plus v3 — Control Center & Samsung DeX ({os_label} Edition)")
        self.geometry("1160x760")
        self.minsize(980, 660)
        self.configure(bg="#111827")

        # Runtime State
        self.scrcpy_proc = None
        self.detached_procs = []
        self.user_requested_stop = False
        self.recovery_attempts = 0
        self.is_running = False
        self.is_dex_running = False
        self.active_dex_display_id = "auto"
        self.dex_running_apps = []  # list of (app_name, pkg)
        self.dex_opened_pkgs = set()
        self.installed_apps = []  # list of (app_name, pkg, is_system)
        self.floating_taskbar_win = None

        # Telemetry State
        self.devices_list = []  # list of (serial, label)
        self.telemetry = {
            "manufacturer": "-",
            "model": "-",
            "android": "-",
            "sdk": "-",
            "battery": 0,
            "temp": "-",
            "ram": "-",
            "size": "-",
            "ip": "-",
        }

        # Persistent Settings & Variables
        self._init_variables()
        self._load_settings()
        self._configure_styles()
        self._build_layout()

        self.protocol("WM_DELETE_WINDOW", self._on_close)

        # Initial Startup Tasks
        self.after(200, self.refresh_devices)
        self.after(900, self._auto_reconnect_startup)
        self.after(15000, self._periodic_telemetry_tick)

    # -----------------------------------------------------------------
    # State Variables & Persistence
    # -----------------------------------------------------------------
    def _init_variables(self):
        self.selected_serial_var = tk.StringVar(value="")
        self.status_var = tk.StringVar(value="Siap menjalankan scrcpy")
        self.pc_ip_var = tk.StringVar(value=get_pc_local_ip())

        # Profile & Quick Options
        self.profile_var = tk.StringVar(value="default")
        self.wireless_var = tk.BooleanVar(value=False)
        self.fullscreen_var = tk.BooleanVar(value=False)
        self.windowed_var = tk.BooleanVar(value=False)
        self.screen_off_var = tk.BooleanVar(value=False)
        self.power_off_close_var = tk.BooleanVar(value=False)
        self.show_touches_var = tk.BooleanVar(value=False)
        self.stay_awake_var = tk.BooleanVar(value=False)
        self.no_control_var = tk.BooleanVar(value=False)
        self.borderless_var = tk.BooleanVar(value=False)
        self.always_on_top_var = tk.BooleanVar(value=False)
        self.disable_screensaver_var = tk.BooleanVar(value=False)
        self.audio_dup_var = tk.BooleanVar(value=False)
        self.no_audio_var = tk.BooleanVar(value=False)
        self.no_video_var = tk.BooleanVar(value=False)
        self.print_fps_var = tk.BooleanVar(value=False)
        self.record_enabled_var = tk.BooleanVar(value=False)
        self.auto_recover_var = tk.BooleanVar(value=True)
        self.auto_reconnect_wifi_var = tk.BooleanVar(value=True)

        # DeX Settings
        self.dex_spec_var = tk.StringVar(value="1920x1080/160")
        self.dex_win_w_var = tk.StringVar(value="1280")
        self.dex_win_h_var = tk.StringVar(value="720")
        self.dex_orientation_var = tk.StringVar(value="landscape")
        self.dex_freeform_var = tk.BooleanVar(value=False)
        self.dex_open_new_win_var = tk.BooleanVar(value=False)
        self.dex_force_stop_var = tk.BooleanVar(value=True)
        self.dex_no_decor_var = tk.BooleanVar(value=True)
        self.dex_keep_content_var = tk.BooleanVar(value=True)
        self.dex_dpi_var = tk.IntVar(value=160)
        self.split_left_var = tk.StringVar(value="chrome")
        self.split_right_var = tk.StringVar(value="whatsapp")

        # Video & Camera
        self.video_codec_var = tk.StringVar(value="default")
        self.max_size_var = tk.StringVar(value="default")
        self.bitrate_var = tk.StringVar(value="")
        self.fps_var = tk.StringVar(value="")
        self.render_driver_var = tk.StringVar(value="default")
        self.orientation_var = tk.StringVar(value="default")
        self.capture_orientation_var = tk.StringVar(value="")
        self.crop_var = tk.StringVar(value="")
        self.display_id_var = tk.StringVar(value="")
        self.video_buffer_var = tk.StringVar(value="")
        self.video_source_var = tk.StringVar(value="default")
        self.camera_facing_var = tk.StringVar(value="default")
        self.camera_id_var = tk.StringVar(value="")
        self.camera_size_var = tk.StringVar(value="")
        self.camera_ar_var = tk.StringVar(value="")
        self.camera_fps_var = tk.StringVar(value="")
        self.camera_high_speed_var = tk.BooleanVar(value=False)

        # Audio & Record
        self.audio_source_var = tk.StringVar(value="default")
        self.audio_codec_var = tk.StringVar(value="default")
        self.audio_bitrate_var = tk.StringVar(value="")
        self.audio_buffer_var = tk.StringVar(value="")
        self.require_audio_var = tk.BooleanVar(value=False)
        self.record_format_var = tk.StringVar(value="mp4")
        self.no_playback_var = tk.BooleanVar(value=False)

        # Input & Window
        self.keyboard_mode_var = tk.StringVar(value="default")
        self.mouse_mode_var = tk.StringVar(value="default")
        self.gamepad_mode_var = tk.StringVar(value="default")
        self.shortcut_mod_var = tk.StringVar(value="default")
        self.otg_mode_var = tk.BooleanVar(value=False)
        self.prefer_text_var = tk.BooleanVar(value=False)
        self.raw_key_var = tk.BooleanVar(value=False)
        self.no_key_repeat_var = tk.BooleanVar(value=False)
        self.legacy_paste_var = tk.BooleanVar(value=False)
        self.no_clip_sync_var = tk.BooleanVar(value=False)
        self.no_mouse_hover_var = tk.BooleanVar(value=False)
        self.window_title_var = tk.StringVar(value="")
        self.start_app_var = tk.StringVar(value="")
        self.window_x_var = tk.StringVar(value="")
        self.window_y_var = tk.StringVar(value="")
        self.window_w_var = tk.StringVar(value="")
        self.window_h_var = tk.StringVar(value="")
        self.time_limit_var = tk.StringVar(value="")
        self.screen_off_timeout_var = tk.StringVar(value="")
        self.extra_args_var = tk.StringVar(value="")

        # Wireless, Remote & Files
        self.tcpip_addr_var = tk.StringVar(value="")
        self.pair_addr_var = tk.StringVar(value="")
        self.pair_code_var = tk.StringVar(value="")
        self.remote_text_var = tk.StringVar(value="")
        self.android_dir_var = tk.StringVar(value="/sdcard/Download")
        self.app_search_var = tk.StringVar(value="")
        self.show_sys_apps_var = tk.BooleanVar(value=False)
        self.custom_preset_name_var = tk.StringVar(value="")

        self.saved_presets = []
        self.saved_wifi_hosts = []
        self.clipboard_history = []
        self.discovered_lan = []

    def _load_settings(self):
        try:
            if CONFIG_FILE.is_file():
                data = json.loads(CONFIG_FILE.read_text(encoding="utf-8"))
                self.profile_var.set(data.get("profile", "default"))
                self.tcpip_addr_var.set(data.get("tcpip_addr", ""))
                self.dex_spec_var.set(data.get("dex_spec", "1920x1080/160"))
                self.dex_orientation_var.set(data.get("dex_orientation", "landscape"))
                self.auto_recover_var.set(data.get("auto_recover", True))
                self.auto_reconnect_wifi_var.set(data.get("auto_reconnect_wifi", True))
                self.saved_presets = data.get("saved_presets", [])
                self.saved_wifi_hosts = [h for h in data.get("saved_wifi_hosts", []) if not h.startswith("10.150.")]
                self.clipboard_history = data.get("clipboard_history", [])
        except Exception:
            pass

    def _save_settings(self):
        try:
            CONFIG_DIR.mkdir(parents=True, exist_ok=True)
            data = {
                "profile": self.profile_var.get(),
                "tcpip_addr": self.tcpip_addr_var.get(),
                "dex_spec": self.dex_spec_var.get(),
                "dex_orientation": self.dex_orientation_var.get(),
                "auto_recover": self.auto_recover_var.get(),
                "auto_reconnect_wifi": self.auto_reconnect_wifi_var.get(),
                "saved_presets": self.saved_presets,
                "saved_wifi_hosts": self.saved_wifi_hosts[:8],
                "clipboard_history": self.clipboard_history[:12],
            }
            CONFIG_FILE.write_text(json.dumps(data, indent=2), encoding="utf-8")
        except Exception:
            pass

    # -----------------------------------------------------------------
    # Theme & Layout Construction
    # -----------------------------------------------------------------
    def _configure_styles(self):
        style = ttk.Style(self)
        try:
            style.theme_use("clam")
        except Exception:
            pass

        bg_dark = "#111827"
        bg_card = "#1F2937"
        bg_input = "#374151"
        fg_main = "#F9FAFB"
        fg_muted = "#9CA3AF"
        accent = "#2563EB"
        accent_hover = "#1D4ED8"

        style.configure(".", background=bg_dark, foreground=fg_main, font=("Segoe UI" if IS_WINDOWS else "Sans", 10))
        style.configure("TFrame", background=bg_dark)
        style.configure("Card.TFrame", background=bg_card)
        style.configure("TLabel", background=bg_dark, foreground=fg_main)
        style.configure("Card.TLabel", background=bg_card, foreground=fg_main)
        style.configure("Muted.TLabel", background=bg_dark, foreground=fg_muted)
        style.configure("CardMuted.TLabel", background=bg_card, foreground=fg_muted)
        style.configure("Header.TLabel", font=("Segoe UI" if IS_WINDOWS else "Sans", 13, "bold"))
        style.configure("TLabelframe", background=bg_card, foreground=fg_main, bordercolor="#374151")
        style.configure("TLabelframe.Label", background=bg_card, foreground="#60A5FA", font=("Segoe UI" if IS_WINDOWS else "Sans", 10, "bold"))
        style.configure("TCheckbutton", background=bg_card, foreground=fg_main)
        style.map("TCheckbutton", background=[("active", bg_card)])
        style.configure("TEntry", fieldbackground=bg_input, foreground=fg_main, insertcolor=fg_main)
        style.configure("TCombobox", fieldbackground=bg_input, background=bg_input, foreground=fg_main)

        style.configure("TButton", background="#374151", foreground=fg_main, padding=(10, 5), borderwidth=0)
        style.map("TButton", background=[("active", "#4B5563")])

        style.configure("Accent.TButton", background=accent, foreground="#FFFFFF", font=("Segoe UI" if IS_WINDOWS else "Sans", 10, "bold"), padding=(12, 6))
        style.map("Accent.TButton", background=[("active", accent_hover)])

        style.configure("Success.TButton", background="#059669", foreground="#FFFFFF", font=("Segoe UI" if IS_WINDOWS else "Sans", 10, "bold"), padding=(10, 5))
        style.map("Success.TButton", background=[("active", "#047857")])

        style.configure("Danger.TButton", background="#DC2626", foreground="#FFFFFF", font=("Segoe UI" if IS_WINDOWS else "Sans", 10, "bold"), padding=(10, 5))
        style.map("Danger.TButton", background=[("active", "#B91C1C")])

        style.configure("Sidebar.TButton", background="#1F2937", foreground="#E5E7EB", anchor="w", padding=(12, 8), font=("Segoe UI" if IS_WINDOWS else "Sans", 10, "bold"))
        style.map("Sidebar.TButton", background=[("active", "#2563EB")])

    def _build_layout(self):
        # 1. Top Header Bar
        header = tk.Frame(self, bg="#0F172A", height=54, padx=14, pady=8)
        header.pack(side="top", fill="x")

        title_box = tk.Frame(header, bg="#0F172A")
        title_box.pack(side="left")
        self.header_title_lbl = tk.Label(title_box, text="scrcpy-plus v3", fg="#F9FAFB", bg="#0F172A", font=("Segoe UI" if IS_WINDOWS else "Sans", 13, "bold"))
        self.header_title_lbl.pack(anchor="w")
        self.header_sub_lbl = tk.Label(title_box, text="Control Center • Windows & Linux Edition", fg="#9CA3AF", bg="#0F172A", font=("Segoe UI" if IS_WINDOWS else "Sans", 9))
        self.header_sub_lbl.pack(anchor="w")

        actions_box = tk.Frame(header, bg="#0F172A")
        actions_box.pack(side="right")

        tk.Label(actions_box, text="Perangkat:", fg="#9CA3AF", bg="#0F172A").pack(side="left", padx=(0, 6))
        self.device_combo = ttk.Combobox(actions_box, textvariable=self.selected_serial_var, width=28, state="readonly")
        self.device_combo["values"] = ["Otomatis (Semua)"]
        self.device_combo.current(0)
        self.device_combo.bind("<<ComboboxSelected>>", lambda _e: self._on_device_selected())
        self.device_combo.pack(side="left", padx=(0, 6))

        ttk.Button(actions_box, text="Refresh", command=self.refresh_devices).pack(side="left", padx=3)
        ttk.Button(actions_box, text="Start DeX (1 Jendela)", style="Accent.TButton", command=self.start_single_window_dex).pack(side="left", padx=4)
        ttk.Button(actions_box, text="Mode PiP", command=self.start_pip_mirror).pack(side="left", padx=3)
        ttk.Button(actions_box, text="Screenshot", command=lambda: self.take_screenshot(from_dex=self.is_dex_running)).pack(side="left", padx=3)
        ttk.Button(actions_box, text="Doctor ADB", style="Success.TButton", command=self.run_system_doctor).pack(side="left", padx=3)
        ttk.Button(actions_box, text="How-To", command=lambda: self.show_section("howto")).pack(side="left", padx=3)

        # 2. Bottom Control Bar
        bottom = tk.Frame(self, bg="#0F172A", height=52, padx=14, pady=8)
        bottom.pack(side="bottom", fill="x")

        nav_keys = [
            ("Home", "3"),
            ("Back", "4"),
            ("Recent", "187"),
            ("Power", "26"),
            ("Vol -", "25"),
            ("Vol +", "24"),
        ]
        for label, code in nav_keys:
            ttk.Button(bottom, text=label, command=lambda c=code, l=label: self.send_keyevent(c, l)).pack(side="left", padx=2)

        tk.Label(bottom, textvariable=self.status_var, fg="#93C5FD", bg="#0F172A", font=("Segoe UI" if IS_WINDOWS else "Sans", 10, "bold")).pack(side="left", padx=14)

        self.start_btn = ttk.Button(bottom, text="▶ Start scrcpy", style="Accent.TButton", command=self.start_scrcpy)
        self.start_btn.pack(side="right", padx=4)

        self.stop_btn = ttk.Button(bottom, text="■ Stop Sesi", style="Danger.TButton", command=self.stop_scrcpy)
        self.stop_btn.pack(side="right", padx=4)

        # 3. Main Body (Sidebar + Scrollable Content Area)
        body = tk.Frame(self, bg="#111827")
        body.pack(side="top", fill="both", expand=True)

        sidebar = tk.Frame(body, bg="#1F2937", width=230, padx=8, pady=10)
        sidebar.pack(side="left", fill="y")
        sidebar.pack_propagate(False)

        self.sections = {}
        nav_items = [
            ("dashboard", "1. Dashboard & Profil"),
            ("dex", "2. DeX Desktop Workspace"),
            ("video", "3. Video, Layar & Kamera"),
            ("audio", "4. Audio & Perekaman"),
            ("input", "5. Input, HID & Jendela"),
            ("apps", "6. Manajer Aplikasi"),
            ("files", "7. Remote & File Explorer"),
            ("wireless", "8. Wi-Fi & Pairing ADB"),
            ("logs", "9. Log & Diagnostik"),
            ("howto", "10. How-To & Developer"),
        ]

        for sec_id, sec_title in nav_items:
            btn = ttk.Button(sidebar, text=sec_title, style="Sidebar.TButton", command=lambda s=sec_id: self.show_section(s))
            btn.pack(fill="x", pady=2)

        # Developer Badge at bottom of Sidebar
        dev_footer = tk.Frame(sidebar, bg="#111827", padx=8, pady=8)
        dev_footer.pack(side="bottom", fill="x", pady=(10, 0))
        tk.Label(dev_footer, text="Developer:", fg="#9CA3AF", bg="#111827", font=("Segoe UI" if IS_WINDOWS else "Sans", 8)).pack(anchor="w")
        tk.Label(dev_footer, text="Subuh Kurniawan", fg="#F9FAFB", bg="#111827", font=("Segoe UI" if IS_WINDOWS else "Sans", 9, "bold")).pack(anchor="w")
        tk.Label(dev_footer, text="kurrniawansubuh@gmail.com", fg="#60A5FA", bg="#111827", font=("Consolas" if IS_WINDOWS else "Monospace", 8)).pack(anchor="w")

        # Right Scrollable Container
        content_outer = tk.Frame(body, bg="#111827")
        content_outer.pack(side="left", fill="both", expand=True)

        self.canvas = tk.Canvas(content_outer, bg="#111827", highlightthickness=0)
        scrollbar = ttk.Scrollbar(content_outer, orient="vertical", command=self.canvas.yview)
        self.scroll_frame = ttk.Frame(self.canvas)

        self.scroll_frame.bind(
            "<Configure>",
            lambda _e: self.canvas.configure(scrollregion=self.canvas.bbox("all")),
        )
        self.canvas_window = self.canvas.create_window((0, 0), window=self.scroll_frame, anchor="nw")
        self.canvas.bind("<Configure>", lambda e: self.canvas.itemconfig(self.canvas_window, width=e.width))
        self.canvas.configure(yscrollcommand=scrollbar.set)

        self.canvas.pack(side="left", fill="both", expand=True, padx=14, pady=12)
        scrollbar.pack(side="right", fill="y")

        # Build all 10 section frames
        self._build_dashboard_section()
        self._build_dex_section()
        self._build_video_section()
        self._build_audio_section()
        self._build_input_section()
        self._build_apps_section()
        self._build_files_section()
        self._build_wireless_section()
        self._build_logs_section()
        self._build_howto_section()

        self.show_section("dashboard")

    def show_section(self, sec_id: str):
        for frame in self.sections.values():
            frame.pack_forget()
        if sec_id in self.sections:
            self.sections[sec_id].pack(fill="both", expand=True)
            self.canvas.yview_moveto(0)
        if sec_id == "wireless" and not self.discovered_lan:
            self.scan_local_wifi_devices()
        elif sec_id == "apps" and not self.installed_apps:
            self.load_installed_apps()
        elif sec_id == "files":
            self.load_android_files()

    # -----------------------------------------------------------------
    # Section 1: Dashboard & Profiles
    # -----------------------------------------------------------------
    def _build_dashboard_section(self):
        frame = ttk.Frame(self.scroll_frame)
        self.sections["dashboard"] = frame

        # Telemetry Card
        tele_box = ttk.LabelFrame(frame, text="Telemetri Perangkat Real-Time", padding=12)
        tele_box.pack(fill="x", pady=(0, 12))

        self.tele_device_lbl = ttk.Label(tele_box, text="Perangkat: Belum terdeteksi", style="Card.TLabel", font=("Segoe UI" if IS_WINDOWS else "Sans", 12, "bold"))
        self.tele_device_lbl.grid(row=0, column=0, sticky="w", padx=(0, 20))

        self.tele_batt_lbl = ttk.Label(tele_box, text="Baterai & Suhu: -", style="Card.TLabel")
        self.tele_batt_lbl.grid(row=0, column=1, sticky="w", padx=15)

        self.tele_ram_lbl = ttk.Label(tele_box, text="RAM: -", style="Card.TLabel")
        self.tele_ram_lbl.grid(row=0, column=2, sticky="w", padx=15)

        self.tele_res_lbl = ttk.Label(tele_box, text="Resolusi: -", style="Card.TLabel")
        self.tele_res_lbl.grid(row=1, column=0, sticky="w", pady=(6, 0))

        self.tele_ip_lbl = ttk.Label(tele_box, text="IP Wi-Fi (wlan0): -", style="Card.TLabel")
        self.tele_ip_lbl.grid(row=1, column=1, sticky="w", padx=15, pady=(6, 0))

        btn_row = ttk.Frame(tele_box, style="Card.TFrame")
        btn_row.grid(row=0, column=3, rowspan=2, padx=10, sticky="e")
        ttk.Button(btn_row, text="Aktifkan Wi-Fi (5555)", style="Accent.TButton", command=self.bridge_usb_to_wifi).pack(side="left", padx=4)
        ttk.Button(btn_row, text="Doctor ADB", style="Success.TButton", command=self.run_system_doctor).pack(side="left", padx=4)

        # Quick Feature Toggles
        opt_box = ttk.LabelFrame(frame, text="Opsi Cepat & Proteksi Sesi Otomatis", padding=10)
        opt_box.pack(fill="x", pady=(0, 12))

        toggles = [
            ("Wi-Fi Otomatis (--wireless)", self.wireless_var),
            ("Fullscreen (-f)", self.fullscreen_var),
            ("Matikan Layar HP (-S)", self.screen_off_var),
            ("Tampilkan Sentuhan (-t)", self.show_touches_var),
            ("Jaga HP Menyala (-w)", self.stay_awake_var),
            ("Duplikasi Audio (--audio-dup)", self.audio_dup_var),
            ("Selalu di Atas (Always on Top)", self.always_on_top_var),
            ("Tanpa Bingkai (Borderless)", self.borderless_var),
            ("Rekam Sesi ke File", self.record_enabled_var),
            ("Auto-Heal Sesi Putus (Watchdog)", self.auto_recover_var),
            ("Auto-Reconnect Wi-Fi Saat Buka", self.auto_reconnect_wifi_var),
        ]
        for idx, (text, var) in enumerate(toggles):
            ttk.Checkbutton(opt_box, text=text, variable=var, command=self._save_settings).grid(row=idx // 3, column=idx % 3, sticky="w", padx=10, pady=4)

        # Profile Selector Grid
        prof_box = ttk.LabelFrame(frame, text="Pilih Mode Profil Mirroring (Klik untuk Memilih)", padding=10)
        prof_box.pack(fill="x", pady=(0, 12))

        for idx, item in enumerate(ALL_PROFILES):
            r, c = divmod(idx, 3)
            p_btn = tk.Button(
                prof_box,
                text=f"[{item['badge']}] {item['title']}\n{item['subtitle']}",
                justify="left",
                anchor="w",
                bg="#1E293B",
                fg="#F8FAFC",
                activebackground="#2563EB",
                activeforeground="#FFFFFF",
                relief="flat",
                padx=10,
                pady=8,
                command=lambda pid=item["id"]: self._select_profile(pid),
            )
            p_btn.grid(row=r, column=c, sticky="nsew", padx=5, pady=5)
            prof_box.columnconfigure(c, weight=1)

    def _select_profile(self, pid: str):
        self.profile_var.set(pid)
        self.status_var.set(f"Profil dipilih: {pid}")
        self._save_settings()
        if pid == "desktop":
            self.show_section("dex")

    # -----------------------------------------------------------------
    # Section 2: Single-Window Samsung DeX Desktop Workspace
    # -----------------------------------------------------------------
    def _build_dex_section(self):
        frame = ttk.Frame(self.scroll_frame)
        self.sections["dex"] = frame

        banner = ttk.LabelFrame(frame, text="Samsung DeX Desktop Environment (Semua Aplikasi di Dalam 1 Jendela Landscape!)", padding=12)
        banner.pack(fill="x", pady=(0, 12))

        ttk.Label(
            banner,
            text="Buka Chrome, WhatsApp, YouTube, Telegram, dan File Manager di dalam 1 Jendela Desktop DeX tunggal tanpa membuka jendela baru!\n"
                 "Dilengkapi Floating DeX Taskbar, pengunci Mode Landscape 16:9 / 21:9, Live DPI Zoom Slider, dan Split-Screen.",
            style="Card.TLabel",
        ).pack(anchor="w", pady=(0, 8))

        top_dex_btns = ttk.Frame(banner, style="Card.TFrame")
        top_dex_btns.pack(fill="x")
        ttk.Button(top_dex_btns, text="▶ Start DeX (1 Jendela Landscape)", style="Accent.TButton", command=self.start_single_window_dex).pack(side="left", padx=4)
        ttk.Button(top_dex_btns, text="Tampilkan Floating DeX Taskbar", style="Success.TButton", command=self.show_floating_dex_taskbar).pack(side="left", padx=4)
        ttk.Button(top_dex_btns, text="Putar Landscape ⇄ Portrait", command=self.toggle_dex_orientation).pack(side="left", padx=4)
        ttk.Button(top_dex_btns, text="Screenshot Layar DeX", command=lambda: self.take_screenshot(from_dex=True)).pack(side="left", padx=4)

        # Orientation & Preset Bar
        cfg_box = ttk.LabelFrame(frame, text="Pengaturan Orientasi Landscape & Resolusi Kanvas DeX", padding=10)
        cfg_box.pack(fill="x", pady=(0, 12))

        orient_row = ttk.Frame(cfg_box, style="Card.TFrame")
        orient_row.pack(fill="x", pady=(0, 8))
        ttk.Label(orient_row, text="Orientasi DeX:", style="Card.TLabel").pack(side="left", padx=(0, 8))
        for mode_id, mode_lbl in [
            ("landscape", "Landscape (16:9 Horizontal Terkunci)"),
            ("landscape-reverse", "Landscape Terbalik"),
            ("portrait", "Portrait (Vertikal)"),
            ("auto", "Otomatis"),
        ]:
            ttk.Button(orient_row, text=mode_lbl, command=lambda m=mode_id: self.set_dex_orientation(m)).pack(side="left", padx=3)

        preset_row = ttk.Frame(cfg_box, style="Card.TFrame")
        preset_row.pack(fill="x", pady=4)
        ttk.Label(preset_row, text="Preset Resolusi DeX:", style="Card.TLabel").pack(side="left", padx=(0, 8))
        for p in DEX_PRESETS:
            ttk.Button(
                preset_row,
                text=p["title"],
                command=lambda item=p: self._apply_dex_preset(item),
            ).pack(side="left", padx=3)

        spec_row = ttk.Frame(cfg_box, style="Card.TFrame")
        spec_row.pack(fill="x", pady=6)
        ttk.Label(spec_row, text="Resolusi/DPI Virtual:", style="Card.TLabel").pack(side="left")
        ttk.Entry(spec_row, textvariable=self.dex_spec_var, width=18).pack(side="left", padx=6)
        ttk.Label(spec_row, text="Lebar Jendela:", style="Card.TLabel").pack(side="left")
        ttk.Entry(spec_row, textvariable=self.dex_win_w_var, width=7).pack(side="left", padx=4)
        ttk.Label(spec_row, text="Tinggi:", style="Card.TLabel").pack(side="left")
        ttk.Entry(spec_row, textvariable=self.dex_win_h_var, width=7).pack(side="left", padx=4)

        ttk.Label(spec_row, text="Live DPI Zoom:", style="Card.TLabel").pack(side="left", padx=(14, 4))
        dpi_scale = tk.Scale(spec_row, from_=120, to=320, orient="horizontal", variable=self.dex_dpi_var, bg="#1F2937", fg="#F9FAFB", highlightthickness=0, length=140)
        dpi_scale.pack(side="left", padx=4)
        ttk.Button(spec_row, text="Terapkan DPI Live", command=self.apply_live_dex_dpi).pack(side="left", padx=4)

        dex_toggles = ttk.Frame(cfg_box, style="Card.TFrame")
        dex_toggles.pack(fill="x", pady=4)
        ttk.Checkbutton(dex_toggles, text="Multi-App Freeform (Berdampingan di 1 Jendela)", variable=self.dex_freeform_var).pack(side="left", padx=8)
        ttk.Checkbutton(dex_toggles, text="Buka App di Jendela Mandiri Baru (Multi-Window)", variable=self.dex_open_new_win_var).pack(side="left", padx=8)
        ttk.Checkbutton(dex_toggles, text="Pindah App dari Layar HP (--force-stop awal)", variable=self.dex_force_stop_var).pack(side="left", padx=8)

        # Quick App Dock inside DeX Section
        quick_box = ttk.LabelFrame(frame, text="Peluncur Cepat Aplikasi di Dalam Jendela DeX (Klik untuk Buka / Pindah Aplikasi)", padding=10)
        quick_box.pack(fill="x", pady=(0, 12))

        for idx, (app_name, pkg_q) in enumerate(DEX_QUICK_APPS):
            r, c = divmod(idx, 6)
            ttk.Button(
                quick_box,
                text=f"🗔 {app_name}",
                command=lambda n=app_name, q=pkg_q: self.launch_dex_app(n, q),
            ).grid(row=r, column=c, sticky="ew", padx=4, pady=4)
            quick_box.columnconfigure(c, weight=1)

        # 1-Click Workspace Bundles & Split Screen
        bundle_box = ttk.LabelFrame(frame, text="Paket Workspace DeX 1-Klik & Split-Screen 2 Aplikasi", padding=10)
        bundle_box.pack(fill="x", pady=(0, 12))

        b_row = ttk.Frame(bundle_box, style="Card.TFrame")
        b_row.pack(fill="x", pady=(0, 8))
        for b in DEX_WORKSPACE_BUNDLES:
            ttk.Button(
                b_row,
                text=f"🚀 {b['title']} ({b['subtitle']})",
                command=lambda bundle=b: self.launch_dex_bundle(bundle),
            ).pack(side="left", padx=4)

        split_row = ttk.Frame(bundle_box, style="Card.TFrame")
        split_row.pack(fill="x")
        ttk.Label(split_row, text="Split-Screen Kiri:", style="Card.TLabel").pack(side="left")
        ttk.Entry(split_row, textvariable=self.split_left_var, width=16).pack(side="left", padx=6)
        ttk.Label(split_row, text="Kanan:", style="Card.TLabel").pack(side="left")
        ttk.Entry(split_row, textvariable=self.split_right_var, width=16).pack(side="left", padx=6)
        ttk.Button(split_row, text="Buka Split-Screen di DeX", style="Accent.TButton", command=self.launch_split_screen_dex).pack(side="left", padx=6)

    def _apply_dex_preset(self, preset: dict):
        self.dex_spec_var.set(preset["spec"])
        self.dex_win_w_var.set(preset["w"])
        self.dex_win_h_var.set(preset["h"])
        self.dex_orientation_var.set("portrait" if preset["portrait"] else "landscape")
        self._save_settings()
        if self.is_dex_running:
            self.apply_live_dex_rotation(self.dex_orientation_var.get())

    # -----------------------------------------------------------------
    # Section 3: Video, Display & Camera
    # -----------------------------------------------------------------
    def _build_video_section(self):
        frame = ttk.Frame(self.scroll_frame)
        self.sections["video"] = frame

        vbox = ttk.LabelFrame(frame, text="Kualitas Video, Codec & Layar", padding=12)
        vbox.pack(fill="x", pady=(0, 12))

        fields = [
            ("Video Codec (default/h264/h265/av1):", self.video_codec_var),
            ("Batas Resolusi (--max-size, mis. 1920):", self.max_size_var),
            ("Bitrate Video (-b, mis. 16M):", self.bitrate_var),
            ("Maksimum FPS (--max-fps, mis. 60):", self.fps_var),
            ("Render Driver (default/opengl/vulkan/direct3d):", self.render_driver_var),
            ("Orientasi Tampilan (default/0/90/180/270):", self.orientation_var),
            ("Capture Orientation (mis. @0, 90):", self.capture_orientation_var),
            ("Crop Layar (W:H:X:Y):", self.crop_var),
            ("Display ID (--display-id):", self.display_id_var),
            ("Video Buffer (ms):", self.video_buffer_var),
        ]
        for idx, (lbl, var) in enumerate(fields):
            r, c = divmod(idx, 2)
            ttk.Label(vbox, text=lbl, style="Card.TLabel").grid(row=r, column=c * 2, sticky="w", padx=6, pady=5)
            ttk.Entry(vbox, textvariable=var, width=18).grid(row=r, column=c * 2 + 1, sticky="w", padx=6, pady=5)

        cbox = ttk.LabelFrame(frame, text="Mirroring Kamera / Webcam (Android 12+)", padding=12)
        cbox.pack(fill="x", pady=(0, 12))

        cam_fields = [
            ("Sumber Video (default/display/camera):", self.video_source_var),
            ("Arah Kamera (default/back/front/external):", self.camera_facing_var),
            ("Camera ID (--camera-id):", self.camera_id_var),
            ("Resolusi Kamera (--camera-size, mis. 1920x1080):", self.camera_size_var),
            ("Rasio Aspek (--camera-ar, mis. 16:9):", self.camera_ar_var),
            ("FPS Kamera (--camera-fps, mis. 60):", self.camera_fps_var),
        ]
        for idx, (lbl, var) in enumerate(cam_fields):
            r, c = divmod(idx, 2)
            ttk.Label(cbox, text=lbl, style="Card.TLabel").grid(row=r, column=c * 2, sticky="w", padx=6, pady=5)
            ttk.Entry(cbox, textvariable=var, width=18).grid(row=r, column=c * 2 + 1, sticky="w", padx=6, pady=5)

        ttk.Checkbutton(cbox, text="Mode Kamera High-Speed (--camera-high-speed)", variable=self.camera_high_speed_var).grid(row=3, column=0, columnspan=2, sticky="w", padx=6, pady=6)

    # -----------------------------------------------------------------
    # Section 4: Audio & Recording
    # -----------------------------------------------------------------
    def _build_audio_section(self):
        frame = ttk.Frame(self.scroll_frame)
        self.sections["audio"] = frame

        abox = ttk.LabelFrame(frame, text="Streaming Audio (Android 11+)", padding=12)
        abox.pack(fill="x", pady=(0, 12))

        a_fields = [
            ("Sumber Audio (default/output/mic/playback/voice-call):", self.audio_source_var),
            ("Codec Audio (default/opus/aac/flac/raw):", self.audio_codec_var),
            ("Bitrate Audio (mis. 128K):", self.audio_bitrate_var),
            ("Buffer Audio (ms, mis. 50):", self.audio_buffer_var),
        ]
        for idx, (lbl, var) in enumerate(a_fields):
            ttk.Label(abox, text=lbl, style="Card.TLabel").grid(row=idx, column=0, sticky="w", padx=6, pady=5)
            ttk.Entry(abox, textvariable=var, width=22).grid(row=idx, column=1, sticky="w", padx=6, pady=5)

        ttk.Checkbutton(abox, text="Duplikasi Audio di HP & PC (--audio-dup)", variable=self.audio_dup_var).grid(row=4, column=0, sticky="w", padx=6, pady=4)
        ttk.Checkbutton(abox, text="Matikan Audio (--no-audio)", variable=self.no_audio_var).grid(row=4, column=1, sticky="w", padx=6, pady=4)

        rbox = ttk.LabelFrame(frame, text="Perekaman Layar & Audio ke File", padding=12)
        rbox.pack(fill="x", pady=(0, 12))
        ttk.Checkbutton(rbox, text="Aktifkan Perekaman Saat Start", variable=self.record_enabled_var).grid(row=0, column=0, sticky="w", padx=6, pady=4)
        ttk.Label(rbox, text="Format Rekaman (mp4/mkv/opus/wav):", style="Card.TLabel").grid(row=1, column=0, sticky="w", padx=6, pady=4)
        ttk.Entry(rbox, textvariable=self.record_format_var, width=14).grid(row=1, column=1, sticky="w", padx=6, pady=4)
        ttk.Checkbutton(rbox, text="Rekam Tanpa Menampilkan Video (--no-playback)", variable=self.no_playback_var).grid(row=2, column=0, columnspan=2, sticky="w", padx=6, pady=4)

    # -----------------------------------------------------------------
    # Section 5: Input, HID & Window
    # -----------------------------------------------------------------
    def _build_input_section(self):
        frame = ttk.Frame(self.scroll_frame)
        self.sections["input"] = frame

        ibox = ttk.LabelFrame(frame, text="Mode Keyboard, Mouse, Gamepad & OTG", padding=12)
        ibox.pack(fill="x", pady=(0, 12))

        in_fields = [
            ("Mode Keyboard (default/sdk/uhid/aoa/disabled):", self.keyboard_mode_var),
            ("Mode Mouse (default/sdk/uhid/aoa/disabled):", self.mouse_mode_var),
            ("Mode Gamepad (default/uhid/aoa/disabled):", self.gamepad_mode_var),
            ("Tombol Shortcut Mod (default/lalt/lsuper/lctrl):", self.shortcut_mod_var),
        ]
        for idx, (lbl, var) in enumerate(in_fields):
            ttk.Label(ibox, text=lbl, style="Card.TLabel").grid(row=idx, column=0, sticky="w", padx=6, pady=4)
            ttk.Entry(ibox, textvariable=var, width=20).grid(row=idx, column=1, sticky="w", padx=6, pady=4)

        wbox = ttk.LabelFrame(frame, text="Geometri Jendela & Argumen Tambahan", padding=12)
        wbox.pack(fill="x", pady=(0, 12))
        w_fields = [
            ("Judul Jendela (--window-title):", self.window_title_var),
            ("Buka Aplikasi Awal (--start-app):", self.start_app_var),
            ("Posisi X (--window-x):", self.window_x_var),
            ("Posisi Y (--window-y):", self.window_y_var),
            ("Lebar Jendela (--window-width):", self.window_w_var),
            ("Tinggi Jendela (--window-height):", self.window_h_var),
            ("Batas Waktu Sesi (detik):", self.time_limit_var),
            ("Extra Flags scrcpy:", self.extra_args_var),
        ]
        for idx, (lbl, var) in enumerate(w_fields):
            r, c = divmod(idx, 2)
            ttk.Label(wbox, text=lbl, style="Card.TLabel").grid(row=r, column=c * 2, sticky="w", padx=6, pady=4)
            ttk.Entry(wbox, textvariable=var, width=20).grid(row=r, column=c * 2 + 1, sticky="w", padx=6, pady=4)

    # -----------------------------------------------------------------
    # Section 6: App Manager
    # -----------------------------------------------------------------
    def _build_apps_section(self):
        frame = ttk.Frame(self.scroll_frame)
        self.sections["apps"] = frame

        top_bar = ttk.LabelFrame(frame, text="Manajer Aplikasi Android (Buka di Jendela DeX atau Layar Utama)", padding=10)
        top_bar.pack(fill="x", pady=(0, 10))

        ttk.Label(top_bar, text="Cari Aplikasi / Package:", style="Card.TLabel").pack(side="left")
        search_entry = ttk.Entry(top_bar, textvariable=self.app_search_var, width=28)
        search_entry.pack(side="left", padx=8)
        search_entry.bind("<KeyRelease>", lambda _e: self._render_apps_list())

        ttk.Checkbutton(top_bar, text="Tampilkan Aplikasi Sistem", variable=self.show_sys_apps_var, command=self._render_apps_list).pack(side="left", padx=8)
        ttk.Button(top_bar, text="Muat Ulang Daftar Aplikasi", style="Accent.TButton", command=self.load_installed_apps).pack(side="right", padx=4)

        list_box = ttk.LabelFrame(frame, text="Daftar Aplikasi Terinstal (Klik Ganda untuk Membuka di DeX)", padding=10)
        list_box.pack(fill="both", expand=True)

        self.apps_tree = ttk.Treeview(list_box, columns=("name", "pkg", "type"), show="headings", height=16)
        self.apps_tree.heading("name", text="Nama Aplikasi")
        self.apps_tree.heading("pkg", text="Package Name")
        self.apps_tree.heading("type", text="Tipe")
        self.apps_tree.column("name", width=260)
        self.apps_tree.column("pkg", width=360)
        self.apps_tree.column("type", width=100)
        self.apps_tree.pack(fill="both", expand=True, pady=(0, 8))
        self.apps_tree.bind("<Double-1>", lambda _e: self._launch_selected_tree_app(in_dex=True))

        act_row = ttk.Frame(list_box, style="Card.TFrame")
        act_row.pack(fill="x")
        ttk.Button(act_row, text="🗔 Buka di Jendela DeX Tunggal", style="Accent.TButton", command=lambda: self._launch_selected_tree_app(in_dex=True)).pack(side="left", padx=4)
        ttk.Button(act_row, text="📱 Mirror di Layar Utama", command=lambda: self._launch_selected_tree_app(in_dex=False)).pack(side="left", padx=4)
        ttk.Button(act_row, text="🗗 Buka di Jendela Mandiri Baru", command=lambda: self._launch_selected_tree_app_detached(is_pip=False)).pack(side="left", padx=4)
        ttk.Button(act_row, text="📌 Buka Mode PiP (Always-on-Top)", command=lambda: self._launch_selected_tree_app_detached(is_pip=True)).pack(side="left", padx=4)

    def _launch_selected_tree_app(self, in_dex: bool):
        sel = self.apps_tree.selection()
        if not sel:
            return
        vals = self.apps_tree.item(sel[0], "values")
        if len(vals) >= 2:
            app_name, pkg = vals[0], vals[1]
            if in_dex:
                self.launch_dex_app(app_name, pkg)
            else:
                self.start_app_var.set(pkg)
                if self.profile_var.get() == "desktop":
                    self.profile_var.set("default")
                self.start_scrcpy()

    def _launch_selected_tree_app_detached(self, is_pip: bool):
        sel = self.apps_tree.selection()
        if not sel:
            return
        vals = self.apps_tree.item(sel[0], "values")
        if len(vals) >= 2:
            self.spawn_detached_dex_window(vals[0], vals[1], is_pip=is_pip)

    # -----------------------------------------------------------------
    # Section 7: Remote Control, Clipboard, Touch Macros & 2-Way Files
    # -----------------------------------------------------------------
    def _build_files_section(self):
        frame = ttk.Frame(self.scroll_frame)
        self.sections["files"] = frame

        # Remote Text & Clipboard Sync
        clip_box = ttk.LabelFrame(frame, text="Ketik Teks Jarak Jauh & Sinkronisasi Clipboard (PC ⇄ Android)", padding=10)
        clip_box.pack(fill="x", pady=(0, 10))

        r1 = ttk.Frame(clip_box, style="Card.TFrame")
        r1.pack(fill="x", pady=4)
        ttk.Entry(r1, textvariable=self.remote_text_var, width=45).pack(side="left", padx=(0, 8))
        ttk.Button(r1, text="Kirim Teks ke HP", style="Accent.TButton", command=self.send_remote_text).pack(side="left", padx=3)
        ttk.Button(r1, text="Paste Clipboard PC → HP", command=self.sync_pc_clipboard_to_phone).pack(side="left", padx=3)
        ttk.Button(r1, text="Ambil Clipboard HP → PC", command=self.pull_phone_clipboard_to_pc).pack(side="left", padx=3)

        # Touch Macros & APK/File Push
        macro_box = ttk.LabelFrame(frame, text="Gesture Layar Cepat & Install APK / Kirim File ke HP", padding=10)
        macro_box.pack(fill="x", pady=(0, 10))

        m_row = ttk.Frame(macro_box, style="Card.TFrame")
        m_row.pack(fill="x", pady=4)
        ttk.Button(m_row, text="↑ Swipe Up", command=lambda: self.send_swipe(540, 1700, 540, 500)).pack(side="left", padx=3)
        ttk.Button(m_row, text="↓ Swipe Down", command=lambda: self.send_swipe(540, 500, 540, 1700)).pack(side="left", padx=3)
        ttk.Button(m_row, text="← Swipe Left", command=lambda: self.send_swipe(900, 1100, 180, 1100)).pack(side="left", padx=3)
        ttk.Button(m_row, text="→ Swipe Right", command=lambda: self.send_swipe(180, 1100, 900, 1100)).pack(side="left", padx=3)
        ttk.Button(m_row, text="📦 Pilih & Install File .APK", style="Accent.TButton", command=self.prompt_install_apk).pack(side="right", padx=4)
        ttk.Button(m_row, text="📤 Kirim File ke HP (Push)", style="Success.TButton", command=self.prompt_push_file).pack(side="right", padx=4)

        # 2-Way Android File Explorer
        fexp_box = ttk.LabelFrame(frame, text="File Explorer Android 2 Arah (Browse & Download File dari HP ke PC)", padding=10)
        fexp_box.pack(fill="both", expand=True)

        nav_f = ttk.Frame(fexp_box, style="Card.TFrame")
        nav_f.pack(fill="x", pady=(0, 6))
        for lbl, path in [
            ("Download", "/sdcard/Download"),
            ("Kamera (DCIM)", "/sdcard/DCIM/Camera"),
            ("Pictures", "/sdcard/Pictures"),
            ("Movies", "/sdcard/Movies"),
            ("Root /sdcard", "/sdcard"),
        ]:
            ttk.Button(nav_f, text=lbl, command=lambda p=path: self.load_android_files(p)).pack(side="left", padx=3)

        ttk.Entry(nav_f, textvariable=self.android_dir_var, width=28).pack(side="left", padx=6)
        ttk.Button(nav_f, text="Buka Folder", command=lambda: self.load_android_files(self.android_dir_var.get())).pack(side="left", padx=3)

        self.files_tree = ttk.Treeview(fexp_box, columns=("name", "type", "path"), show="headings", height=12)
        self.files_tree.heading("name", text="Nama File / Folder")
        self.files_tree.heading("type", text="Tipe")
        self.files_tree.heading("path", text="Lokasi Lengkap di Android")
        self.files_tree.column("name", width=280)
        self.files_tree.column("type", width=90)
        self.files_tree.column("path", width=360)
        self.files_tree.pack(fill="both", expand=True, pady=(0, 6))
        self.files_tree.bind("<Double-1>", lambda _e: self._on_file_tree_double_click())

        f_act = ttk.Frame(fexp_box, style="Card.TFrame")
        f_act.pack(fill="x")
        ttk.Button(f_act, text="📥 Download File Terpilih ke PC (Pull ke Downloads)", style="Accent.TButton", command=self.pull_selected_android_file).pack(side="left", padx=4)

    # -----------------------------------------------------------------
    # Section 8: Wireless & Pairing ADB
    # -----------------------------------------------------------------
    def _build_wireless_section(self):
        frame = ttk.Frame(self.scroll_frame)
        self.sections["wireless"] = frame

        wbox = ttk.LabelFrame(frame, text="Koneksi ADB TCP/IP (Wi-Fi) & Pemindai Jaringan Lokal (LAN / mDNS)", padding=12)
        wbox.pack(fill="x", pady=(0, 12))

        r1 = ttk.Frame(wbox, style="Card.TFrame")
        r1.pack(fill="x", pady=4)
        ttk.Label(r1, text="IP:Port Perangkat:", style="Card.TLabel").pack(side="left")
        ttk.Entry(r1, textvariable=self.tcpip_addr_var, width=24).pack(side="left", padx=8)
        ttk.Button(r1, text="Connect IP", style="Accent.TButton", command=self.connect_wifi_ip).pack(side="left", padx=4)
        ttk.Button(r1, text="Auto USB → Wi-Fi (5555)", style="Success.TButton", command=self.bridge_usb_to_wifi).pack(side="left", padx=4)
        ttk.Button(r1, text="Disconnect Semua", style="Danger.TButton", command=self.disconnect_all_wifi).pack(side="left", padx=4)

        r2 = ttk.Frame(wbox, style="Card.TFrame")
        r2.pack(fill="x", pady=8)
        ttk.Button(r2, text="📡 Scan Jaringan Lokal (LAN, mDNS & Port 5555)", style="Accent.TButton", command=self.scan_local_wifi_devices).pack(side="left", padx=4)
        self.lan_info_lbl = ttk.Label(r2, text=f"IP PC: {self.pc_ip_var.get()}  •  IP Wi-Fi HP: {self.telemetry['ip']}", style="Card.TLabel")
        self.lan_info_lbl.pack(side="left", padx=12)

        self.lan_results_frame = ttk.Frame(wbox, style="Card.TFrame")
        self.lan_results_frame.pack(fill="x", pady=4)

        pbox = ttk.LabelFrame(frame, text="Wireless Debugging Pairing (Android 11+ Kode 6 Digit)", padding=12)
        pbox.pack(fill="x", pady=(0, 12))
        pr = ttk.Frame(pbox, style="Card.TFrame")
        pr.pack(fill="x", pady=4)
        ttk.Label(pr, text="IP:Port Pairing:", style="Card.TLabel").pack(side="left")
        ttk.Entry(pr, textvariable=self.pair_addr_var, width=22).pack(side="left", padx=6)
        ttk.Label(pr, text="Kode Pairing 6 Digit:", style="Card.TLabel").pack(side="left", padx=(10, 0))
        ttk.Entry(pr, textvariable=self.pair_code_var, width=12).pack(side="left", padx=6)
        ttk.Button(pr, text="Pair Perangkat", style="Accent.TButton", command=self.pair_device).pack(side="left", padx=6)

    # -----------------------------------------------------------------
    # Section 9: Logs & Diagnostic Tools
    # -----------------------------------------------------------------
    def _build_logs_section(self):
        frame = ttk.Frame(self.scroll_frame)
        self.sections["logs"] = frame

        bar = ttk.Frame(frame)
        bar.pack(fill="x", pady=(0, 8))
        ttk.Button(bar, text="🩺 Doctor & Auto-Fix ADB", style="Success.TButton", command=self.run_system_doctor).pack(side="left", padx=3)
        ttk.Button(bar, text="Status ADB", command=lambda: self.run_diag_cmd([self.adb_bin, "devices", "-l"], "Status ADB")).pack(side="left", padx=3)
        ttk.Button(bar, text="Daftar Kamera", command=lambda: self.run_diag_cmd([self.scrcpy_bin, "--list-cameras"], "Daftar Kamera")).pack(side="left", padx=3)
        ttk.Button(bar, text="Ukuran Kamera", command=lambda: self.run_diag_cmd([self.scrcpy_bin, "--list-camera-sizes"], "Ukuran Kamera")).pack(side="left", padx=3)
        ttk.Button(bar, text="Daftar Layar", command=lambda: self.run_diag_cmd([self.scrcpy_bin, "--list-displays"], "Daftar Layar")).pack(side="left", padx=3)
        ttk.Button(bar, text="Daftar Encoder", command=lambda: self.run_diag_cmd([self.scrcpy_bin, "--list-encoders"], "Daftar Encoder")).pack(side="left", padx=3)
        ttk.Button(bar, text="Bersihkan Log", command=lambda: self.log_text.delete("1.0", "end")).pack(side="right", padx=3)

        self.log_text = tk.Text(frame, height=24, bg="#090D16", fg="#A7F3D0", insertbackground="#FFFFFF", font=("Consolas" if IS_WINDOWS else "Monospace", 10))
        self.log_text.pack(fill="both", expand=True)
        self.append_log("Selamat datang di scrcpy-plus v3 (Cross-Platform Windows & Linux Edition).\nDeveloper: Subuh Kurniawan <kurrniawansubuh@gmail.com>\n")

    # -----------------------------------------------------------------
    # Section 10: How-To Guide & Developer Info
    # -----------------------------------------------------------------
    def _build_howto_section(self):
        frame = ttk.Frame(self.scroll_frame)
        self.sections["howto"] = frame

        dev_box = ttk.LabelFrame(frame, text="Informasi Developer & Pembuat", padding=14)
        dev_box.pack(fill="x", pady=(0, 12))

        tk.Label(dev_box, text="Subuh Kurniawan", fg="#F9FAFB", bg="#1F2937", font=("Segoe UI" if IS_WINDOWS else "Sans", 16, "bold")).pack(anchor="w")
        tk.Label(dev_box, text="Email: kurrniawansubuh@gmail.com", fg="#60A5FA", bg="#1F2937", font=("Consolas" if IS_WINDOWS else "Monospace", 11, "bold")).pack(anchor="w", pady=(2, 8))

        dev_btns = ttk.Frame(dev_box, style="Card.TFrame")
        dev_btns.pack( anchor="w")
        ttk.Button(dev_btns, text="📋 Salin Email Developer", command=self._copy_dev_email).pack(side="left", padx=(0, 6))
        ttk.Button(dev_btns, text="✉️ Hubungi Developer via Email", style="Accent.TButton", command=lambda: webbrowser.open("mailto:kurrniawansubuh@gmail.com?subject=Feedback%20scrcpy-plus%20v3")).pack(side="left")

        guide_box = ttk.LabelFrame(frame, text="Panduan Lengkap Penggunaan (How-To Guide — Windows & Linux)", padding=14)
        guide_box.pack(fill="x", pady=(0, 12))

        guide_content = (
            "1. PERSIAPAN AWAL DI HP ANDROID (Wajib Sekali Saja):\n"
            "   • Buka Pengaturan → Tentang Ponsel → Ketuk 'Nomor Bentukan' (Build Number) 7 kali hingga Developer Options aktif.\n"
            "   • Buka Pengaturan → Opsi Pengembang (Developer Options) → Aktifkan 'USB Debugging'.\n"
            "   • Aktifkan juga 'USB debugging (Security settings)' / 'Disable permission monitoring' agar kontrol mouse, keyboard, dan peluncuran aplikasi di Virtual Display DeX berjalan penuh.\n\n"
            "2. CARA KONEKSI WI-FI ADB TANPA KABEL (Jaringan Lokal / Hotspot):\n"
            "   • Cara Paling Cepat (1-Klik via USB): Hubungkan kabel USB, klik tombol 'Aktifkan Wi-Fi (5555)' di Dashboard atau 'Auto USB → Wi-Fi (5555)' di menu Wi-Fi. Setelah terhubung, cabut kabel USB.\n"
            "   • Tanpa Kabel USB (Scan LAN & mDNS): Buka menu '8. Wi-Fi & Pairing ADB', klik 'Scan Jaringan Lokal (LAN, mDNS & Port 5555)', lalu klik tombol perangkat yang ditemukan.\n\n"
            "3. CARA MENGGUNAKAN MODE SAMSUNG DeX (Jendela Tunggal Landscape):\n"
            "   • Buka menu '2. DeX Desktop Workspace', pilih orientasi 'Landscape (16:9 Horizontal Terkunci)', lalu klik 'Start DeX (1 Jendela Landscape)'.\n"
            "   • Klik aplikasi apa saja di daftar Peluncur Cepat atau Floating DeX Taskbar — aplikasi akan berganti di dalam 1 jendela DeX yang sama tanpa membuka jendela baru!\n\n"
            "4. PINTASAN KEYBOARD (Saat Jendela scrcpy / DeX Aktif di Windows & Linux):\n"
            "   • Alt + F : Fullscreen / Windowed          • Alt + H : Tombol Home Android\n"
            "   • Alt + B : Tombol Back (Kembali)          • Alt + S : Recent Apps / App Switcher\n"
            "   • Alt + O : Matikan layar fisik HP saja    • Alt + Shift + O : Nyalakan layar fisik HP\n"
            "   • Alt + R : Putar orientasi layar          • Alt + ↑ / ↓ : Volume Naik / Turun"
        )
        tk.Label(guide_box, text=guide_content, justify="left", anchor="w", fg="#E5E7EB", bg="#1F2937", font=("Segoe UI" if IS_WINDOWS else "Sans", 10)).pack(fill="x")

    def _copy_dev_email(self):
        self.clipboard_clear()
        self.clipboard_append("kurrniawansubuh@gmail.com")
        self.status_var.set("Email developer (kurrniawansubuh@gmail.com) disalin ke Clipboard")

    # -----------------------------------------------------------------
    # Logging & ADB Helpers
    # -----------------------------------------------------------------
    def append_log(self, text: str):
        if not text:
            return
        self.log_text.insert("end", text)
        self.log_text.see("end")

    def _adb_args(self, *extra) -> list:
        cmd = [self.adb_bin]
        sel = self.selected_serial_var.get().strip()
        if sel and not sel.startswith("Otomatis"):
            serial = sel.split(" ")[0].strip()
            if serial:
                cmd.extend(["-s", serial])
        cmd.extend(extra)
        return cmd

    def _on_device_selected(self):
        self.fetch_telemetry()
        self.load_installed_apps()

    def refresh_devices(self):
        def worker():
            out = run_capture([self.adb_bin, "devices", "-l"], timeout=6.0)
            found = []
            for line in out.splitlines():
                line = line.strip()
                if not line or line.startswith("List of") or line.startswith("*"):
                    continue
                parts = line.split()
                if len(parts) >= 2 and parts[1] in ("device", "offline", "unauthorized"):
                    serial = parts[0]
                    model = "Android"
                    for p in parts[2:]:
                        if p.startswith("model:"):
                            model = p.split(":", 1)[1]
                    found.append((serial, f"{serial} ({model} - {parts[1]})"))
            self.after(0, lambda: self._update_devices_ui(found))

        threading.Thread(target=worker, daemon=True).start()

    def _update_devices_ui(self, found: list):
        self.devices_list = found
        vals = ["Otomatis (Semua)"] + [label for _, label in found]
        self.device_combo["values"] = vals
        cur = self.selected_serial_var.get()
        if found:
            if cur.startswith("Otomatis") or not any(cur.startswith(s) for s, _ in found):
                self.selected_serial_var.set(found[0][1])
            self.status_var.set(f"{len(found)} perangkat ADB terhubung")
            self.fetch_telemetry()
        else:
            self.selected_serial_var.set("Otomatis (Semua)")
            self.status_var.set("Tidak ada perangkat ADB terdeteksi")

    # -----------------------------------------------------------------
    # 5-Stage Android 11-15 Wi-Fi IP Detection & Live Telemetry
    # -----------------------------------------------------------------
    def _detect_device_wifi_ip_sync(self) -> str:
        # Stage 1: Direct IPv4 on wlan0
        out = run_capture(self._adb_args("shell", "ip", "-f", "inet", "addr", "show", "wlan0"), timeout=4.0)
        m = re.search(r"inet\s+(\d+\.\d+\.\d+\.\d+)", out)
        if m and m.group(1) != "127.0.0.1":
            return m.group(1)

        # Stage 2: Private LAN IPv4 (192.168.x.x / 172.16-31.x.x) across all interfaces
        out_all = run_capture(self._adb_args("shell", "ip", "-f", "inet", "addr", "show"), timeout=4.0)
        for line in out_all.splitlines():
            m2 = re.search(r"inet\s+((?:192\.168|172\.(?:1[6-9]|2\d|3[01]))\.\d+\.\d+)", line)
            if m2:
                return m2.group(1)

        # Stage 3: Per-interface routing table wlan0
        out_tbl = run_capture(self._adb_args("shell", "ip", "route", "show", "table", "wlan0"), timeout=4.0)
        m3 = re.search(r"src\s+(\d+\.\d+\.\d+\.\d+)", out_tbl)
        if m3:
            return m3.group(1)

        # Stage 4: Main routing table preferring wlan
        out_rt = run_capture(self._adb_args("shell", "ip", "route"), timeout=4.0)
        for line in out_rt.splitlines():
            if "wlan" in line:
                m4 = re.search(r"src\s+(\d+\.\d+\.\d+\.\d+)", line)
                if m4:
                    return m4.group(1)
        return "-"

    def fetch_telemetry(self):
        def worker():
            state = run_capture(self._adb_args("get-state"), timeout=4.0).strip()
            if state != "device":
                return
            manuf = run_capture(self._adb_args("shell", "getprop", "ro.product.manufacturer"), timeout=4.0).strip().title()
            model = run_capture(self._adb_args("shell", "getprop", "ro.product.model"), timeout=4.0).strip()
            android_v = run_capture(self._adb_args("shell", "getprop", "ro.build.version.release"), timeout=4.0).strip()
            sdk_v = run_capture(self._adb_args("shell", "getprop", "ro.build.version.sdk"), timeout=4.0).strip()
            batt_out = run_capture(self._adb_args("shell", "dumpsys", "battery"), timeout=4.0)
            wm_out = run_capture(self._adb_args("shell", "wm", "size"), timeout=4.0)
            mem_out = run_capture(self._adb_args("shell", "cat", "/proc/meminfo"), timeout=4.0)
            wifi_ip = self._detect_device_wifi_ip_sync()

            batt_lvl = 0
            temp_str = "-"
            for line in batt_out.splitlines():
                if "level:" in line:
                    try:
                        batt_lvl = int(line.split("level:")[1].strip())
                    except Exception:
                        pass
                elif "temperature:" in line:
                    try:
                        raw_t = float(line.split("temperature:")[1].strip())
                        if raw_t > 0:
                            temp_str = f"{raw_t / 10.0:.1f}°C"
                    except Exception:
                        pass

            ram_str = "-"
            mt = re.search(r"MemTotal:\s+(\d+)", mem_out)
            ma = re.search(r"MemAvailable:\s+(\d+)", mem_out)
            if mt and ma:
                total_gb = int(mt.group(1)) / 1048576.0
                avail_gb = int(ma.group(1)) / 1048576.0
                ram_str = f"{total_gb - avail_gb:.1f} / {total_gb:.1f} GB"

            size_str = "-"
            for line in wm_out.splitlines():
                if "Physical size:" in line:
                    size_str = line.split("Physical size:")[1].strip()
                    break

            info = {
                "manufacturer": manuf or "-",
                "model": model or "-",
                "android": android_v or "-",
                "sdk": sdk_v or "-",
                "battery": batt_lvl,
                "temp": temp_str,
                "ram": ram_str,
                "size": size_str,
                "ip": wifi_ip,
            }
            self.after(0, lambda: self._update_telemetry_ui(info))

        threading.Thread(target=worker, daemon=True).start()

    def _update_telemetry_ui(self, info: dict):
        self.telemetry = info
        self.tele_device_lbl.configure(text=f"{info['manufacturer']} {info['model']} (Android {info['android']} • API {info['sdk']})")
        self.tele_batt_lbl.configure(text=f"Baterai & Suhu: {info['battery']}% • {info['temp']}")
        self.tele_ram_lbl.configure(text=f"RAM: {info['ram']}")
        self.tele_res_lbl.configure(text=f"Resolusi Layar: {info['size']}")
        self.tele_ip_lbl.configure(text=f"IP Wi-Fi (wlan0): {info['ip']}")
        self.lan_info_lbl.configure(text=f"IP PC: {self.pc_ip_var.get()}  •  IP Wi-Fi HP: {info['ip']}")

        if info["ip"] != "-":
            cur = self.tcpip_addr_var.get().strip()
            if not cur or cur.startswith("10.") or not cur.startswith(info["ip"]):
                self.tcpip_addr_var.set(f"{info['ip']}:5555")
                self._save_settings()

    def _periodic_telemetry_tick(self):
        if self.devices_list:
            self.fetch_telemetry()
        self.after(15000, self._periodic_telemetry_tick)

    def _auto_reconnect_startup(self):
        if self.auto_reconnect_wifi_var.get() and not self.devices_list:
            addr = self.tcpip_addr_var.get().strip()
            if addr:
                self.connect_wifi_ip()

    # -----------------------------------------------------------------
    # Single-Window Samsung DeX Engine + Floating DeX Taskbar
    # -----------------------------------------------------------------
    def _detect_virtual_display_id_sync(self) -> str:
        for _ in range(10):
            out = run_capture(self._adb_args("shell", "dumpsys", "window", "displays"), timeout=4.0)
            matches = re.findall(r"mDisplayId=([1-9]\d*)", out)
            if matches:
                return matches[-1]
            out2 = run_capture(self._adb_args("shell", "dumpsys", "display"), timeout=4.0)
            matches2 = re.findall(r"mDisplayId=([1-9]\d*)", out2)
            if matches2:
                return matches2[-1]
            time.sleep(0.35)
        return ""

    def _resolve_package_and_activity_sync(self, raw_query: str) -> tuple:
        clean = raw_query.lstrip("+?").strip()
        if not clean:
            clean = "com.android.settings"
        pkg = clean
        path_check = run_capture(self._adb_args("shell", "pm", "path", pkg), timeout=4.0)
        if "package:" not in path_check:
            pkgs_out = run_capture(self._adb_args("shell", "pm", "list", "packages"), timeout=6.0)
            for line in pkgs_out.splitlines():
                p = line.replace("package:", "").strip()
                if clean.lower() in p.lower():
                    pkg = p
                    break
        comp = ""
        for cat in ("android.intent.category.LAUNCHER", "android.intent.category.INFO"):
            res = run_capture(
                self._adb_args("shell", "cmd", "package", "resolve-activity", "--brief", "-a", "android.intent.action.MAIN", "-c", cat, pkg),
                timeout=4.0,
            )
            lines = [l.strip() for l in res.splitlines() if "/" in l]
            if lines:
                comp = lines[-1]
                break
        return pkg, comp

    def _apply_display_rotation_sync(self, did: str, mode: str):
        if not did or did == "0":
            return
        run_capture(self._adb_args("shell", "settings", "put", "global", "force_resizable_activities", "1"), timeout=3.0)
        run_capture(self._adb_args("shell", "settings", "put", "global", "enable_freeform_support", "1"), timeout=3.0)
        if mode in ("landscape", "landscape-reverse"):
            rot = "0" if mode == "landscape" else "2"
            run_capture(self._adb_args("shell", "wm", "fixed-to-user-rotation", "-d", did, "enabled"), timeout=3.0)
            run_capture(self._adb_args("shell", "wm", "user-rotation", "-d", did, "lock", rot), timeout=3.0)
        elif mode == "portrait":
            run_capture(self._adb_args("shell", "wm", "fixed-to-user-rotation", "-d", did, "enabled"), timeout=3.0)
            run_capture(self._adb_args("shell", "wm", "user-rotation", "-d", did, "lock", "1"), timeout=3.0)
        else:
            run_capture(self._adb_args("shell", "wm", "fixed-to-user-rotation", "-d", did, "disabled"), timeout=3.0)
            run_capture(self._adb_args("shell", "wm", "user-rotation", "-d", did, "free"), timeout=3.0)

    def start_single_window_dex(self):
        if self.is_dex_running and self.scrcpy_proc and self.scrcpy_proc.poll() is None:
            self.show_floating_dex_taskbar()
            self.status_var.set(f"Sesi DeX sudah aktif (Display #{self.active_dex_display_id})")
            return
        self.launch_dex_app("Pengaturan DeX", "com.android.settings")

    def launch_dex_app(self, app_name: str, package_query: str):
        if self.dex_open_new_win_var.get() and self.is_dex_running:
            self.spawn_detached_dex_window(app_name, package_query, is_pip=False)
            return

        # Case 1: Single DeX Window is ALREADY running -> switch/launch app INSIDE that same DeX window!
        if self.is_dex_running and self.scrcpy_proc and self.scrcpy_proc.poll() is None:
            def switch_worker():
                did = self.active_dex_display_id if self.active_dex_display_id != "auto" else self._detect_virtual_display_id_sync()
                if not did:
                    self.after(0, lambda: self.status_var.set("Virtual Display DeX belum siap, mencoba ulang..."))
                    return
                self.active_dex_display_id = did
                pkg, comp = self._resolve_package_and_activity_sync(package_query)
                if self.dex_orientation_var.get() == "landscape":
                    self._apply_display_rotation_sync(did, "landscape")
                if self.dex_force_stop_var.get() and pkg not in self.dex_opened_pkgs:
                    run_capture(self._adb_args("shell", "am", "force-stop", pkg), timeout=3.0)
                self.dex_opened_pkgs.add(pkg)

                cmd = ["shell", "am", "start", "--display", did]
                if self.dex_freeform_var.get():
                    cmd.extend(["--windowingMode", "5"])
                if comp and "/" in comp:
                    cmd.extend(["-n", comp])
                else:
                    cmd = ["shell", "cmd", "activity", "start-activity", "--display", did, pkg]
                out = run_capture(self._adb_args(*cmd), timeout=5.0)
                self.after(0, lambda: self._on_dex_app_switched(app_name, pkg, did, out))

            threading.Thread(target=switch_worker, daemon=True).start()
            return

        # Case 2: Start the Single-Window DeX Virtual Display Session
        if self.is_running:
            self.stop_scrcpy()
            self.after(400, lambda: self.launch_dex_app(app_name, package_query))
            return

        def start_dex_worker():
            pkg, _ = self._resolve_package_and_activity_sync(package_query)
            spec = self.dex_spec_var.get().strip() or "1920x1080/160"
            win_w = self.dex_win_w_var.get().strip() or "1280"
            win_h = self.dex_win_h_var.get().strip() or "720"
            orient = self.dex_orientation_var.get()

            args = [self.scrcpy_bin]
            sel = self.selected_serial_var.get().strip()
            if sel and not sel.startswith("Otomatis"):
                args.extend(["-s", sel.split(" ")[0]])

            start_arg = f"+{pkg}" if self.dex_force_stop_var.get() else pkg
            args.extend([
                f"--new-display={spec}",
                f"--start-app={start_arg}",
                "--display-ime-policy=hide",
                f"--window-width={win_w}",
                f"--window-height={win_h}",
                f"--window-title=Samsung DeX ({orient.title()}) — {self.telemetry['model']}",
                "-b", self.bitrate_var.get().strip() or "16M",
                "--max-fps", self.fps_var.get().strip() or "60",
            ])
            if orient == "landscape":
                args.append("--capture-orientation=@0")
            elif orient == "landscape-reverse":
                args.append("--capture-orientation=@180")
            if self.dex_no_decor_var.get():
                args.append("--no-vd-system-decorations")
            if self.dex_keep_content_var.get():
                args.append("--no-vd-destroy-content")
            if self.no_audio_var.get():
                args.append("--no-audio")
            elif self.audio_dup_var.get():
                args.append("--audio-dup")

            self.after(0, lambda: self._spawn_main_process(args, is_dex=True, initial_app=(app_name, pkg)))

        threading.Thread(target=start_dex_worker, daemon=True).start()

    def _on_dex_app_switched(self, app_name: str, pkg: str, did: str, out: str):
        self.append_log(f"\n[DeX Display #{did}] Membuka {app_name} ({pkg})\n{out}\n")
        if not any(p == pkg for _, p in self.dex_running_apps):
            self.dex_running_apps.append((app_name, pkg))
        self.status_var.set(f"DeX Display #{did}: Menampilkan '{app_name}' di jendela DeX tunggal")
        self._refresh_floating_taskbar_buttons()

    def spawn_detached_dex_window(self, app_name: str, package_query: str, is_pip: bool = False):
        def worker():
            pkg, _ = self._resolve_package_and_activity_sync(package_query)
            spec = "1280x720/180" if is_pip else (self.dex_spec_var.get().strip() or "1920x1080/160")
            w = "440" if is_pip else "1024"
            h = "250" if is_pip else "640"
            args = [self.scrcpy_bin]
            sel = self.selected_serial_var.get().strip()
            if sel and not sel.startswith("Otomatis"):
                args.extend(["-s", sel.split(" ")[0]])
            args.extend([
                f"--new-display={spec}",
                f"--start-app=+{pkg}",
                "--no-vd-system-decorations",
                "--no-vd-destroy-content",
                "--display-ime-policy=hide",
                f"--window-width={w}",
                f"--window-height={h}",
                f"--window-title={'PiP • ' if is_pip else ''}{app_name}",
            ])
            if is_pip:
                args.append("--always-on-top")
            if self.dex_orientation_var.get() == "landscape":
                args.append("--capture-orientation=@0")
            try:
                proc = subprocess.Popen(args, cwd=str(self.workspace_dir), creationflags=CREATE_NO_WINDOW)
                self.detached_procs.append(proc)
                self.after(0, lambda: self.status_var.set(f"Membuka '{app_name}' di jendela {'PiP' if is_pip else 'mandiri'} baru"))
            except Exception as exc:
                self.after(0, lambda: self.status_var.set(f"Gagal membuka jendela: {exc}"))

        threading.Thread(target=worker, daemon=True).start()

    def start_pip_mirror(self):
        args = [self.scrcpy_bin]
        sel = self.selected_serial_var.get().strip()
        if sel and not sel.startswith("Otomatis"):
            args.extend(["-s", sel.split(" ")[0]])
        args.extend([
            "--always-on-top",
            "--window-width=310",
            "--window-height=660",
            f"--window-title=PiP Mirror — {self.telemetry['model']}",
            "-b", "8M",
            "--max-fps", "60",
        ])
        try:
            proc = subprocess.Popen(args, cwd=str(self.workspace_dir), creationflags=CREATE_NO_WINDOW)
            self.detached_procs.append(proc)
            self.status_var.set("Jendela PiP (Always-on-Top) aktif")
        except Exception as exc:
            self.status_var.set(f"Gagal membuka PiP: {exc}")

    def launch_dex_bundle(self, bundle: dict):
        self.dex_orientation_var.set("landscape")
        self.dex_freeform_var.set(bundle["freeform"])
        apps = bundle["apps"]
        if not apps:
            return
        self.launch_dex_app(apps[0][0], apps[0][1])
        for idx, (name, q) in enumerate(apps[1:], start=1):
            self.after(idx * 1500, lambda n=name, query=q: self.launch_dex_app(n, query))

    def launch_split_screen_dex(self):
        self.dex_orientation_var.set("landscape")
        self.dex_freeform_var.set(True)
        left_q = self.split_left_var.get().strip() or "chrome"
        right_q = self.split_right_var.get().strip() or "whatsapp"
        self.launch_dex_app(left_q.title(), left_q)
        self.after(1400, lambda: self.launch_dex_app(right_q.title(), right_q))

    def set_dex_orientation(self, mode: str):
        self.dex_orientation_var.set(mode)
        if mode == "portrait":
            self.dex_spec_var.set("1080x1920/320")
            self.dex_win_w_var.set("420")
            self.dex_win_h_var.set("740")
        elif self.dex_spec_var.get().startswith("1080x1920"):
            self.dex_spec_var.set("1920x1080/160")
            self.dex_win_w_var.set("1280")
            self.dex_win_h_var.set("720")
        self._save_settings()
        if self.is_dex_running:
            self.apply_live_dex_rotation(mode)

    def toggle_dex_orientation(self):
        new_mode = "portrait" if self.dex_orientation_var.get().startswith("landscape") else "landscape"
        self.set_dex_orientation(new_mode)

    def apply_live_dex_rotation(self, mode: str):
        def worker():
            did = self.active_dex_display_id if self.active_dex_display_id != "auto" else self._detect_virtual_display_id_sync()
            if did:
                self.active_dex_display_id = did
                self._apply_display_rotation_sync(did, mode)
                self.after(0, lambda: self.status_var.set(f"Orientasi DeX Display #{did} diatur ke: {mode.title()}"))

        threading.Thread(target=worker, daemon=True).start()

    def apply_live_dex_dpi(self):
        dpi = self.dex_dpi_var.get()

        def worker():
            did = self.active_dex_display_id if self.active_dex_display_id != "auto" else self._detect_virtual_display_id_sync()
            if did:
                run_capture(self._adb_args("shell", "wm", "density", str(dpi), "-d", did), timeout=4.0)
                self.after(0, lambda: self.status_var.set(f"DeX Display #{did} Live DPI diatur ke {dpi}"))

        threading.Thread(target=worker, daemon=True).start()

    def send_dex_keyevent(self, key_code: str, label: str):
        def worker():
            did = self.active_dex_display_id if self.active_dex_display_id != "auto" else self._detect_virtual_display_id_sync()
            if did and did != "0":
                run_capture(self._adb_args("shell", "input", "-d", did, "keyevent", key_code), timeout=4.0)
            else:
                run_capture(self._adb_args("shell", "input", "keyevent", key_code), timeout=4.0)
            self.after(0, lambda: self.status_var.set(f"DeX Keyevent: {label}"))

        threading.Thread(target=worker, daemon=True).start()

    # -----------------------------------------------------------------
    # Floating Always-on-Top DeX Taskbar Window (Windows & Linux)
    # -----------------------------------------------------------------
    def show_floating_dex_taskbar(self):
        if self.floating_taskbar_win and self.floating_taskbar_win.winfo_exists():
            self.floating_taskbar_win.deiconify()
            self.floating_taskbar_win.lift()
            return

        win = tk.Toplevel(self)
        win.title("Samsung DeX Taskbar — App Switcher & Controls")
        win.geometry("860x56+180+40")
        win.configure(bg="#0F172A")
        win.attributes("-topmost", True)
        self.floating_taskbar_win = win

        bar = tk.Frame(win, bg="#0F172A", padx=8, pady=8)
        bar.pack(fill="both", expand=True)

        for name, q in DEX_QUICK_APPS[:6]:
            ttk.Button(bar, text=name, command=lambda n=name, query=q: self.launch_dex_app(n, query)).pack(side="left", padx=2)

        self.taskbar_apps_frame = tk.Frame(bar, bg="#0F172A")
        self.taskbar_apps_frame.pack(side="left", padx=6)

        ttk.Button(bar, text="◁ Back", command=lambda: self.send_dex_keyevent("4", "Back")).pack(side="right", padx=2)
        ttk.Button(bar, text="○ Home", command=lambda: self.send_dex_keyevent("3", "Home")).pack(side="right", padx=2)
        ttk.Button(bar, text="▢ Recent", command=lambda: self.send_dex_keyevent("187", "Recent")).pack(side="right", padx=2)
        ttk.Button(bar, text="⇄ Rotasi", command=self.toggle_dex_orientation).pack(side="right", padx=2)
        ttk.Button(bar, text="📸 Shot", command=lambda: self.take_screenshot(from_dex=True)).pack(side="right", padx=2)

    def _refresh_floating_taskbar_buttons(self):
        if not self.floating_taskbar_win or not self.floating_taskbar_win.winfo_exists():
            return
        for child in self.taskbar_apps_frame.winfo_children():
            child.destroy()
        for name, pkg in self.dex_running_apps[-4:]:
            ttk.Button(self.taskbar_apps_frame, text=f"• {name}", style="Accent.TButton", command=lambda n=name, p=pkg: self.launch_dex_app(n, p)).pack(side="left", padx=2)

    # -----------------------------------------------------------------
    # Main scrcpy Session Builder & Self-Healing Watchdog
    # -----------------------------------------------------------------
    def build_scrcpy_arguments(self, record_path: str = None) -> list:
        args = [self.scrcpy_bin]
        sel = self.selected_serial_var.get().strip()
        if sel and not sel.startswith("Otomatis"):
            args.extend(["-s", sel.split(" ")[0]])

        prof = self.profile_var.get()
        is_cam = prof == "camera" or self.video_source_var.get() == "camera"
        is_otg = prof == "otg" or self.otg_mode_var.get()

        # Apply profile defaults
        if prof == "gaming":
            args.extend(["--show-touches", "--disable-screensaver", "-b", self.bitrate_var.get() or "20M", "--max-fps", self.fps_var.get() or "60"])
        elif prof == "productivity":
            args.extend(["-w", "-b", self.bitrate_var.get() or "8M"])
        elif prof == "studio":
            args.extend(["--video-codec=h265", "-b", self.bitrate_var.get() or "15M", "--show-touches"])
        elif prof == "private":
            args.extend(["-S", "--power-off-on-close", "--disable-screensaver"])
        elif prof == "camera":
            args.extend(["--video-source=camera", f"--camera-facing={self.camera_facing_var.get() if self.camera_facing_var.get() != 'default' else 'back'}", f"--camera-size={self.camera_size_var.get() or '1920x1080'}"])
        elif prof == "audio-only":
            args.append("--no-video")
        elif prof == "low-latency":
            args.extend(["-m", "1024", "-b", "4M", "--max-fps", "60"])
        elif prof == "otg":
            args.append("--otg")

        if self.fullscreen_var.get():
            args.append("-f")
        if self.screen_off_var.get() and not is_cam and not is_otg:
            args.append("-S")
        if self.show_touches_var.get() and not is_cam and not is_otg:
            args.append("-t")
        if self.stay_awake_var.get() and not is_cam and not is_otg:
            args.append("-w")
        if self.always_on_top_var.get():
            args.append("--always-on-top")
        if self.borderless_var.get():
            args.append("--window-borderless")
        if self.audio_dup_var.get():
            args.append("--audio-dup")
        if self.no_audio_var.get():
            args.append("--no-audio")

        if self.video_codec_var.get() != "default":
            args.append(f"--video-codec={self.video_codec_var.get()}")
        if self.max_size_var.get() not in ("default", ""):
            args.extend(["-m", self.max_size_var.get()])
        if self.bitrate_var.get().strip():
            args.extend(["-b", self.bitrate_var.get().strip()])
        if self.fps_var.get().strip():
            args.extend(["--max-fps", self.fps_var.get().strip()])
        if self.window_title_var.get().strip():
            args.extend(["--window-title", self.window_title_var.get().strip()])
        if self.start_app_var.get().strip() and not is_cam and not is_otg:
            args.append(f"--start-app={self.start_app_var.get().strip()}")
        if record_path:
            args.extend(["--record", record_path])

        extra = self.extra_args_var.get().strip()
        if extra:
            args.extend(extra.split())
        return args

    def start_scrcpy(self):
        if self.profile_var.get() == "desktop":
            self.show_section("dex")
            self.start_single_window_dex()
            return

        if self.is_running:
            self.stop_scrcpy()
            self.after(400, self.start_scrcpy)
            return

        rec_path = None
        if self.record_enabled_var.get() or self.profile_var.get() == "recording":
            ext = self.record_format_var.get().strip() or "mp4"
            default_name = f"scrcpy-{datetime.now().strftime('%Y%m%d-%H%M%S')}.{ext}"
            rec_path = filedialog.asksaveasfilename(defaultextension=f".{ext}", initialfile=default_name)
            if not rec_path:
                self.status_var.set("Perekaman dibatalkan")
                return

        args = self.build_scrcpy_arguments(record_path=rec_path)
        self._spawn_main_process(args, is_dex=False)

    def _spawn_main_process(self, args: list, is_dex: bool, initial_app: tuple = None):
        self.user_requested_stop = False
        self.append_log(f"\n$ {' '.join(args)}\n")

        try:
            proc = subprocess.Popen(
                args,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                encoding="utf-8",
                errors="replace",
                cwd=str(self.workspace_dir),
                creationflags=CREATE_NO_WINDOW,
            )
        except Exception as exc:
            self.status_var.set(f"Gagal menjalankan scrcpy: {exc}")
            return

        self.scrcpy_proc = proc
        self.is_running = True
        self.is_dex_running = is_dex
        if is_dex and initial_app:
            self.dex_running_apps = [initial_app]
            self.dex_opened_pkgs = {initial_app[1]}
            self.show_floating_dex_taskbar()
            self.status_var.set("Jendela Tunggal Samsung DeX aktif — Klik aplikasi lain untuk berganti di jendela yang sama")
        else:
            self.status_var.set(f"scrcpy aktif ({self.profile_var.get()})")

        def reader():
            for line in proc.stdout:
                self.after(0, lambda l=line: self._handle_proc_output(l))
            rc = proc.wait()
            self.after(0, lambda: self._on_proc_terminated(rc, is_dex, initial_app))

        threading.Thread(target=reader, daemon=True).start()

    def _handle_proc_output(self, line: str):
        self.append_log(line)
        m = re.search(r"\(id=(\d+)\)", line)
        if m and m.group(1) != "0":
            did = m.group(1)
            self.active_dex_display_id = did
            self.status_var.set(f"Samsung DeX Aktif (Display ID: #{did}, Mode: {self.dex_orientation_var.get().title()})")
            self.apply_live_dex_rotation(self.dex_orientation_var.get())

    def _on_proc_terminated(self, rc: int, was_dex: bool, initial_app: tuple):
        self.is_running = False
        self.is_dex_running = False
        self.scrcpy_proc = None
        self.active_dex_display_id = "auto"

        if rc != 0 and not self.user_requested_stop and self.auto_recover_var.get() and self.recovery_attempts < 3:
            self.recovery_attempts += 1
            self.status_var.set(f"Sesi terputus (kode {rc}). Auto-Heal ({self.recovery_attempts}/3) dalam 2 detik...")
            self.append_log(f"\n[Auto-Recovery Watchdog] Sesi terputus tak terduga (kode {rc}). Memulihkan koneksi ADB...\n")
            threading.Thread(target=lambda: run_capture([self.adb_bin, "reconnect", "offline"], timeout=4.0), daemon=True).start()
            if was_dex and initial_app:
                self.after(2000, lambda: self.launch_dex_app(initial_app[0], initial_app[1]))
            else:
                self.after(2000, self.start_scrcpy)
        else:
            self.recovery_attempts = 0
            self.status_var.set("Sesi selesai" if rc == 0 else f"scrcpy berhenti (kode {rc}). Klik Doctor ADB untuk diagnostik.")

    def stop_scrcpy(self):
        self.user_requested_stop = True
        self.recovery_attempts = 0
        if self.scrcpy_proc and self.scrcpy_proc.poll() is None:
            try:
                self.scrcpy_proc.terminate()
            except Exception:
                pass
        for p in self.detached_procs:
            if p.poll() is None:
                try:
                    p.terminate()
                except Exception:
                    pass
        self.detached_procs.clear()
        if self.floating_taskbar_win and self.floating_taskbar_win.winfo_exists():
            self.floating_taskbar_win.destroy()
        self.is_running = False
        self.is_dex_running = False
        self.status_var.set("Semua sesi dihentikan")

    # -----------------------------------------------------------------
    # App Manager, Files, Clipboard, Wireless & System Doctor
    # -----------------------------------------------------------------
    def load_installed_apps(self):
        self.status_var.set("Memuat daftar aplikasi dari perangkat Android...")

        def worker():
            out = run_capture([self.scrcpy_bin, "--list-apps"], timeout=12.0)
            apps = []
            for line in out.splitlines():
                s = line.strip()
                if s.startswith("*") or s.startswith("-"):
                    is_sys = s.startswith("-")
                    body = s[1:].strip()
                    parts = body.split()
                    if parts and "." in parts[-1]:
                        pkg = parts[-1]
                        name = " ".join(parts[:-1]) or pkg
                        apps.append((name, pkg, is_sys))
            apps.sort(key=lambda x: x[0].lower())
            self.installed_apps = apps
            self.after(0, self._render_apps_list)

        threading.Thread(target=worker, daemon=True).start()

    def _render_apps_list(self):
        for item in self.apps_tree.get_children():
            self.apps_tree.delete(item)
        q = self.app_search_var.get().strip().lower()
        show_sys = self.show_sys_apps_var.get()
        count = 0
        for name, pkg, is_sys in self.installed_apps:
            if is_sys and not show_sys:
                continue
            if q and q not in name.lower() and q not in pkg.lower():
                continue
            self.apps_tree.insert("", "end", values=(name, pkg, "Sistem" if is_sys else "User"))
            count += 1
        self.status_var.set(f"Menampilkan {count} aplikasi Android")

    def send_keyevent(self, code: str, label: str):
        threading.Thread(
            target=lambda: run_capture(self._adb_args("shell", "input", "keyevent", code), timeout=4.0),
            daemon=True,
        ).start()
        self.status_var.set(f"Tombol dikirim: {label}")

    def send_remote_text(self):
        txt = self.remote_text_var.get().strip()
        if not txt:
            return
        escaped = txt.replace(" ", "%s")
        threading.Thread(
            target=lambda: run_capture(self._adb_args("shell", "input", "text", escaped), timeout=4.0),
            daemon=True,
        ).start()
        self.remote_text_var.set("")
        self.status_var.set("Teks berhasil dikirim ke perangkat")

    def sync_pc_clipboard_to_phone(self):
        try:
            txt = self.clipboard_get().strip()
        except Exception:
            txt = ""
        if not txt:
            return
        escaped = txt.replace(" ", "%s")
        threading.Thread(
            target=lambda: run_capture(self._adb_args("shell", "input", "text", escaped), timeout=5.0),
            daemon=True,
        ).start()
        self.status_var.set("Clipboard PC dikirim ke HP")

    def pull_phone_clipboard_to_pc(self):
        def worker():
            out = run_capture(self._adb_args("shell", "cmd", "clipboard", "get-primary-clip"), timeout=4.0).strip()
            if out and "Error" not in out:
                self.after(0, lambda: (self.clipboard_clear(), self.clipboard_append(out), self.status_var.set("Clipboard HP disalin ke PC")))

        threading.Thread(target=worker, daemon=True).start()

    def send_swipe(self, x1: int, y1: int, x2: int, y2: int):
        threading.Thread(
            target=lambda: run_capture(self._adb_args("shell", "input", "swipe", str(x1), str(y1), str(x2), str(y2), "280"), timeout=4.0),
            daemon=True,
        ).start()

    def prompt_install_apk(self):
        path = filedialog.askopenfilename(filetypes=[("Android APK", "*.apk")])
        if not path:
            return
        self.status_var.set(f"Meng-install {Path(path).name}...")

        def worker():
            out = run_capture(self._adb_args("install", "-r", path), timeout=60.0)
            self.after(0, lambda: (self.append_log(f"\n$ adb install -r {path}\n{out}\n"), self.status_var.set(f"Install APK selesai: {Path(path).name}")))

        threading.Thread(target=worker, daemon=True).start()

    def prompt_push_file(self):
        path = filedialog.askopenfilename()
        if not path:
            return
        dest = self.android_dir_var.get().rstrip("/") + "/"
        self.status_var.set(f"Mengirim {Path(path).name} ke {dest}...")

        def worker():
            out = run_capture(self._adb_args("push", path, dest), timeout=60.0)
            self.after(0, lambda: (self.append_log(f"\n$ adb push {path} {dest}\n{out}\n"), self.status_var.set("File terkirim!"), self.load_android_files()))

        threading.Thread(target=worker, daemon=True).start()

    def load_android_files(self, directory: str = None):
        if directory:
            self.android_dir_var.set(directory)
        target = self.android_dir_var.get().strip() or "/sdcard/Download"

        def worker():
            out = run_capture(self._adb_args("shell", f"ls -1p '{target}' 2>/dev/null | head -n 100"), timeout=5.0)
            items = []
            for line in out.splitlines():
                name = line.strip()
                if not name or "No such file" in name:
                    continue
                is_dir = name.endswith("/")
                clean = name[:-1] if is_dir else name
                full = f"{target.rstrip('/')}/{clean}"
                items.append((clean, "Folder" if is_dir else "File", full, is_dir))
            self.after(0, lambda: self._render_files_tree(items))

        threading.Thread(target=worker, daemon=True).start()

    def _render_files_tree(self, items: list):
        for i in self.files_tree.get_children():
            self.files_tree.delete(i)
        for clean, ftype, full, _ in items:
            self.files_tree.insert("", "end", values=(clean, ftype, full))

    def _on_file_tree_double_click(self):
        sel = self.files_tree.selection()
        if not sel:
            return
        vals = self.files_tree.item(sel[0], "values")
        if len(vals) >= 3:
            if vals[1] == "Folder":
                self.load_android_files(vals[2])
            else:
                self.pull_selected_android_file()

    def pull_selected_android_file(self):
        sel = self.files_tree.selection()
        if not sel:
            return
        vals = self.files_tree.item(sel[0], "values")
        if len(vals) < 3 or vals[1] == "Folder":
            return
        remote_path = vals[2]
        downloads_dir = Path.home() / "Downloads"
        downloads_dir.mkdir(parents=True, exist_ok=True)
        self.status_var.set(f"Mengunduh {vals[0]} ke {downloads_dir}...")

        def worker():
            out = run_capture(self._adb_args("pull", remote_path, str(downloads_dir)), timeout=60.0)
            self.after(0, lambda: (self.append_log(f"\n$ adb pull {remote_path} {downloads_dir}\n{out}\n"), self.status_var.set(f"Berhasil diunduh ke Downloads: {vals[0]}")))

        threading.Thread(target=worker, daemon=True).start()

    def take_screenshot(self, from_dex: bool = False):
        desktop = Path.home() / "Desktop"
        desktop.mkdir(parents=True, exist_ok=True)
        out_path = desktop / f"scrcpy-screenshot-{datetime.now().strftime('%Y%m%d-%H%M%S')}.png"

        def worker():
            cmd = self._adb_args("exec-out", "screencap", "-p")
            if from_dex and self.active_dex_display_id not in ("", "auto", "0"):
                cmd = self._adb_args("exec-out", "screencap", "-d", self.active_dex_display_id, "-p")
            try:
                with open(out_path, "wb") as f:
                    subprocess.run(cmd, stdout=f, timeout=8.0, creationflags=CREATE_NO_WINDOW)
                self.after(0, lambda: self.status_var.set(f"Screenshot tersimpan di Desktop: {out_path.name}"))
            except Exception as exc:
                self.after(0, lambda: self.status_var.set(f"Gagal screenshot: {exc}"))

        threading.Thread(target=worker, daemon=True).start()

    # -----------------------------------------------------------------
    # Wireless ADB & Local LAN Scanner (Windows & Linux)
    # -----------------------------------------------------------------
    def connect_wifi_ip(self):
        addr = self.tcpip_addr_var.get().strip()
        if not addr:
            return
        if ":" not in addr:
            addr = f"{addr}:5555"
            self.tcpip_addr_var.set(addr)
        self.status_var.set(f"Menghubungkan ke {addr}...")

        def worker():
            host_ip = addr.split(":")[0]
            pc_ip = get_pc_local_ip()
            if pc_ip != "-":
                run_capture([self.adb_bin, "-d", "shell", "ping", "-c", "2", "-W", "1", pc_ip], timeout=3.0)
            out = run_capture([self.adb_bin, "connect", addr], timeout=6.0)
            if "No route to host" in out or "cannot connect" in out or "failed to connect" in out:
                run_capture([self.adb_bin, "kill-server"], timeout=3.0)
                run_capture([self.adb_bin, "start-server"], timeout=4.0)
                out = run_capture([self.adb_bin, "connect", addr], timeout=6.0)
            self.after(0, lambda: (self.append_log(f"\n$ adb connect {addr}\n{out}\n"), self.status_var.set(out.strip()), self.refresh_devices()))

        threading.Thread(target=worker, daemon=True).start()

    def bridge_usb_to_wifi(self):
        self.status_var.set("Mendeteksi IP wlan0 & mengaktifkan TCP/IP port 5555...")

        def worker():
            pc_ip = get_pc_local_ip()
            ip = self.telemetry["ip"]
            if ip == "-" or ip.startswith("10."):
                ip = self._detect_device_wifi_ip_sync()
            if pc_ip != "-":
                run_capture([self.adb_bin, "-d", "shell", "ping", "-c", "2", "-W", "1", pc_ip], timeout=3.0)
            run_capture([self.adb_bin, "-d", "tcpip", "5555"], timeout=5.0)
            time.sleep(1.1)
            if ip != "-":
                target = f"{ip}:5555"
                out = run_capture([self.adb_bin, "connect", target], timeout=6.0)
                self.after(0, lambda: (self.tcpip_addr_var.set(target), self._save_settings(), self.status_var.set(out.strip()), self.refresh_devices()))
            else:
                self.after(0, lambda: self.status_var.set("Port 5555 aktif. Pastikan Wi-Fi HP menyala di jaringan yang sama."))

        threading.Thread(target=worker, daemon=True).start()

    def scan_local_wifi_devices(self):
        self.status_var.set("Memindai jaringan lokal (LAN, mDNS, wlan0 & Port 5555)...")

        def worker():
            pc_ip = get_pc_local_ip()
            self.after(0, lambda: self.pc_ip_var.set(pc_ip))
            found = []

            # 1. Connected Wi-Fi ADB devices
            dev_out = run_capture([self.adb_bin, "devices"], timeout=4.0)
            for line in dev_out.splitlines()[1:]:
                parts = line.split()
                if len(parts) >= 2 and ":" in parts[0] and parts[1] == "device":
                    found.append(f"{parts[0]} (Terhubung)")

            # 2. USB device wlan0 IP
            usb_ip = self._detect_device_wifi_ip_sync()
            if usb_ip != "-":
                if pc_ip != "-":
                    run_capture([self.adb_bin, "-d", "shell", "ping", "-c", "2", "-W", "1", pc_ip], timeout=3.0)
                item = f"{usb_ip}:5555 (IP Wi-Fi USB)"
                if item not in found:
                    found.append(item)

            # 3. mDNS Wireless Debugging services
            mdns_out = run_capture([self.adb_bin, "mdns", "services"], timeout=4.0)
            for m in re.findall(r"(\d+\.\d+\.\d+\.\d+:\d+)", mdns_out):
                item = f"{m} (mDNS)"
                if item not in found:
                    found.append(item)

            # 4. Fast parallel TCP port 5555 probe on local /24 subnet (.2..35, .100..125)
            if re.match(r"^\d+\.\d+\.\d+\.\d+$", pc_ip):
                prefix = ".".join(pc_ip.split(".")[:3])
                candidates = [f"{prefix}.{i}" for i in list(range(2, 35)) + list(range(100, 125)) if f"{prefix}.{i}" != pc_ip]
                lock = threading.Lock()

                def probe(ip_addr: str):
                    try:
                        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
                            s.settimeout(0.45)
                            if s.connect_ex((ip_addr, 5555)) == 0:
                                with lock:
                                    label = f"{ip_addr}:5555 (Port 5555 Aktif)"
                                    if not any(f.startswith(f"{ip_addr}:5555") for f in found):
                                        found.append(label)
                    except Exception:
                        pass

                threads = [threading.Thread(target=probe, args=(c,), daemon=True) for c in candidates]
                for t in threads:
                    t.start()
                for t in threads:
                    t.join(timeout=0.6)

            self.after(0, lambda: self._render_lan_results(found))

        threading.Thread(target=worker, daemon=True).start()

    def _render_lan_results(self, found: list):
        self.discovered_lan = found
        for child in self.lan_results_frame.winfo_children():
            child.destroy()
        if found:
            ttk.Label(self.lan_results_frame, text="Perangkat Ditemukan (Klik untuk Connect):", style="Card.TLabel").pack(side="left", padx=(0, 8))
            for item in found:
                host_only = item.split(" ")[0]
                ttk.Button(
                    self.lan_results_frame,
                    text=f"📶 {item}",
                    style="Success.TButton",
                    command=lambda h=host_only: (self.tcpip_addr_var.set(h), self.connect_wifi_ip()),
                ).pack(side="left", padx=4)
            self.status_var.set(f"Ditemukan {len(found)} perangkat Android di jaringan lokal!")
        else:
            self.status_var.set("Tidak ditemukan port 5555 terbuka di LAN. Hubungkan USB sekali lalu klik 'Auto USB → Wi-Fi'.")

    def pair_device(self):
        addr = self.pair_addr_var.get().strip()
        code = self.pair_code_var.get().strip()
        if not addr or not code:
            return
        self.run_diag_cmd([self.adb_bin, "pair", addr, code], f"Pairing dengan {addr}")

    def disconnect_all_wifi(self):
        self.run_diag_cmd([self.adb_bin, "disconnect"], "Memutuskan semua koneksi Wi-Fi ADB")
        self.after(800, self.refresh_devices)

    def run_diag_cmd(self, cmd: list, title: str):
        self.show_section("logs")
        self.status_var.set(f"Menjalankan: {title}...")

        def worker():
            out = run_capture(cmd, timeout=10.0)
            self.after(0, lambda: (self.append_log(f"\n$ {' '.join(cmd)}\n{out}\n"), self.status_var.set(f"Selesai: {title}")))

        threading.Thread(target=worker, daemon=True).start()

    def run_system_doctor(self):
        self.show_section("logs")
        self.status_var.set("Menjalankan System & ADB Doctor (Auto-Fix)...")

        def worker():
            lines = [
                "\n=== scrcpy-plus System & ADB Doctor (Windows & Linux) ===",
                f"[1/4] Binary Check:\n  scrcpy : {self.scrcpy_bin}\n  adb    : {self.adb_bin}\n  PC IP  : {get_pc_local_ip()}",
                "[2/4] Memulihkan koneksi ADB offline / unauthorized...",
            ]
            run_capture([self.adb_bin, "start-server"], timeout=5.0)
            run_capture([self.adb_bin, "reconnect", "offline"], timeout=5.0)
            devs = run_capture([self.adb_bin, "devices", "-l"], timeout=5.0)
            lines.append(devs.strip())

            lines.append("[3/4] Mengoptimalkan dukungan Multi-Window & Landscape DeX Android...")
            run_capture(self._adb_args("shell", "settings", "put", "global", "force_resizable_activities", "1"), timeout=4.0)
            run_capture(self._adb_args("shell", "settings", "put", "global", "enable_freeform_support", "1"), timeout=4.0)
            lines.append("  force_resizable_activities = 1 (OK)\n  enable_freeform_support    = 1 (OK)")

            did = self._detect_virtual_display_id_sync()
            lines.append(f"[4/4] Active DeX Virtual Display ID: {did if did else 'none (Display 0 only)'}")
            lines.append("=== Doctor Selesai ===\n")
            report = "\n".join(lines)
            self.after(0, lambda: (self.append_log(report), self.status_var.set("Doctor ADB selesai dijalankan"), self.refresh_devices()))

        threading.Thread(target=worker, daemon=True).start()

    def _on_close(self):
        self._save_settings()
        self.stop_scrcpy()
        self.destroy()


if __name__ == "__main__":
    app = ScrcpyPlusCrossPlatformGUI()
    app.mainloop()
