#import <Cocoa/Cocoa.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

static NSString *const kDefaultsKeySettings = @"ScrcpyPlusSavedSettingsV3";

@interface ScrcpyPlusAppDelegate : NSObject <NSApplicationDelegate>
@property(nonatomic, strong) NSWindow *window;

// Header Controls
@property(nonatomic, strong) NSPopUpButton *devicePicker;
@property(nonatomic, strong) NSMutableArray<NSString *> *deviceSerials;
@property(nonatomic, strong) NSPopUpButton *profilePicker;
@property(nonatomic, strong) NSTextField *profileDescLabel;

// Tab 1: General & Window
@property(nonatomic, strong) NSMutableArray<NSButton *> *featureButtons;
@property(nonatomic, strong) NSTextField *windowTitleField;
@property(nonatomic, strong) NSTextField *startAppField;
@property(nonatomic, strong) NSTextField *timeLimitField;
@property(nonatomic, strong) NSTextField *screenOffTimeoutField;

// Tab 2: Video, Display & Camera
@property(nonatomic, strong) NSPopUpButton *videoCodecPicker;
@property(nonatomic, strong) NSPopUpButton *maxSizePicker;
@property(nonatomic, strong) NSTextField *bitrateField;
@property(nonatomic, strong) NSTextField *fpsField;
@property(nonatomic, strong) NSPopUpButton *orientationPicker;
@property(nonatomic, strong) NSPopUpButton *renderDriverPicker;
@property(nonatomic, strong) NSTextField *videoBufferField;
@property(nonatomic, strong) NSTextField *cropField;
@property(nonatomic, strong) NSTextField *displayIdField;
@property(nonatomic, strong) NSButton *virtualDisplayCheck;
@property(nonatomic, strong) NSTextField *virtualDisplaySpecField;
@property(nonatomic, strong) NSButton *keepVdContentCheck;
@property(nonatomic, strong) NSPopUpButton *videoSourcePicker;
@property(nonatomic, strong) NSPopUpButton *cameraFacingPicker;
@property(nonatomic, strong) NSTextField *cameraSizeField;
@property(nonatomic, strong) NSTextField *cameraFpsField;
@property(nonatomic, strong) NSTextField *cameraIdField;
@property(nonatomic, strong) NSButton *cameraHighSpeedCheck;

// Tab 3: Audio & Recording
@property(nonatomic, strong) NSPopUpButton *audioSourcePicker;
@property(nonatomic, strong) NSPopUpButton *audioCodecPicker;
@property(nonatomic, strong) NSTextField *audioBitrateField;
@property(nonatomic, strong) NSTextField *audioBufferField;
@property(nonatomic, strong) NSButton *requireAudioCheck;
@property(nonatomic, strong) NSPopUpButton *recordFormatPicker;
@property(nonatomic, strong) NSButton *noPlaybackCheck;
@property(nonatomic, strong) NSTextField *extraArgsField;

// Tab 4: Input, HID & Wireless
@property(nonatomic, strong) NSPopUpButton *keyboardModePicker;
@property(nonatomic, strong) NSPopUpButton *mouseModePicker;
@property(nonatomic, strong) NSPopUpButton *gamepadModePicker;
@property(nonatomic, strong) NSPopUpButton *shortcutModPicker;
@property(nonatomic, strong) NSButton *otgCheck;
@property(nonatomic, strong) NSButton *preferTextCheck;
@property(nonatomic, strong) NSButton *rawKeyEventsCheck;
@property(nonatomic, strong) NSButton *noKeyRepeatCheck;
@property(nonatomic, strong) NSButton *legacyPasteCheck;
@property(nonatomic, strong) NSButton *noClipboardSyncCheck;
@property(nonatomic, strong) NSButton *noMouseHoverCheck;
@property(nonatomic, strong) NSTextField *tcpipAddressField;
@property(nonatomic, strong) NSTextField *pairAddressField;
@property(nonatomic, strong) NSTextField *pairCodeField;
@property(nonatomic, strong) NSTextField *sendTextField;

// Tab 5: ADB Tools & Live Log
@property(nonatomic, strong) NSTabView *tabView;
@property(nonatomic, strong) NSTextView *logTextView;

// Bottom Bar & Task State
@property(nonatomic, strong) NSTextField *statusLabel;
@property(nonatomic, strong) NSButton *startButton;
@property(nonatomic, strong) NSButton *stopButton;
@property(nonatomic, strong) NSTask *scrcpyTask;
@property(nonatomic, strong) NSPipe *outputPipe;
@end

@implementation ScrcpyPlusAppDelegate

- (NSString *)workspaceDirectoryPath {
    NSURL *bundleURL = [[NSBundle mainBundle] bundleURL];
    return bundleURL.URLByDeletingLastPathComponent.path;
}

- (NSString *)launcherPath {
    return [[self workspaceDirectoryPath] stringByAppendingPathComponent:@"scrcpy-plus"];
}

- (NSString *)adbPath {
    NSString *bundledAdb = [[self workspaceDirectoryPath] stringByAppendingPathComponent:@"adb"];
    if ([[NSFileManager defaultManager] isExecutableFileAtPath:bundledAdb]) {
        return bundledAdb;
    }
    return @"/usr/bin/env";
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    self.featureButtons = [NSMutableArray array];
    self.deviceSerials = [NSMutableArray array];

    NSString *iconPath = [[self workspaceDirectoryPath] stringByAppendingPathComponent:@"icon.png"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:iconPath]) {
        NSImage *icon = [[NSImage alloc] initWithContentsOfFile:iconPath];
        if (icon) {
            [NSApp setApplicationIconImage:icon];
        }
    }

    NSRect frame = NSMakeRect(0, 0, 780, 680);
    self.window = [[NSWindow alloc] initWithContentRect:frame
                                              styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable
                                                backing:NSBackingStoreBuffered
                                                  defer:NO];
    self.window.title = @"scrcpy-plus v3 — Android Mirror & Control Center";
    [self.window center];
    self.window.minSize = NSMakeSize(780, 680);
    self.window.maxSize = NSMakeSize(780, 680);
    self.window.contentView.wantsLayer = YES;

    NSView *content = self.window.contentView;

    // 1. Header Area
    [self buildHeaderInView:content];

    // 2. Tab View
    self.tabView = [[NSTabView alloc] initWithFrame:NSMakeRect(20, 108, 740, 445)];
    [content addSubview:self.tabView];

    [self buildGeneralTab];
    [self buildVideoCameraTab];
    [self buildAudioRecordTab];
    [self buildInputWirelessTab];
    [self buildToolsLogTab];

    // 3. Quick Device Action Bar & Footer
    [self buildFooterInView:content];

    [self refreshDevices:nil];
    [self loadSavedSettings];
    [self profileChanged:self.profilePicker];

    [self.window makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];
}

#pragma mark - UI Construction

- (void)buildHeaderInView:(NSView *)content {
    [self addLabel:@"scrcpy-plus" frame:NSMakeRect(24, 632, 220, 32) fontSize:24 weight:NSFontWeightBold to:content];
    [self addLabel:@"Mirroring layar, kamera, audio, virtual display & kendali penuh ADB" frame:NSMakeRect(26, 612, 460, 18) fontSize:12 weight:NSFontWeightRegular to:content].textColor = NSColor.secondaryLabelColor;

    NSButton *savePresetBtn = [NSButton buttonWithTitle:@"Simpan Preset" target:self action:@selector(savePresetAction:)];
    savePresetBtn.frame = NSMakeRect(535, 628, 120, 28);
    [content addSubview:savePresetBtn];

    NSButton *resetBtn = [NSButton buttonWithTitle:@"Reset Default" target:self action:@selector(resetPresetAction:)];
    resetBtn.frame = NSMakeRect(658, 628, 102, 28);
    [content addSubview:resetBtn];

    // Device Selector Row
    [self addLabel:@"Perangkat:" frame:NSMakeRect(26, 578, 75, 20) fontSize:13 weight:NSFontWeightSemibold to:content];
    self.devicePicker = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(102, 574, 245, 28) pullsDown:NO];
    [content addSubview:self.devicePicker];

    NSButton *refreshBtn = [NSButton buttonWithTitle:@"Refresh" target:self action:@selector(refreshDevices:)];
    refreshBtn.frame = NSMakeRect(352, 574, 76, 28);
    [content addSubview:refreshBtn];

    // Profile Selector
    [self addLabel:@"Profil:" frame:NSMakeRect(444, 578, 50, 20) fontSize:13 weight:NSFontWeightSemibold to:content];
    self.profilePicker = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(492, 574, 268, 28) pullsDown:NO];
    [self.profilePicker addItemsWithTitles:@[
        @"default", @"gaming", @"recording", @"presentation", @"productivity",
        @"debug", @"windowed", @"private", @"studio", @"camera",
        @"desktop", @"audio-only", @"low-latency", @"otg"
    ]];
    [self.profilePicker selectItemWithTitle:@"gaming"];
    self.profilePicker.target = self;
    self.profilePicker.action = @selector(profileChanged:);
    [content addSubview:self.profilePicker];

    self.profileDescLabel = [self addLabel:@"" frame:NSMakeRect(26, 554, 730, 18) fontSize:11.5 weight:NSFontWeightMedium to:content];
    self.profileDescLabel.textColor = NSColor.systemBlueColor;
}

- (void)buildGeneralTab {
    NSTabViewItem *item = [[NSTabViewItem alloc] initWithIdentifier:@"general"];
    item.label = @"Umum & Jendela";
    NSView *view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 720, 410)];
    item.view = view;

    [self addLabel:@"Opsi Cepat Mirroring & Jendela" frame:NSMakeRect(18, 372, 350, 20) fontSize:13 weight:NSFontWeightSemibold to:view];

    NSArray<NSString *> *featureNames = @[
        @"Koneksi Wi-Fi Otomatis (--wireless)",
        @"Fullscreen (-f)",
        @"Mode Jendela Biasa (--windowed)",
        @"Matikan Layar HP Saat Mulai (-S)",
        @"Matikan Layar HP Saat Selesai (--power-off-on-close)",
        @"Tampilkan Indikator Sentuhan (-t)",
        @"Jaga HP Tetap Menyala (-w)",
        @"Nonaktifkan Kontrol Input (-n / Read-Only)",
        @"Jendela Tanpa Bingkai (--borderless)",
        @"Jendela Selalu di Atas (--always-on-top)",
        @"Cegah Screensaver Mac (--disable-screensaver)",
        @"Duplikasi Audio di HP & Mac (--audio-dup)",
        @"Matikan Audio (--no-audio)",
        @"Matikan Video / Audio Saja (--no-video)",
        @"Tampilkan FPS di Log (--print-fps)",
        @"Rekam Sesi ke File (--record)"
    ];

    for (NSUInteger i = 0; i < featureNames.count; i++) {
        NSUInteger col = i % 2;
        NSUInteger row = i / 2;
        NSButton *btn = [NSButton checkboxWithTitle:featureNames[i] target:nil action:nil];
        btn.frame = NSMakeRect(18 + col * 355, 340 - row * 28, 345, 22);
        btn.tag = (NSInteger)i;
        [view addSubview:btn];
        [self.featureButtons addObject:btn];
    }

    NSBox *sep = [[NSBox alloc] initWithFrame:NSMakeRect(18, 108, 684, 1)];
    sep.boxType = NSBoxSeparator;
    [view addSubview:sep];

    [self addLabel:@"Pengaturan Jendela, Aplikasi & Timer" frame:NSMakeRect(18, 80, 350, 20) fontSize:13 weight:NSFontWeightSemibold to:view];

    [self addLabel:@"Judul Jendela:" frame:NSMakeRect(18, 48, 100, 20) fontSize:12 weight:NSFontWeightRegular to:view];
    self.windowTitleField = [self textFieldWithPlaceholder:@"mis. My Android" frame:NSMakeRect(120, 46, 220, 24)];
    [view addSubview:self.windowTitleField];

    [self addLabel:@"Buka Aplikasi (--start-app):" frame:NSMakeRect(365, 48, 175, 20) fontSize:12 weight:NSFontWeightRegular to:view];
    self.startAppField = [self textFieldWithPlaceholder:@"mis. ?chrome atau +com.pkg" frame:NSMakeRect(540, 46, 162, 24)];
    [view addSubview:self.startAppField];

    [self addLabel:@"Batas Waktu Sesi (detik):" frame:NSMakeRect(18, 14, 155, 20) fontSize:12 weight:NSFontWeightRegular to:view];
    self.timeLimitField = [self textFieldWithPlaceholder:@"mis. 300" frame:NSMakeRect(175, 12, 90, 24)];
    [view addSubview:self.timeLimitField];

    [self addLabel:@"Timeout Layar HP (detik):" frame:NSMakeRect(365, 14, 165, 20) fontSize:12 weight:NSFontWeightRegular to:view];
    self.screenOffTimeoutField = [self textFieldWithPlaceholder:@"mis. 60" frame:NSMakeRect(540, 12, 90, 24)];
    [view addSubview:self.screenOffTimeoutField];

    [self.tabView addTabViewItem:item];
}

- (void)buildVideoCameraTab {
    NSTabViewItem *item = [[NSTabViewItem alloc] initWithIdentifier:@"video"];
    item.label = @"Video, Layar & Kamera";
    NSView *view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 720, 410)];
    item.view = view;

    [self addLabel:@"Kualitas Video & Layar" frame:NSMakeRect(18, 372, 300, 20) fontSize:13 weight:NSFontWeightSemibold to:view];

    [self addLabel:@"Codec Video:" frame:NSMakeRect(18, 340, 95, 20) fontSize:12 weight:NSFontWeightRegular to:view];
    self.videoCodecPicker = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(115, 336, 130, 26) pullsDown:NO];
    [self.videoCodecPicker addItemsWithTitles:@[@"Default (h264)", @"h264", @"h265", @"av1"]];
    [view addSubview:self.videoCodecPicker];

    [self addLabel:@"Resolusi Maks:" frame:NSMakeRect(265, 340, 95, 20) fontSize:12 weight:NSFontWeightRegular to:view];
    self.maxSizePicker = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(365, 336, 140, 26) pullsDown:NO];
    [self.maxSizePicker addItemsWithTitles:@[@"Default (Asli)", @"720", @"1024", @"1080", @"1280", @"1440", @"1920", @"2560"]];
    [view addSubview:self.maxSizePicker];

    [self addLabel:@"Render:" frame:NSMakeRect(520, 340, 55, 20) fontSize:12 weight:NSFontWeightRegular to:view];
    self.renderDriverPicker = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(575, 336, 125, 26) pullsDown:NO];
    [self.renderDriverPicker addItemsWithTitles:@[@"Default", @"metal", @"opengl", @"opengles2", @"software"]];
    [view addSubview:self.renderDriverPicker];

    [self addLabel:@"Bitrate Video:" frame:NSMakeRect(18, 302, 95, 20) fontSize:12 weight:NSFontWeightRegular to:view];
    self.bitrateField = [self textFieldWithPlaceholder:@"mis. 12M, 20M" frame:NSMakeRect(115, 300, 125, 24)];
    [view addSubview:self.bitrateField];

    [self addLabel:@"Maks FPS:" frame:NSMakeRect(265, 302, 95, 20) fontSize:12 weight:NSFontWeightRegular to:view];
    self.fpsField = [self textFieldWithPlaceholder:@"mis. 60, 120" frame:NSMakeRect(365, 300, 100, 24)];
    [view addSubview:self.fpsField];

    [self addLabel:@"Orientasi:" frame:NSMakeRect(485, 302, 70, 20) fontSize:12 weight:NSFontWeightRegular to:view];
    self.orientationPicker = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(555, 298, 145, 26) pullsDown:NO];
    [self.orientationPicker addItemsWithTitles:@[@"Default", @"0", @"90", @"180", @"270", @"flip0", @"flip90", @"flip180", @"flip270"]];
    [view addSubview:self.orientationPicker];

    [self addLabel:@"Buffer Video (ms):" frame:NSMakeRect(18, 264, 115, 20) fontSize:12 weight:NSFontWeightRegular to:view];
    self.videoBufferField = [self textFieldWithPlaceholder:@"0" frame:NSMakeRect(135, 262, 75, 24)];
    [view addSubview:self.videoBufferField];

    [self addLabel:@"Crop (W:H:X:Y):" frame:NSMakeRect(230, 264, 105, 20) fontSize:12 weight:NSFontWeightRegular to:view];
    self.cropField = [self textFieldWithPlaceholder:@"mis. 1080:1920:0:0" frame:NSMakeRect(338, 262, 150, 24)];
    [view addSubview:self.cropField];

    [self addLabel:@"Display ID:" frame:NSMakeRect(508, 264, 75, 20) fontSize:12 weight:NSFontWeightRegular to:view];
    self.displayIdField = [self textFieldWithPlaceholder:@"0" frame:NSMakeRect(585, 262, 65, 24)];
    [view addSubview:self.displayIdField];

    NSBox *sep1 = [[NSBox alloc] initWithFrame:NSMakeRect(18, 244, 684, 1)];
    sep1.boxType = NSBoxSeparator;
    [view addSubview:sep1];

    // Virtual Display Section
    [self addLabel:@"Layar Virtual Baru (Mode Desktop / Multi-Display)" frame:NSMakeRect(18, 216, 400, 20) fontSize:13 weight:NSFontWeightSemibold to:view];
    self.virtualDisplayCheck = [NSButton checkboxWithTitle:@"Buat Layar Virtual (--new-display)" target:nil action:nil];
    self.virtualDisplayCheck.frame = NSMakeRect(18, 188, 250, 22);
    [view addSubview:self.virtualDisplayCheck];

    [self addLabel:@"Resolusi/DPI:" frame:NSMakeRect(280, 188, 90, 20) fontSize:12 weight:NSFontWeightRegular to:view];
    self.virtualDisplaySpecField = [self textFieldWithPlaceholder:@"mis. 1920x1080/280" frame:NSMakeRect(370, 186, 155, 24)];
    [view addSubview:self.virtualDisplaySpecField];

    self.keepVdContentCheck = [NSButton checkboxWithTitle:@"Pertahankan App Saat Tutup (--no-vd-destroy-content)" target:nil action:nil];
    self.keepVdContentCheck.frame = NSMakeRect(18, 160, 420, 22);
    [view addSubview:self.keepVdContentCheck];

    NSBox *sep2 = [[NSBox alloc] initWithFrame:NSMakeRect(18, 144, 684, 1)];
    sep2.boxType = NSBoxSeparator;
    [view addSubview:sep2];

    // Camera Mirroring Section
    [self addLabel:@"Mirroring Kamera HP (Android 12+)" frame:NSMakeRect(18, 116, 350, 20) fontSize:13 weight:NSFontWeightSemibold to:view];

    [self addLabel:@"Sumber Video:" frame:NSMakeRect(18, 84, 95, 20) fontSize:12 weight:NSFontWeightRegular to:view];
    self.videoSourcePicker = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(115, 80, 140, 26) pullsDown:NO];
    [self.videoSourcePicker addItemsWithTitles:@[@"Default (display)", @"display", @"camera"]];
    [view addSubview:self.videoSourcePicker];

    [self addLabel:@"Arah Kamera:" frame:NSMakeRect(275, 84, 90, 20) fontSize:12 weight:NSFontWeightRegular to:view];
    self.cameraFacingPicker = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(368, 80, 130, 26) pullsDown:NO];
    [self.cameraFacingPicker addItemsWithTitles:@[@"Default", @"back", @"front", @"external"]];
    [view addSubview:self.cameraFacingPicker];

    [self addLabel:@"Camera ID:" frame:NSMakeRect(515, 84, 75, 20) fontSize:12 weight:NSFontWeightRegular to:view];
    self.cameraIdField = [self textFieldWithPlaceholder:@"mis. 0, 1" frame:NSMakeRect(590, 82, 80, 24)];
    [view addSubview:self.cameraIdField];

    [self addLabel:@"Ukuran Kamera:" frame:NSMakeRect(18, 44, 100, 20) fontSize:12 weight:NSFontWeightRegular to:view];
    self.cameraSizeField = [self textFieldWithPlaceholder:@"mis. 1920x1080" frame:NSMakeRect(120, 42, 135, 24)];
    [view addSubview:self.cameraSizeField];

    [self addLabel:@"FPS Kamera:" frame:NSMakeRect(275, 44, 90, 20) fontSize:12 weight:NSFontWeightRegular to:view];
    self.cameraFpsField = [self textFieldWithPlaceholder:@"mis. 30, 60" frame:NSMakeRect(368, 42, 95, 24)];
    [view addSubview:self.cameraFpsField];

    self.cameraHighSpeedCheck = [NSButton checkboxWithTitle:@"High-Speed Camera (--camera-high-speed)" target:nil action:nil];
    self.cameraHighSpeedCheck.frame = NSMakeRect(480, 43, 235, 22);
    [view addSubview:self.cameraHighSpeedCheck];

    [self.tabView addTabViewItem:item];
}

- (void)buildAudioRecordTab {
    NSTabViewItem *item = [[NSTabViewItem alloc] initWithIdentifier:@"audio"];
    item.label = @"Audio & Rekaman";
    NSView *view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 720, 410)];
    item.view = view;

    [self addLabel:@"Konfigurasi Audio" frame:NSMakeRect(18, 372, 300, 20) fontSize:13 weight:NSFontWeightSemibold to:view];

    [self addLabel:@"Sumber Audio:" frame:NSMakeRect(18, 336, 100, 20) fontSize:12 weight:NSFontWeightRegular to:view];
    self.audioSourcePicker = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(125, 332, 220, 26) pullsDown:NO];
    [self.audioSourcePicker addItemsWithTitles:@[
        @"Default (output)", @"output", @"playback", @"mic", @"mic-unprocessed",
        @"mic-camcorder", @"mic-voice-recognition", @"mic-voice-communication",
        @"voice-call", @"voice-call-uplink", @"voice-call-downlink", @"voice-performance"
    ]];
    [view addSubview:self.audioSourcePicker];

    [self addLabel:@"Codec Audio:" frame:NSMakeRect(370, 336, 90, 20) fontSize:12 weight:NSFontWeightRegular to:view];
    self.audioCodecPicker = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(465, 332, 150, 26) pullsDown:NO];
    [self.audioCodecPicker addItemsWithTitles:@[@"Default (opus)", @"opus", @"aac", @"flac", @"raw"]];
    [view addSubview:self.audioCodecPicker];

    [self addLabel:@"Bitrate Audio:" frame:NSMakeRect(18, 294, 100, 20) fontSize:12 weight:NSFontWeightRegular to:view];
    self.audioBitrateField = [self textFieldWithPlaceholder:@"mis. 128K, 256K" frame:NSMakeRect(125, 292, 130, 24)];
    [view addSubview:self.audioBitrateField];

    [self addLabel:@"Buffer Audio (ms):" frame:NSMakeRect(285, 294, 120, 20) fontSize:12 weight:NSFontWeightRegular to:view];
    self.audioBufferField = [self textFieldWithPlaceholder:@"mis. 50" frame:NSMakeRect(410, 292, 90, 24)];
    [view addSubview:self.audioBufferField];

    self.requireAudioCheck = [NSButton checkboxWithTitle:@"Wajibkan Audio Aktif (--require-audio)" target:nil action:nil];
    self.requireAudioCheck.frame = NSMakeRect(18, 258, 300, 22);
    [view addSubview:self.requireAudioCheck];

    NSBox *sep1 = [[NSBox alloc] initWithFrame:NSMakeRect(18, 236, 684, 1)];
    sep1.boxType = NSBoxSeparator;
    [view addSubview:sep1];

    [self addLabel:@"Perekaman Layar & Audio" frame:NSMakeRect(18, 204, 300, 20) fontSize:13 weight:NSFontWeightSemibold to:view];

    [self addLabel:@"Format Rekaman:" frame:NSMakeRect(18, 168, 115, 20) fontSize:12 weight:NSFontWeightRegular to:view];
    self.recordFormatPicker = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(138, 164, 160, 26) pullsDown:NO];
    [self.recordFormatPicker addItemsWithTitles:@[@"Otomatis (mp4)", @"mp4", @"mkv", @"m4a", @"mka", @"opus", @"aac", @"flac", @"wav"]];
    [view addSubview:self.recordFormatPicker];

    self.noPlaybackCheck = [NSButton checkboxWithTitle:@"Rekam di Latar Belakang Tanpa Playback (-N / --no-playback)" target:nil action:nil];
    self.noPlaybackCheck.frame = NSMakeRect(320, 166, 380, 22);
    [view addSubview:self.noPlaybackCheck];

    NSBox *sep2 = [[NSBox alloc] initWithFrame:NSMakeRect(18, 136, 684, 1)];
    sep2.boxType = NSBoxSeparator;
    [view addSubview:sep2];

    [self addLabel:@"Argumen Tambahan Kustom (Extra Raw scrcpy Flags)" frame:NSMakeRect(18, 104, 420, 20) fontSize:13 weight:NSFontWeightSemibold to:view];
    [self addLabel:@"Masukkan flag scrcpy lanjutan jika diperlukan (dipisahkan spasi):" frame:NSMakeRect(18, 82, 480, 18) fontSize:11.5 weight:NSFontWeightRegular to:view].textColor = NSColor.secondaryLabelColor;
    self.extraArgsField = [self textFieldWithPlaceholder:@"mis. --window-x 100 --window-y 100 --display-ime-policy=local" frame:NSMakeRect(18, 50, 684, 26)];
    [view addSubview:self.extraArgsField];

    [self.tabView addTabViewItem:item];
}

- (void)buildInputWirelessTab {
    NSTabViewItem *item = [[NSTabViewItem alloc] initWithIdentifier:@"input"];
    item.label = @"Input, HID & Wi-Fi";
    NSView *view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 720, 410)];
    item.view = view;

    [self addLabel:@"Mode Keyboard, Mouse, Gamepad & OTG" frame:NSMakeRect(18, 372, 350, 20) fontSize:13 weight:NSFontWeightSemibold to:view];

    [self addLabel:@"Keyboard:" frame:NSMakeRect(18, 338, 70, 20) fontSize:12 weight:NSFontWeightRegular to:view];
    self.keyboardModePicker = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(90, 334, 135, 26) pullsDown:NO];
    [self.keyboardModePicker addItemsWithTitles:@[@"Default (sdk)", @"sdk", @"uhid", @"aoa", @"disabled"]];
    [view addSubview:self.keyboardModePicker];

    [self addLabel:@"Mouse:" frame:NSMakeRect(245, 338, 55, 20) fontSize:12 weight:NSFontWeightRegular to:view];
    self.mouseModePicker = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(300, 334, 135, 26) pullsDown:NO];
    [self.mouseModePicker addItemsWithTitles:@[@"Default (sdk)", @"sdk", @"uhid", @"aoa", @"disabled"]];
    [view addSubview:self.mouseModePicker];

    [self addLabel:@"Gamepad:" frame:NSMakeRect(455, 338, 70, 20) fontSize:12 weight:NSFontWeightRegular to:view];
    self.gamepadModePicker = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(525, 334, 155, 26) pullsDown:NO];
    [self.gamepadModePicker addItemsWithTitles:@[@"Default (disabled)", @"uhid", @"aoa", @"disabled"]];
    [view addSubview:self.gamepadModePicker];

    [self addLabel:@"Shortcut Mod:" frame:NSMakeRect(18, 300, 90, 20) fontSize:12 weight:NSFontWeightRegular to:view];
    self.shortcutModPicker = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(112, 296, 165, 26) pullsDown:NO];
    [self.shortcutModPicker addItemsWithTitles:@[@"Default (lalt,lsuper)", @"lalt,lsuper", @"lctrl,lsuper", @"lalt", @"lsuper", @"lctrl"]];
    [view addSubview:self.shortcutModPicker];

    self.otgCheck = [NSButton checkboxWithTitle:@"Mode USB OTG (--otg)" target:nil action:nil];
    self.otgCheck.frame = NSMakeRect(300, 298, 185, 22);
    [view addSubview:self.otgCheck];

    self.preferTextCheck = [NSButton checkboxWithTitle:@"Prefer Text (--prefer-text)" target:nil action:nil];
    self.preferTextCheck.frame = NSMakeRect(495, 298, 200, 22);
    [view addSubview:self.preferTextCheck];

    self.rawKeyEventsCheck = [NSButton checkboxWithTitle:@"Raw Key Events (--raw-key-events)" target:nil action:nil];
    self.rawKeyEventsCheck.frame = NSMakeRect(18, 268, 240, 22);
    [view addSubview:self.rawKeyEventsCheck];

    self.noKeyRepeatCheck = [NSButton checkboxWithTitle:@"Tanpa Key Repeat (--no-key-repeat)" target:nil action:nil];
    self.noKeyRepeatCheck.frame = NSMakeRect(265, 268, 235, 22);
    [view addSubview:self.noKeyRepeatCheck];

    self.legacyPasteCheck = [NSButton checkboxWithTitle:@"Legacy Paste (--legacy-paste)" target:nil action:nil];
    self.legacyPasteCheck.frame = NSMakeRect(505, 268, 205, 22);
    [view addSubview:self.legacyPasteCheck];

    self.noClipboardSyncCheck = [NSButton checkboxWithTitle:@"Matikan Auto-Sync Clipboard (--no-clipboard-autosync)" target:nil action:nil];
    self.noClipboardSyncCheck.frame = NSMakeRect(18, 240, 355, 22);
    [view addSubview:self.noClipboardSyncCheck];

    self.noMouseHoverCheck = [NSButton checkboxWithTitle:@"Abaikan Mouse Hover (--no-mouse-hover)" target:nil action:nil];
    self.noMouseHoverCheck.frame = NSMakeRect(380, 240, 300, 22);
    [view addSubview:self.noMouseHoverCheck];

    NSBox *sep1 = [[NSBox alloc] initWithFrame:NSMakeRect(18, 222, 684, 1)];
    sep1.boxType = NSBoxSeparator;
    [view addSubview:sep1];

    // Wireless ADB & Pairing
    [self addLabel:@"Koneksi Wi-Fi / TCP-IP & Wireless Pairing" frame:NSMakeRect(18, 194, 360, 20) fontSize:13 weight:NSFontWeightSemibold to:view];

    [self addLabel:@"IP:Port Perangkat:" frame:NSMakeRect(18, 160, 120, 20) fontSize:12 weight:NSFontWeightRegular to:view];
    self.tcpipAddressField = [self textFieldWithPlaceholder:@"mis. 192.168.1.15:5555" frame:NSMakeRect(140, 158, 190, 24)];
    [view addSubview:self.tcpipAddressField];

    NSButton *connectIpBtn = [NSButton buttonWithTitle:@"Connect IP" target:self action:@selector(connectWirelessIP:)];
    connectIpBtn.frame = NSMakeRect(340, 156, 100, 28);
    [view addSubview:connectIpBtn];

    NSButton *usbToWifiBtn = [NSButton buttonWithTitle:@"USB → Wi-Fi (5555)" target:self action:@selector(bridgeUsbToWifi:)];
    usbToWifiBtn.frame = NSMakeRect(445, 156, 145, 28);
    [view addSubview:usbToWifiBtn];

    NSButton *disconnectBtn = [NSButton buttonWithTitle:@"Disconnect" target:self action:@selector(disconnectWireless:)];
    disconnectBtn.frame = NSMakeRect(595, 156, 100, 28);
    [view addSubview:disconnectBtn];

    [self addLabel:@"Pair IP:Port (Android 11+):" frame:NSMakeRect(18, 120, 165, 20) fontSize:12 weight:NSFontWeightRegular to:view];
    self.pairAddressField = [self textFieldWithPlaceholder:@"mis. 192.168.1.15:39123" frame:NSMakeRect(185, 118, 175, 24)];
    [view addSubview:self.pairAddressField];

    [self addLabel:@"Kode Pair:" frame:NSMakeRect(372, 120, 70, 20) fontSize:12 weight:NSFontWeightRegular to:view];
    self.pairCodeField = [self textFieldWithPlaceholder:@"6 digit" frame:NSMakeRect(442, 118, 95, 24)];
    [view addSubview:self.pairCodeField];

    NSButton *pairBtn = [NSButton buttonWithTitle:@"Pair Perangkat" target:self action:@selector(pairWirelessDevice:)];
    pairBtn.frame = NSMakeRect(548, 116, 147, 28);
    [view addSubview:pairBtn];

    NSBox *sep2 = [[NSBox alloc] initWithFrame:NSMakeRect(18, 96, 684, 1)];
    sep2.boxType = NSBoxSeparator;
    [view addSubview:sep2];

    [self addLabel:@"Ketik Teks Cepat ke Perangkat" frame:NSMakeRect(18, 66, 260, 20) fontSize:13 weight:NSFontWeightSemibold to:view];
    self.sendTextField = [self textFieldWithPlaceholder:@"Ketik teks untuk dikirim ke HP..." frame:NSMakeRect(18, 34, 540, 26)];
    [view addSubview:self.sendTextField];

    NSButton *sendTextBtn = [NSButton buttonWithTitle:@"Kirim Teks" target:self action:@selector(sendTextAction:)];
    sendTextBtn.frame = NSMakeRect(568, 32, 130, 28);
    [view addSubview:sendTextBtn];

    [self.tabView addTabViewItem:item];
}

- (void)buildToolsLogTab {
    NSTabViewItem *item = [[NSTabViewItem alloc] initWithIdentifier:@"tools"];
    item.label = @"Alat ADB & Log Live";
    NSView *view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 720, 410)];
    item.view = view;

    NSArray<NSDictionary *> *toolSpecs = @[
        @{@"title": @"Info Perangkat", @"arg": @"--device-info"},
        @{@"title": @"Daftar Aplikasi", @"arg": @"--list-apps"},
        @{@"title": @"Daftar Kamera", @"arg": @"--list-cameras"},
        @{@"title": @"Ukuran Kamera", @"arg": @"--list-camera-sizes"},
        @{@"title": @"Daftar Layar", @"arg": @"--list-displays"},
        @{@"title": @"Daftar Encoder", @"arg": @"--list-encoders"}
    ];

    for (NSUInteger i = 0; i < toolSpecs.count; i++) {
        NSButton *btn = [NSButton buttonWithTitle:toolSpecs[i][@"title"] target:self action:@selector(runDiagnosticTool:)];
        btn.frame = NSMakeRect(16 + i * 102, 366, 100, 28);
        btn.identifier = toolSpecs[i][@"arg"];
        [view addSubview:btn];
    }

    NSButton *clearLogBtn = [NSButton buttonWithTitle:@"Bersihkan" target:self action:@selector(clearLogAction:)];
    clearLogBtn.frame = NSMakeRect(630, 366, 80, 28);
    [view addSubview:clearLogBtn];

    NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(16, 14, 694, 342)];
    scrollView.hasVerticalScroller = YES;
    scrollView.borderType = NSBezelBorder;

    self.logTextView = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, 694, 342)];
    self.logTextView.editable = NO;
    self.logTextView.selectable = YES;
    self.logTextView.font = [NSFont monospacedSystemFontOfSize:11.5 weight:NSFontWeightRegular];
    self.logTextView.textContainerInset = NSMakeSize(6, 6);
    self.logTextView.string = @"Siap. Log sesi scrcpy dan hasil pemeriksaan ADB akan tampil di sini.\n";
    scrollView.documentView = self.logTextView;
    [view addSubview:scrollView];

    [self.tabView addTabViewItem:item];
}

- (void)buildFooterInView:(NSView *)content {
    // Quick Hardware Control Row
    NSArray<NSDictionary *> *quickKeys = @[
        @{@"title": @"Home", @"key": @"3"},
        @{@"title": @"Back", @"key": @"4"},
        @{@"title": @"Recent", @"key": @"187"},
        @{@"title": @"Power", @"key": @"26"},
        @{@"title": @"Vol -", @"key": @"25"},
        @{@"title": @"Vol +", @"key": @"24"},
        @{@"title": @"Notifikasi", @"key": @"83"}
    ];

    for (NSUInteger i = 0; i < quickKeys.count; i++) {
        NSButton *btn = [NSButton buttonWithTitle:quickKeys[i][@"title"] target:self action:@selector(sendQuickKeyevent:)];
        btn.frame = NSMakeRect(20 + i * 66, 68, 64, 26);
        btn.identifier = quickKeys[i][@"key"];
        btn.controlSize = NSControlSizeSmall;
        [content addSubview:btn];
    }

    NSButton *screenshotBtn = [NSButton buttonWithTitle:@"Screenshot" target:self action:@selector(takeScreenshotAction:)];
    screenshotBtn.frame = NSMakeRect(488, 68, 90, 26);
    screenshotBtn.controlSize = NSControlSizeSmall;
    [content addSubview:screenshotBtn];

    NSButton *installApkBtn = [NSButton buttonWithTitle:@"Install APK..." target:self action:@selector(installApkAction:)];
    installApkBtn.frame = NSMakeRect(580, 68, 92, 26);
    installApkBtn.controlSize = NSControlSizeSmall;
    [content addSubview:installApkBtn];

    NSButton *pushFileBtn = [NSButton buttonWithTitle:@"Kirim File..." target:self action:@selector(pushFileAction:)];
    pushFileBtn.frame = NSMakeRect(674, 68, 86, 26);
    pushFileBtn.controlSize = NSControlSizeSmall;
    [content addSubview:pushFileBtn];

    // Status & Start/Stop Row
    self.stopButton = [NSButton buttonWithTitle:@"Stop" target:self action:@selector(stopScrcpy:)];
    self.stopButton.frame = NSMakeRect(20, 18, 95, 34);
    self.stopButton.enabled = NO;
    [content addSubview:self.stopButton];

    self.statusLabel = [self addLabel:@"Siap" frame:NSMakeRect(128, 25, 480, 20) fontSize:12.5 weight:NSFontWeightMedium to:content];
    self.statusLabel.textColor = NSColor.secondaryLabelColor;

    self.startButton = [NSButton buttonWithTitle:@"Start scrcpy" target:self action:@selector(startScrcpy:)];
    self.startButton.frame = NSMakeRect(620, 18, 140, 34);
    self.startButton.bezelStyle = NSBezelStyleRounded;
    self.startButton.keyEquivalent = @"\r";
    [content addSubview:self.startButton];
}

#pragma mark - Helpers

- (NSTextField *)addLabel:(NSString *)text frame:(NSRect)frame fontSize:(CGFloat)size weight:(CGFloat)weight to:(NSView *)view {
    NSTextField *label = [NSTextField labelWithString:text];
    label.frame = frame;
    label.font = [NSFont systemFontOfSize:size weight:weight];
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    [view addSubview:label];
    return label;
}

- (NSTextField *)textFieldWithPlaceholder:(NSString *)placeholder frame:(NSRect)frame {
    NSTextField *field = [[NSTextField alloc] initWithFrame:frame];
    field.placeholderString = placeholder;
    field.stringValue = @"";
    field.font = [NSFont systemFontOfSize:12];
    return field;
}

- (BOOL)isFeatureEnabled:(NSUInteger)index {
    return index < self.featureButtons.count && self.featureButtons[index].state == NSControlStateValueOn;
}

- (NSString *)selectedSerial {
    NSInteger idx = self.devicePicker.indexOfSelectedItem;
    if (idx > 0 && idx < (NSInteger)self.deviceSerials.count) {
        return self.deviceSerials[(NSUInteger)idx];
    }
    return @"";
}

- (void)appendLog:(NSString *)text {
    if (text.length == 0) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSAttributedString *attr = [[NSAttributedString alloc] initWithString:text attributes:@{
            NSFontAttributeName: [NSFont monospacedSystemFontOfSize:11.5 weight:NSFontWeightRegular],
            NSForegroundColorAttributeName: NSColor.labelColor
        }];
        [self.logTextView.textStorage appendAttributedString:attr];
        [self.logTextView scrollRangeToVisible:NSMakeRange(self.logTextView.string.length, 0)];
    });
}

#pragma mark - Profile Description & Presets

- (void)profileChanged:(id)sender {
    NSString *profile = self.profilePicker.titleOfSelectedItem;
    NSDictionary<NSString *, NSString *> *descriptions = @{
        @"default": @"Default: Pengaturan standar scrcpy yang seimbang untuk penggunaan umum.",
        @"gaming": @"Gaming: Fullscreen, 60 FPS, bitrate 20M, indikator sentuhan aktif & cegah screensaver.",
        @"recording": @"Recording: Otomatis merekam video kualitas tinggi (30M bitrate + audio output).",
        @"presentation": @"Presentation: Fullscreen, tampilkan sentuhan & bitrate 12M untuk demo presentasi.",
        @"productivity": @"Productivity: Jaga HP tetap menyala (-w), bitrate 8M, hemat daya untuk kerja harian.",
        @"debug": @"Debug: Tampilkan sentuhan, cetak FPS di log, cegah screensaver (bitrate 10M).",
        @"windowed": @"Windowed: Mode jendela desktop normal (bukan fullscreen), bitrate 9M.",
        @"private": @"Private: Matikan layar fisik HP (-S) selama mirroring & saat aplikasi ditutup.",
        @"studio": @"Studio: Kualitas visual tinggi H.265 15M bitrate untuk kebutuhan konten & streaming.",
        @"camera": @"Camera: Mirror kamera HP secara langsung (Android 12+, default 1080p 30fps).",
        @"desktop": @"Desktop / DeX: Buat layar virtual sekunder 1920x1080/280 terpisah dari layar utama HP.",
        @"audio-only": @"Audio-Only: Streaming suara dari HP ke Mac tanpa menampilkan jendela video.",
        @"low-latency": @"Low-Latency: Resolusi maks 1024px, bitrate 4M, 60 FPS — sangat ringan untuk Wi-Fi.",
        @"otg": @"OTG Mode: Gunakan keyboard & mouse Mac di HP lewat USB tanpa mirroring layar."
    };
    self.profileDescLabel.stringValue = descriptions[profile] ?: @"";
}

- (void)savePresetAction:(id)sender {
    NSMutableArray<NSNumber *> *checks = [NSMutableArray array];
    for (NSButton *btn in self.featureButtons) {
        [checks addObject:@(btn.state == NSControlStateValueOn)];
    }
    NSDictionary *dict = @{
        @"profile": self.profilePicker.titleOfSelectedItem ?: @"gaming",
        @"checks": checks,
        @"windowTitle": self.windowTitleField.stringValue ?: @"",
        @"startApp": self.startAppField.stringValue ?: @"",
        @"timeLimit": self.timeLimitField.stringValue ?: @"",
        @"screenOffTimeout": self.screenOffTimeoutField.stringValue ?: @"",
        @"videoCodec": self.videoCodecPicker.titleOfSelectedItem ?: @"Default (h264)",
        @"maxSize": self.maxSizePicker.titleOfSelectedItem ?: @"Default (Asli)",
        @"renderDriver": self.renderDriverPicker.titleOfSelectedItem ?: @"Default",
        @"bitrate": self.bitrateField.stringValue ?: @"",
        @"fps": self.fpsField.stringValue ?: @"",
        @"orientation": self.orientationPicker.titleOfSelectedItem ?: @"Default",
        @"videoBuffer": self.videoBufferField.stringValue ?: @"",
        @"crop": self.cropField.stringValue ?: @"",
        @"displayId": self.displayIdField.stringValue ?: @"",
        @"virtualDisplay": @(self.virtualDisplayCheck.state == NSControlStateValueOn),
        @"virtualDisplaySpec": self.virtualDisplaySpecField.stringValue ?: @"",
        @"keepVdContent": @(self.keepVdContentCheck.state == NSControlStateValueOn),
        @"videoSource": self.videoSourcePicker.titleOfSelectedItem ?: @"Default (display)",
        @"cameraFacing": self.cameraFacingPicker.titleOfSelectedItem ?: @"Default",
        @"cameraId": self.cameraIdField.stringValue ?: @"",
        @"cameraSize": self.cameraSizeField.stringValue ?: @"",
        @"cameraFps": self.cameraFpsField.stringValue ?: @"",
        @"cameraHighSpeed": @(self.cameraHighSpeedCheck.state == NSControlStateValueOn),
        @"audioSource": self.audioSourcePicker.titleOfSelectedItem ?: @"Default (output)",
        @"audioCodec": self.audioCodecPicker.titleOfSelectedItem ?: @"Default (opus)",
        @"audioBitrate": self.audioBitrateField.stringValue ?: @"",
        @"audioBuffer": self.audioBufferField.stringValue ?: @"",
        @"requireAudio": @(self.requireAudioCheck.state == NSControlStateValueOn),
        @"recordFormat": self.recordFormatPicker.titleOfSelectedItem ?: @"Otomatis (mp4)",
        @"noPlayback": @(self.noPlaybackCheck.state == NSControlStateValueOn),
        @"extraArgs": self.extraArgsField.stringValue ?: @"",
        @"keyboardMode": self.keyboardModePicker.titleOfSelectedItem ?: @"Default (sdk)",
        @"mouseMode": self.mouseModePicker.titleOfSelectedItem ?: @"Default (sdk)",
        @"gamepadMode": self.gamepadModePicker.titleOfSelectedItem ?: @"Default (disabled)",
        @"shortcutMod": self.shortcutModPicker.titleOfSelectedItem ?: @"Default (lalt,lsuper)",
        @"otg": @(self.otgCheck.state == NSControlStateValueOn),
        @"preferText": @(self.preferTextCheck.state == NSControlStateValueOn),
        @"rawKeyEvents": @(self.rawKeyEventsCheck.state == NSControlStateValueOn),
        @"noKeyRepeat": @(self.noKeyRepeatCheck.state == NSControlStateValueOn),
        @"legacyPaste": @(self.legacyPasteCheck.state == NSControlStateValueOn),
        @"noClipboardSync": @(self.noClipboardSyncCheck.state == NSControlStateValueOn),
        @"noMouseHover": @(self.noMouseHoverCheck.state == NSControlStateValueOn),
        @"tcpipAddress": self.tcpipAddressField.stringValue ?: @""
    };
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:kDefaultsKeySettings];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.statusLabel.stringValue = @"Preset konfigurasi berhasil disimpan";
}

- (void)loadSavedSettings {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kDefaultsKeySettings];
    if (!dict) return;

    if (dict[@"profile"]) [self.profilePicker selectItemWithTitle:dict[@"profile"]];
    NSArray *checks = dict[@"checks"];
    if ([checks isKindOfClass:[NSArray class]]) {
        for (NSUInteger i = 0; i < checks.count && i < self.featureButtons.count; i++) {
            self.featureButtons[i].state = [checks[i] boolValue] ? NSControlStateValueOn : NSControlStateValueOff;
        }
    }
    self.windowTitleField.stringValue = dict[@"windowTitle"] ?: @"";
    self.startAppField.stringValue = dict[@"startApp"] ?: @"";
    self.timeLimitField.stringValue = dict[@"timeLimit"] ?: @"";
    self.screenOffTimeoutField.stringValue = dict[@"screenOffTimeout"] ?: @"";
    if (dict[@"videoCodec"]) [self.videoCodecPicker selectItemWithTitle:dict[@"videoCodec"]];
    if (dict[@"maxSize"]) [self.maxSizePicker selectItemWithTitle:dict[@"maxSize"]];
    if (dict[@"renderDriver"]) [self.renderDriverPicker selectItemWithTitle:dict[@"renderDriver"]];
    self.bitrateField.stringValue = dict[@"bitrate"] ?: @"";
    self.fpsField.stringValue = dict[@"fps"] ?: @"";
    if (dict[@"orientation"]) [self.orientationPicker selectItemWithTitle:dict[@"orientation"]];
    self.videoBufferField.stringValue = dict[@"videoBuffer"] ?: @"";
    self.cropField.stringValue = dict[@"crop"] ?: @"";
    self.displayIdField.stringValue = dict[@"displayId"] ?: @"";
    self.virtualDisplayCheck.state = [dict[@"virtualDisplay"] boolValue] ? NSControlStateValueOn : NSControlStateValueOff;
    self.virtualDisplaySpecField.stringValue = dict[@"virtualDisplaySpec"] ?: @"";
    self.keepVdContentCheck.state = [dict[@"keepVdContent"] boolValue] ? NSControlStateValueOn : NSControlStateValueOff;
    if (dict[@"videoSource"]) [self.videoSourcePicker selectItemWithTitle:dict[@"videoSource"]];
    if (dict[@"cameraFacing"]) [self.cameraFacingPicker selectItemWithTitle:dict[@"cameraFacing"]];
    self.cameraIdField.stringValue = dict[@"cameraId"] ?: @"";
    self.cameraSizeField.stringValue = dict[@"cameraSize"] ?: @"";
    self.cameraFpsField.stringValue = dict[@"cameraFps"] ?: @"";
    self.cameraHighSpeedCheck.state = [dict[@"cameraHighSpeed"] boolValue] ? NSControlStateValueOn : NSControlStateValueOff;
    if (dict[@"audioSource"]) [self.audioSourcePicker selectItemWithTitle:dict[@"audioSource"]];
    if (dict[@"audioCodec"]) [self.audioCodecPicker selectItemWithTitle:dict[@"audioCodec"]];
    self.audioBitrateField.stringValue = dict[@"audioBitrate"] ?: @"";
    self.audioBufferField.stringValue = dict[@"audioBuffer"] ?: @"";
    self.requireAudioCheck.state = [dict[@"requireAudio"] boolValue] ? NSControlStateValueOn : NSControlStateValueOff;
    if (dict[@"recordFormat"]) [self.recordFormatPicker selectItemWithTitle:dict[@"recordFormat"]];
    self.noPlaybackCheck.state = [dict[@"noPlayback"] boolValue] ? NSControlStateValueOn : NSControlStateValueOff;
    self.extraArgsField.stringValue = dict[@"extraArgs"] ?: @"";
    if (dict[@"keyboardMode"]) [self.keyboardModePicker selectItemWithTitle:dict[@"keyboardMode"]];
    if (dict[@"mouseMode"]) [self.mouseModePicker selectItemWithTitle:dict[@"mouseMode"]];
    if (dict[@"gamepadMode"]) [self.gamepadModePicker selectItemWithTitle:dict[@"gamepadMode"]];
    if (dict[@"shortcutMod"]) [self.shortcutModPicker selectItemWithTitle:dict[@"shortcutMod"]];
    self.otgCheck.state = [dict[@"otg"] boolValue] ? NSControlStateValueOn : NSControlStateValueOff;
    self.preferTextCheck.state = [dict[@"preferText"] boolValue] ? NSControlStateValueOn : NSControlStateValueOff;
    self.rawKeyEventsCheck.state = [dict[@"rawKeyEvents"] boolValue] ? NSControlStateValueOn : NSControlStateValueOff;
    self.noKeyRepeatCheck.state = [dict[@"noKeyRepeat"] boolValue] ? NSControlStateValueOn : NSControlStateValueOff;
    self.legacyPasteCheck.state = [dict[@"legacyPaste"] boolValue] ? NSControlStateValueOn : NSControlStateValueOff;
    self.noClipboardSyncCheck.state = [dict[@"noClipboardSync"] boolValue] ? NSControlStateValueOn : NSControlStateValueOff;
    self.noMouseHoverCheck.state = [dict[@"noMouseHover"] boolValue] ? NSControlStateValueOn : NSControlStateValueOff;
    self.tcpipAddressField.stringValue = dict[@"tcpipAddress"] ?: @"";
}

- (void)resetPresetAction:(id)sender {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kDefaultsKeySettings];
    [self.profilePicker selectItemWithTitle:@"gaming"];
    for (NSButton *btn in self.featureButtons) {
        btn.state = NSControlStateValueOff;
    }
    self.windowTitleField.stringValue = @"";
    self.startAppField.stringValue = @"";
    self.timeLimitField.stringValue = @"";
    self.screenOffTimeoutField.stringValue = @"";
    [self.videoCodecPicker selectItemAtIndex:0];
    [self.maxSizePicker selectItemAtIndex:0];
    [self.renderDriverPicker selectItemAtIndex:0];
    self.bitrateField.stringValue = @"";
    self.fpsField.stringValue = @"";
    [self.orientationPicker selectItemAtIndex:0];
    self.videoBufferField.stringValue = @"";
    self.cropField.stringValue = @"";
    self.displayIdField.stringValue = @"";
    self.virtualDisplayCheck.state = NSControlStateValueOff;
    self.virtualDisplaySpecField.stringValue = @"";
    self.keepVdContentCheck.state = NSControlStateValueOff;
    [self.videoSourcePicker selectItemAtIndex:0];
    [self.cameraFacingPicker selectItemAtIndex:0];
    self.cameraIdField.stringValue = @"";
    self.cameraSizeField.stringValue = @"";
    self.cameraFpsField.stringValue = @"";
    self.cameraHighSpeedCheck.state = NSControlStateValueOff;
    [self.audioSourcePicker selectItemAtIndex:0];
    [self.audioCodecPicker selectItemAtIndex:0];
    self.audioBitrateField.stringValue = @"";
    self.audioBufferField.stringValue = @"";
    self.requireAudioCheck.state = NSControlStateValueOff;
    [self.recordFormatPicker selectItemAtIndex:0];
    self.noPlaybackCheck.state = NSControlStateValueOff;
    self.extraArgsField.stringValue = @"";
    [self.keyboardModePicker selectItemAtIndex:0];
    [self.mouseModePicker selectItemAtIndex:0];
    [self.gamepadModePicker selectItemAtIndex:0];
    [self.shortcutModPicker selectItemAtIndex:0];
    self.otgCheck.state = NSControlStateValueOff;
    self.preferTextCheck.state = NSControlStateValueOff;
    self.rawKeyEventsCheck.state = NSControlStateValueOff;
    self.noKeyRepeatCheck.state = NSControlStateValueOff;
    self.legacyPasteCheck.state = NSControlStateValueOff;
    self.noClipboardSyncCheck.state = NSControlStateValueOff;
    self.noMouseHoverCheck.state = NSControlStateValueOff;
    [self profileChanged:self.profilePicker];
    self.statusLabel.stringValue = @"Pengaturan dikembalikan ke default";
}

#pragma mark - Device Management & ADB Actions

- (void)refreshDevices:(id)sender {
    [self.devicePicker removeAllItems];
    [self.deviceSerials removeAllObjects];

    [self.devicePicker addItemWithTitle:@"Otomatis (Semua Perangkat)"];
    [self.deviceSerials addObject:@""];

    NSString *adb = [self adbPath];
    NSTask *task = [[NSTask alloc] init];
    task.executableURL = [NSURL fileURLWithPath:adb];
    task.arguments = [adb isEqualToString:@"/usr/bin/env"] ? @[@"adb", @"devices", @"-l"] : @[@"devices", @"-l"];
    NSPipe *pipe = [NSPipe pipe];
    task.standardOutput = pipe;
    task.standardError = pipe;

    NSError *err = nil;
    if ([task launchAndReturnError:&err]) {
        [task waitUntilExit];
        NSData *data = [pipe.fileHandleForReading readDataToEndOfFile];
        NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ?: @"";
        NSArray<NSString *> *lines = [output componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        for (NSString *line in lines) {
            NSString *trimmed = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (trimmed.length == 0 || [trimmed hasPrefix:@"List of devices"] || [trimmed hasPrefix:@"*"]) {
                continue;
            }
            NSArray<NSString *> *parts = [trimmed componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSMutableArray<NSString *> *tokens = [NSMutableArray array];
            for (NSString *p in parts) {
                if (p.length > 0) [tokens addObject:p];
            }
            if (tokens.count >= 2) {
                NSString *serial = tokens[0];
                NSString *state = tokens[1];
                NSString *model = @"";
                for (NSString *tok in tokens) {
                    if ([tok hasPrefix:@"model:"]) {
                        model = [tok substringFromIndex:6];
                        break;
                    }
                }
                NSString *label = model.length > 0
                    ? [NSString stringWithFormat:@"%@ (%@ - %@)", model, serial, state]
                    : [NSString stringWithFormat:@"%@ (%@)", serial, state];
                [self.devicePicker addItemWithTitle:label];
                [self.deviceSerials addObject:serial];
            }
        }
    }

    NSUInteger count = self.deviceSerials.count - 1;
    if (count > 0) {
        [self.devicePicker selectItemAtIndex:1];
        self.statusLabel.stringValue = [NSString stringWithFormat:@"%lu perangkat ADB terdeteksi", (unsigned long)count];
    } else {
        self.statusLabel.stringValue = @"Belum ada perangkat ADB terhubung";
    }
}

- (void)runHelperCommand:(NSArray<NSString *> *)args statusMessage:(NSString *)statusMsg switchToLogTab:(BOOL)showLog {
    NSString *launcher = [self launcherPath];
    if (![[NSFileManager defaultManager] isExecutableFileAtPath:launcher]) {
        [self showError:@"Tidak menemukan scrcpy-plus di folder aplikasi."];
        return;
    }
    if (showLog) {
        [self.tabView selectTabViewItemWithIdentifier:@"tools"];
    }
    NSMutableArray<NSString *> *fullArgs = [NSMutableArray array];
    NSString *serial = [self selectedSerial];
    if (serial.length > 0) {
        [fullArgs addObjectsFromArray:@[@"--serial", serial]];
    }
    [fullArgs addObjectsFromArray:args];

    self.statusLabel.stringValue = statusMsg;
    [self appendLog:[NSString stringWithFormat:@"\n$ ./scrcpy-plus %@\n", [fullArgs componentsJoinedByString:@" "]]];

    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        NSTask *task = [[NSTask alloc] init];
        task.executableURL = [NSURL fileURLWithPath:launcher];
        task.arguments = fullArgs;
        task.currentDirectoryURL = [NSURL fileURLWithPath:[self workspaceDirectoryPath]];
        NSPipe *pipe = [NSPipe pipe];
        task.standardOutput = pipe;
        task.standardError = pipe;

        NSError *error = nil;
        if (![task launchAndReturnError:&error]) {
            [self appendLog:[NSString stringWithFormat:@"Error: %@\n", error.localizedDescription]];
            return;
        }
        NSData *data = [pipe.fileHandleForReading readDataToEndOfFile];
        [task waitUntilExit];
        NSString *out = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ?: @"";
        [self appendLog:out];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.statusLabel.stringValue = task.terminationStatus == 0 ? @"Perintah selesai" : @"Perintah gagal (lihat tab Log Live)";
            [self refreshDevices:nil];
        });
    });
}

- (void)connectWirelessIP:(id)sender {
    NSString *ip = [self.tcpipAddressField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (ip.length == 0) {
        [self showError:@"Masukkan alamat IP:Port terlebih dahulu (contoh: 192.168.1.15:5555)."];
        return;
    }
    NSString *adb = [self adbPath];
    [self appendLog:[NSString stringWithFormat:@"\n$ adb connect %@\n", ip]];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        NSTask *task = [[NSTask alloc] init];
        task.executableURL = [NSURL fileURLWithPath:adb];
        task.arguments = [adb isEqualToString:@"/usr/bin/env"] ? @[@"adb", @"connect", ip] : @[@"connect", ip];
        NSPipe *pipe = [NSPipe pipe];
        task.standardOutput = pipe;
        task.standardError = pipe;
        if ([task launchAndReturnError:nil]) {
            NSData *data = [pipe.fileHandleForReading readDataToEndOfFile];
            [task waitUntilExit];
            NSString *out = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ?: @"";
            [self appendLog:out];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self refreshDevices:nil];
                self.statusLabel.stringValue = [out stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            });
        }
    });
}

- (void)bridgeUsbToWifi:(id)sender {
    NSString *adb = [self adbPath];
    NSString *serial = [self selectedSerial];
    [self appendLog:@"\nMengaktifkan mode ADB TCP/IP (port 5555) dari USB...\n"];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        NSMutableArray<NSString *> *baseArgs = [NSMutableArray array];
        if ([adb isEqualToString:@"/usr/bin/env"]) [baseArgs addObject:@"adb"];
        if (serial.length > 0) [baseArgs addObjectsFromArray:@[@"-s", serial]];

        // Detect IP
        NSTask *ipTask = [[NSTask alloc] init];
        ipTask.executableURL = [NSURL fileURLWithPath:adb];
        ipTask.arguments = [baseArgs arrayByAddingObjectsFromArray:@[@"shell", @"ip", @"route"]];
        NSPipe *ipPipe = [NSPipe pipe];
        ipTask.standardOutput = ipPipe;
        NSString *detectedIp = @"";
        if ([ipTask launchAndReturnError:nil]) {
            NSData *d = [ipPipe.fileHandleForReading readDataToEndOfFile];
            [ipTask waitUntilExit];
            NSString *routeOut = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding] ?: @"";
            NSArray<NSString *> *tokens = [routeOut componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            for (NSUInteger i = 0; i + 1 < tokens.count; i++) {
                if ([tokens[i] isEqualToString:@"src"]) {
                    detectedIp = tokens[i + 1];
                    break;
                }
            }
        }

        NSTask *tcpTask = [[NSTask alloc] init];
        tcpTask.executableURL = [NSURL fileURLWithPath:adb];
        tcpTask.arguments = [baseArgs arrayByAddingObjectsFromArray:@[@"tcpip", @"5555"]];
        if ([tcpTask launchAndReturnError:nil]) {
            [tcpTask waitUntilExit];
        }
        [NSThread sleepForTimeInterval:1.0];

        if (detectedIp.length > 0) {
            NSString *addr = [NSString stringWithFormat:@"%@:5555", detectedIp];
            NSTask *connTask = [[NSTask alloc] init];
            connTask.executableURL = [NSURL fileURLWithPath:adb];
            connTask.arguments = [adb isEqualToString:@"/usr/bin/env"] ? @[@"adb", @"connect", addr] : @[@"connect", addr];
            NSPipe *cPipe = [NSPipe pipe];
            connTask.standardOutput = cPipe;
            if ([connTask launchAndReturnError:nil]) {
                NSData *cd = [cPipe.fileHandleForReading readDataToEndOfFile];
                [connTask waitUntilExit];
                NSString *cOut = [[NSString alloc] initWithData:cd encoding:NSUTF8StringEncoding] ?: @"";
                [self appendLog:cOut];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.tcpipAddressField.stringValue = addr;
                [self refreshDevices:nil];
                self.statusLabel.stringValue = [NSString stringWithFormat:@"Terhubung ke Wi-Fi %@", addr];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.statusLabel.stringValue = @"Port 5555 diaktifkan, namun IP perangkat tidak terdeteksi otomatis";
            });
        }
    });
}

- (void)disconnectWireless:(id)sender {
    NSString *ip = [self.tcpipAddressField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSArray<NSString *> *args = ip.length > 0 ? @[@"--disconnect", ip] : @[@"--disconnect"];
    [self runHelperCommand:args statusMessage:@"Memutuskan koneksi Wi-Fi ADB..." switchToLogTab:NO];
}

- (void)pairWirelessDevice:(id)sender {
    NSString *addr = [self.pairAddressField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *code = [self.pairCodeField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (addr.length == 0 || code.length == 0) {
        [self showError:@"Masukkan IP:Port Pairing dan Kode Pairing 6 digit terlebih dahulu."];
        return;
    }
    [self runHelperCommand:@[@"--pair", addr, code] statusMessage:@"Melakukan pairing Wi-Fi..." switchToLogTab:YES];
}

- (void)sendTextAction:(id)sender {
    NSString *text = self.sendTextField.stringValue;
    if (text.length == 0) return;
    [self runHelperCommand:@[@"--send-text", text] statusMessage:@"Mengirim teks ke perangkat..." switchToLogTab:NO];
}

- (void)sendQuickKeyevent:(NSButton *)sender {
    NSString *key = sender.identifier;
    if (key.length == 0) return;
    [self runHelperCommand:@[@"--keyevent", key] statusMessage:[NSString stringWithFormat:@"Mengirim tombol %@...", sender.title] switchToLogTab:NO];
}

- (void)takeScreenshotAction:(id)sender {
    NSString *filename = [NSString stringWithFormat:@"scrcpy-screenshot-%ld.png", (long)[[NSDate date] timeIntervalSince1970]];
    NSString *desktopPath = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:filename];
    [self runHelperCommand:@[@"--screenshot", desktopPath] statusMessage:[NSString stringWithFormat:@"Menyimpan screenshot ke Desktop (%@)...", filename] switchToLogTab:NO];
}

- (void)installApkAction:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.allowedContentTypes = @[[UTType typeWithFilenameExtension:@"apk"]];
    panel.allowsMultipleSelection = NO;
    panel.message = @"Pilih file APK untuk di-install ke perangkat Android";
    if ([panel runModal] == NSModalResponseOK && panel.URL.path.length > 0) {
        [self runHelperCommand:@[@"--install-apk", panel.URL.path] statusMessage:@"Meng-install APK ke perangkat..." switchToLogTab:YES];
    }
}

- (void)pushFileAction:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.allowsMultipleSelection = NO;
    panel.canChooseDirectories = NO;
    panel.message = @"Pilih file untuk dikirim ke /sdcard/Download/ di perangkat Android";
    if ([panel runModal] == NSModalResponseOK && panel.URL.path.length > 0) {
        [self runHelperCommand:@[@"--push", panel.URL.path, @"/sdcard/Download/"] statusMessage:@"Mengirim file ke /sdcard/Download/..." switchToLogTab:YES];
    }
}

- (void)runDiagnosticTool:(NSButton *)sender {
    NSString *arg = sender.identifier;
    if (arg.length == 0) return;
    [self runHelperCommand:@[arg] statusMessage:[NSString stringWithFormat:@"Menjalankan %@...", sender.title] switchToLogTab:YES];
}

- (void)clearLogAction:(id)sender {
    self.logTextView.string = @"";
}

#pragma mark - Start & Stop scrcpy

- (NSMutableArray<NSString *> *)buildScrcpyArgumentsWithRecordingURL:(NSURL *)recordURL {
    NSMutableArray<NSString *> *arguments = [NSMutableArray array];

    NSString *serial = [self selectedSerial];
    if (serial.length > 0) {
        [arguments addObjectsFromArray:@[@"--serial", serial]];
    }

    NSString *profile = self.profilePicker.titleOfSelectedItem ?: @"default";
    [arguments addObjectsFromArray:@[@"--profile", profile]];

    // 16 General Feature Checkboxes
    NSArray<NSArray<NSString *> *> *featureFlags = @[
        @[@"--wireless"],
        @[@"--fullscreen"],
        @[@"--windowed"],
        @[@"--screen-off"],
        @[@"--power-off-on-close"],
        @[@"--show-touches"],
        @[@"--stay-awake"],
        @[@"--no-control"],
        @[@"--borderless"],
        @[@"--always-on-top"],
        @[@"--disable-screensaver"],
        @[@"--audio-dup"],
        @[@"--no-audio"],
        @[@"--no-video"],
        @[@"--print-fps"],
        @[] // Record handled separately via save panel
    ];

    for (NSUInteger i = 0; i < featureFlags.count; i++) {
        if ([self isFeatureEnabled:i]) {
            [arguments addObjectsFromArray:featureFlags[i]];
        }
    }

    // Window & Timers
    if (self.windowTitleField.stringValue.length > 0) {
        [arguments addObjectsFromArray:@[@"--title", self.windowTitleField.stringValue]];
    }
    if (self.startAppField.stringValue.length > 0) {
        [arguments addObjectsFromArray:@[@"--start-app", self.startAppField.stringValue]];
    }
    if (self.timeLimitField.stringValue.length > 0) {
        [arguments addObjectsFromArray:@[@"--time-limit", self.timeLimitField.stringValue]];
    }
    if (self.screenOffTimeoutField.stringValue.length > 0) {
        [arguments addObjectsFromArray:@[@"--screen-off-timeout", self.screenOffTimeoutField.stringValue]];
    }

    // Video & Display
    if (self.videoCodecPicker.indexOfSelectedItem > 0) {
        [arguments addObjectsFromArray:@[@"--video-codec", self.videoCodecPicker.titleOfSelectedItem]];
    }
    if (self.maxSizePicker.indexOfSelectedItem > 0) {
        [arguments addObjectsFromArray:@[@"--max-size", self.maxSizePicker.titleOfSelectedItem]];
    }
    if (self.renderDriverPicker.indexOfSelectedItem > 0) {
        [arguments addObjectsFromArray:@[@"--render-driver", self.renderDriverPicker.titleOfSelectedItem]];
    }
    if (self.bitrateField.stringValue.length > 0) {
        [arguments addObjectsFromArray:@[@"--bitrate", self.bitrateField.stringValue]];
    }
    if (self.fpsField.stringValue.length > 0) {
        [arguments addObjectsFromArray:@[@"--fps", self.fpsField.stringValue]];
    }
    if (self.orientationPicker.indexOfSelectedItem > 0) {
        [arguments addObjectsFromArray:@[@"--orientation", self.orientationPicker.titleOfSelectedItem]];
    }
    if (self.videoBufferField.stringValue.length > 0) {
        [arguments addObjectsFromArray:@[@"--video-buffer", self.videoBufferField.stringValue]];
    }
    if (self.cropField.stringValue.length > 0) {
        [arguments addObjectsFromArray:@[@"--crop", self.cropField.stringValue]];
    }
    if (self.displayIdField.stringValue.length > 0) {
        [arguments addObjectsFromArray:@[@"--display-id", self.displayIdField.stringValue]];
    }

    // Virtual Display
    if (self.virtualDisplayCheck.state == NSControlStateValueOn) {
        if (self.virtualDisplaySpecField.stringValue.length > 0) {
            [arguments addObject:[NSString stringWithFormat:@"--new-display=%@", self.virtualDisplaySpecField.stringValue]];
        } else {
            [arguments addObject:@"--new-display"];
        }
    }
    if (self.keepVdContentCheck.state == NSControlStateValueOn) {
        [arguments addObject:@"--no-vd-destroy-content"];
    }

    // Camera
    if (self.videoSourcePicker.indexOfSelectedItem > 0) {
        [arguments addObjectsFromArray:@[@"--video-source", self.videoSourcePicker.titleOfSelectedItem]];
    }
    if (self.cameraFacingPicker.indexOfSelectedItem > 0) {
        [arguments addObjectsFromArray:@[@"--camera-facing", self.cameraFacingPicker.titleOfSelectedItem]];
    }
    if (self.cameraIdField.stringValue.length > 0) {
        [arguments addObjectsFromArray:@[@"--camera-id", self.cameraIdField.stringValue]];
    }
    if (self.cameraSizeField.stringValue.length > 0) {
        [arguments addObjectsFromArray:@[@"--camera-size", self.cameraSizeField.stringValue]];
    }
    if (self.cameraFpsField.stringValue.length > 0) {
        [arguments addObjectsFromArray:@[@"--camera-fps", self.cameraFpsField.stringValue]];
    }
    if (self.cameraHighSpeedCheck.state == NSControlStateValueOn) {
        [arguments addObject:@"--camera-high-speed"];
    }

    // Audio
    if (self.audioSourcePicker.indexOfSelectedItem > 0) {
        [arguments addObjectsFromArray:@[@"--audio-source", self.audioSourcePicker.titleOfSelectedItem]];
    }
    if (self.audioCodecPicker.indexOfSelectedItem > 0) {
        [arguments addObjectsFromArray:@[@"--audio-codec", self.audioCodecPicker.titleOfSelectedItem]];
    }
    if (self.audioBitrateField.stringValue.length > 0) {
        [arguments addObjectsFromArray:@[@"--audio-bitrate", self.audioBitrateField.stringValue]];
    }
    if (self.audioBufferField.stringValue.length > 0) {
        [arguments addObjectsFromArray:@[@"--audio-buffer", self.audioBufferField.stringValue]];
    }
    if (self.requireAudioCheck.state == NSControlStateValueOn) {
        [arguments addObject:@"--require-audio"];
    }

    // Recording
    if (recordURL != nil) {
        [arguments addObjectsFromArray:@[@"--record", recordURL.path]];
    }
    if (self.recordFormatPicker.indexOfSelectedItem > 0) {
        [arguments addObjectsFromArray:@[@"--record-format", self.recordFormatPicker.titleOfSelectedItem]];
    }
    if (self.noPlaybackCheck.state == NSControlStateValueOn) {
        [arguments addObject:@"--no-playback"];
    }

    // Input & Peripherals
    if (self.keyboardModePicker.indexOfSelectedItem > 0) {
        [arguments addObjectsFromArray:@[@"--keyboard", self.keyboardModePicker.titleOfSelectedItem]];
    }
    if (self.mouseModePicker.indexOfSelectedItem > 0) {
        [arguments addObjectsFromArray:@[@"--mouse", self.mouseModePicker.titleOfSelectedItem]];
    }
    if (self.gamepadModePicker.indexOfSelectedItem > 0) {
        [arguments addObjectsFromArray:@[@"--gamepad", self.gamepadModePicker.titleOfSelectedItem]];
    }
    if (self.shortcutModPicker.indexOfSelectedItem > 0) {
        [arguments addObjectsFromArray:@[@"--shortcut-mod", self.shortcutModPicker.titleOfSelectedItem]];
    }
    if (self.otgCheck.state == NSControlStateValueOn) {
        [arguments addObject:@"--otg"];
    }
    if (self.preferTextCheck.state == NSControlStateValueOn) {
        [arguments addObject:@"--prefer-text"];
    }
    if (self.rawKeyEventsCheck.state == NSControlStateValueOn) {
        [arguments addObject:@"--raw-key-events"];
    }
    if (self.noKeyRepeatCheck.state == NSControlStateValueOn) {
        [arguments addObject:@"--no-key-repeat"];
    }
    if (self.legacyPasteCheck.state == NSControlStateValueOn) {
        [arguments addObject:@"--legacy-paste"];
    }
    if (self.noClipboardSyncCheck.state == NSControlStateValueOn) {
        [arguments addObject:@"--no-clipboard-autosync"];
    }
    if (self.noMouseHoverCheck.state == NSControlStateValueOn) {
        [arguments addObject:@"--no-mouse-hover"];
    }

    // Extra Custom Arguments
    NSString *extra = [self.extraArgsField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (extra.length > 0) {
        [arguments addObject:@"--"];
        NSArray<NSString *> *parts = [extra componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        for (NSString *part in parts) {
            if (part.length > 0) {
                [arguments addObject:part];
            }
        }
    }

    return arguments;
}

- (void)startScrcpy:(id)sender {
    if (self.scrcpyTask.isRunning) {
        self.statusLabel.stringValue = @"scrcpy sedang berjalan";
        return;
    }

    BOOL shouldRecord = [self isFeatureEnabled:15] || [self.profilePicker.titleOfSelectedItem isEqualToString:@"recording"];
    NSURL *recordURL = nil;
    if (shouldRecord) {
        NSString *ext = self.recordFormatPicker.indexOfSelectedItem > 0 ? self.recordFormatPicker.titleOfSelectedItem : @"mp4";
        NSSavePanel *panel = [NSSavePanel savePanel];
        panel.nameFieldStringValue = [NSString stringWithFormat:@"scrcpy-recording.%@", ext];
        UTType *utType = [UTType typeWithFilenameExtension:ext];
        if (utType) {
            panel.allowedContentTypes = @[utType];
        }
        if ([panel runModal] != NSModalResponseOK || panel.URL == nil) {
            self.statusLabel.stringValue = @"Perekaman dibatalkan";
            return;
        }
        recordURL = panel.URL;
    }

    NSString *launcherPath = [self launcherPath];
    if (![[NSFileManager defaultManager] isExecutableFileAtPath:launcherPath]) {
        [self showError:@"Tidak menemukan scrcpy-plus di folder aplikasi."];
        return;
    }

    NSMutableArray<NSString *> *arguments = [self buildScrcpyArgumentsWithRecordingURL:recordURL];

    // Also log to ~/Library/Logs/scrcpy-plus/gui-launch.log
    NSURL *logDirectory = [[[NSFileManager defaultManager] homeDirectoryForCurrentUser]
                           URLByAppendingPathComponent:@"Library/Logs/scrcpy-plus" isDirectory:YES];
    [[NSFileManager defaultManager] createDirectoryAtURL:logDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    NSURL *logURL = [logDirectory URLByAppendingPathComponent:@"gui-launch.log"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:logURL.path]) {
        [[NSFileManager defaultManager] createFileAtPath:logURL.path contents:nil attributes:nil];
    }
    NSFileHandle *fileLogHandle = [NSFileHandle fileHandleForWritingAtPath:logURL.path];
    [fileLogHandle seekToEndOfFile];

    NSTask *task = [[NSTask alloc] init];
    task.executableURL = [NSURL fileURLWithPath:launcherPath];
    task.arguments = arguments;
    task.currentDirectoryURL = [NSURL fileURLWithPath:[self workspaceDirectoryPath]];

    NSPipe *pipe = [NSPipe pipe];
    self.outputPipe = pipe;
    task.standardOutput = pipe;
    task.standardError = pipe;

    [self appendLog:[NSString stringWithFormat:@"\n=== Menjalankan: ./scrcpy-plus %@ ===\n", [arguments componentsJoinedByString:@" "]]];

    __weak typeof(self) weakSelf = self;
    pipe.fileHandleForReading.readabilityHandler = ^(NSFileHandle *handle) {
        NSData *data = [handle availableData];
        if (data.length > 0) {
            [fileLogHandle writeData:data];
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (str) {
                [weakSelf appendLog:str];
            }
        }
    };

    task.terminationHandler = ^(NSTask *finishedTask) {
        weakSelf.outputPipe.fileHandleForReading.readabilityHandler = nil;
        [fileLogHandle closeFile];
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.startButton.enabled = YES;
            weakSelf.stopButton.enabled = NO;
            weakSelf.statusLabel.stringValue = finishedTask.terminationStatus == 0
                ? @"Sesi scrcpy selesai"
                : [NSString stringWithFormat:@"scrcpy berhenti (kode %d). Cek tab Alat ADB & Log Live", finishedTask.terminationStatus];
            weakSelf.scrcpyTask = nil;
        });
    };

    NSError *launchError = nil;
    if (![task launchAndReturnError:&launchError]) {
        pipe.fileHandleForReading.readabilityHandler = nil;
        [fileLogHandle closeFile];
        [self showError:launchError.localizedDescription];
        return;
    }

    self.scrcpyTask = task;
    self.startButton.enabled = NO;
    self.stopButton.enabled = YES;
    self.statusLabel.stringValue = @"scrcpy sedang berjalan...";
}

- (void)stopScrcpy:(id)sender {
    if (!self.scrcpyTask.isRunning) {
        self.statusLabel.stringValue = @"Tidak ada sesi yang berjalan";
        return;
    }
    [self.scrcpyTask terminate];
    self.statusLabel.stringValue = @"Menghentikan scrcpy…";
}

- (void)showError:(NSString *)message {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"scrcpy-plus";
    alert.informativeText = message;
    alert.alertStyle = NSAlertStyleCritical;
    [alert addButtonWithTitle:@"OK"];
    [alert runModal];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    if (self.scrcpyTask.isRunning) {
        [self.scrcpyTask terminate];
    }
    return YES;
}

@end

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        NSApplication *application = [NSApplication sharedApplication];
        ScrcpyPlusAppDelegate *delegate = [[ScrcpyPlusAppDelegate alloc] init];
        application.delegate = delegate;
        [application run];
        return 0;
    }
}
