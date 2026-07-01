import SwiftUI
import AppKit
import ContainedCore

/// The menu shown by the menu-bar extra: a compact command surface with service status, running
/// containers, live resource counts, and the same creation / navigation affordances as the app menu.
struct MenuBarContent: View {
    @Environment(AppModel.self) private var app
    @Environment(UIState.self) private var ui

    private var store: ContainersStore { app.containers }
    private var stopped: [ContainerSnapshot] { store.snapshots.filter { $0.state != .running } }
    private var unreadActivityCount: Int { app.historyStore.unreadEventCount() }

    private var cliLabel: String {
        switch app.bootstrap {
        case .ready:
            return app.cliVersion.map { L10n.text("CLI v%@", $0) } ?? L10n.text("CLI ready")
        case .checking:
            return L10n.text("Checking CLI")
        case .cliMissing:
            return L10n.text("CLI missing")
        case .unsupported(let version):
            return L10n.text("CLI v%@ unsupported", version)
        case .serviceStopped:
            return L10n.text("Service stopped")
        }
    }

    private var localizedServiceLabel: String {
        L10n.text(app.serviceLabel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            Divider()

            infoGrid

            Divider()

            actionStrip

            Divider()

            Menu(L10n.text("Service")) {
                statusItem
                Divider()
                if app.serviceHealthy {
                    Button(L10n.text("Stop Service")) { Task { await app.stopService() } }
                } else {
                    Button(L10n.text("Start Service")) { Task { await app.startService() } }
                }
                Button(L10n.text("Restart Service")) { Task { await app.restartService() } }
            }

            Menu(L10n.text("Containers")) {
                Menu(L10n.text("Running Containers")) {
                    if store.running.isEmpty {
                        disabledPlaceholder(L10n.text("No running containers"))
                    } else {
                        ForEach(store.running) { snapshot in
                            Button(containerName(for: snapshot)) {
                                Task { await store.stop(snapshot.id) }
                            }
                        }
                    }
                }

                Menu(L10n.text("Stopped Containers")) {
                    if stopped.isEmpty {
                        disabledPlaceholder(L10n.text("No stopped containers"))
                    } else {
                        ForEach(stopped) { snapshot in
                            Button(containerName(for: snapshot)) {
                                Task { await store.start(snapshot.id) }
                            }
                        }
                    }
                }
            }

            Menu(L10n.text("Create")) {
                Button(L10n.text("Run Container…")) { activate(); route(.runContainer) }
                Button(L10n.text("Pull Image…")) { activate(); route(.pullImage) }
                    .disabled(!app.settings.hubSearchEnabled)
                Button(L10n.text("Build Image…")) { activate(); route(.build) }
                    .disabled(!app.settings.imageBuildEnabled)
                Divider()
                Button(L10n.text("New Volume…")) { activate(); route(.createVolume) }
                Button(L10n.text("New Network…")) { activate(); route(.createNetwork) }
                Button(L10n.text("Import Compose…")) { activate(); ComposeImport.pickAndImport(app: app, ui: ui) }
                    .disabled(!app.settings.composeImportEnabled)
            }

            Menu(L10n.text("Navigate")) {
                Button(L10n.text("Containers")) { activate(); navigate(to: .containers) }
                Button(L10n.text("Images")) { activate(); openSectionOrMorph(.images, morph: .updates) }
                Button(L10n.text("Templates")) { activate(); openSectionOrMorph(.templates, morph: .templates) }
                Button(L10n.text("System")) { activate(); openSectionOrMorph(.system, morph: .system) }
                Button(L10n.text("Activity")) { activate(); openSectionOrMorph(.activity, morph: .activity) }
            }

            Menu(L10n.text("Shortcuts")) {
                if app.settings.keyboardShortcutsEnabled {
                    Button(L10n.text(ui.sidebarVisible ? "Hide Sidebar" : "Show Sidebar")) { activate(); ui.setSidebarVisible(!ui.sidebarVisible) }
                        .keyboardShortcut("s", modifiers: .command)
                        .disabled(!app.settings.sidebarNavigationEnabled)
                    Button(L10n.text("Search This Page")) { activate(); ui.focusSearch() }
                        .keyboardShortcut("f", modifiers: .command)
                    Button(L10n.text("Settings")) { activate(); openSettings(to: .appearance) }
                        .keyboardShortcut(";", modifiers: .command)
                    Button(L10n.text("Run Container")) { activate(); route(.runContainer) }
                        .keyboardShortcut("n", modifiers: .command)
                    Button(L10n.text("Run Image Check")) { Task { await app.runImageUpdateSweepNow() } }
                        .keyboardShortcut("u", modifiers: .command)
                    Button(L10n.text("Activity")) { activate(); route(.activityHistory) }
                        .keyboardShortcut("i", modifiers: .command)
                } else {
                    disabledPlaceholder(L10n.text("Enable keyboard shortcuts in Settings → Experimental"))
                }
            }

            Menu(L10n.text("Settings")) {
                Button(L10n.text("Open Contained")) { activate() }
                Divider()
                ForEach(SettingsContent.SettingsPage.allCases) { page in
                    Button(page.title) { activate(); openSettings(to: page) }
                }
            }

            Menu(L10n.text("Help")) {
                Button(L10n.text("Check for Updates…")) {
                    activate()
                    app.updater.checkForUpdates()
                }
                Button(L10n.text("About Contained")) { activate(); openSettings(to: .about) }
                Button(L10n.text("Reveal CLI Binary in Finder")) { activate(); revealCLIBinary() }
                Divider()
                Button(L10n.text("Release Notes")) { activate(); NSWorkspace.shared.open(Links.releasesURL) }
                Button(L10n.text("Troubleshooting")) { activate(); NSWorkspace.shared.open(Links.troubleshootingURL) }
                Button(L10n.text("Keyboard Shortcuts")) { activate(); NSWorkspace.shared.open(Links.shortcutsURL) }
            }

            Divider()

            footerRow
        }
        .padding(14)
        .frame(width: 340)
    }

    @ViewBuilder
    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Label("Contained", systemImage: app.serviceHealthy ? "shippingbox.fill" : "shippingbox")
                    .font(.headline)
                Spacer(minLength: 0)
                Text("\(store.running.count)")
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 10) {
                Label(localizedServiceLabel, systemImage: app.serviceHealthy ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .foregroundStyle(app.serviceHealthy ? .green : .secondary)
                Text(app.settings.updateChannel.displayName)
                    .foregroundStyle(.secondary)
                Spacer(minLength: 0)
                if unreadActivityCount > 0 {
                    Label(unreadCountText, systemImage: "bell.badge")
                        .foregroundStyle(.secondary)
                }
            }
            .font(.caption)
        }
    }

    @ViewBuilder
    private var infoGrid: some View {
        VStack(alignment: .leading, spacing: 8) {
            infoRow(L10n.text("Containers"), value: containersSummary)
            infoRow(L10n.text("Resources"), value: resourcesSummary)
            infoRow(L10n.text("Bootstrap"), value: cliLabel)
            infoRow(L10n.text("Activity"), value: unreadActivityCount > 0 ? unreadCountText : L10n.text("All caught up"))
        }
        .font(.caption)
    }

    private var actionStrip: some View {
        HStack(spacing: 8) {
            miniAction(L10n.text("Open"), systemImage: "app")
            miniAction(L10n.text("Run"), systemImage: "plus") { route(.runContainer) }
            miniAction(L10n.text("Activity"), systemImage: unreadActivityCount > 0 ? "bell.badge" : "bell") { route(.activityHistory) }
            miniAction(L10n.text("Updates"), systemImage: "arrow.triangle.2.circlepath") { app.updater.checkForUpdates() }
        }
    }

    private var footerRow: some View {
        HStack(spacing: 8) {
            Button(L10n.text("Open Contained")) { activate() }
            Spacer(minLength: 0)
            Button(L10n.text("Quit")) { NSApplication.shared.terminate(nil) }
        }
        .buttonStyle(.borderless)
    }

    private var containersSummary: String {
        [countText(store.running.count, singular: "%d running", plural: "%d running"),
         countText(stopped.count, singular: "%d stopped", plural: "%d stopped")]
            .joined(separator: " · ")
    }

    private var resourcesSummary: String {
        [countText(app.images.count, singular: "%d image", plural: "%d images"),
         countText(app.volumes.count, singular: "%d volume", plural: "%d volumes"),
         countText(app.networks.count, singular: "%d network", plural: "%d networks")]
            .joined(separator: " · ")
    }

    private var unreadCountText: String {
        countText(unreadActivityCount, singular: "%d unread", plural: "%d unread")
    }

    private func countText(_ count: Int, singular: String, plural: String) -> String {
        L10n.text(count == 1 ? singular : plural, count)
    }

    @ViewBuilder
    private func miniAction(_ title: String,
                            systemImage: String,
                            action: @escaping () -> Void = {}) -> some View {
        Button(action: {
            activate()
            action()
        }) {
            Label(title, systemImage: systemImage)
        }
        .buttonStyle(.borderless)
    }

    @ViewBuilder
    private func infoRow(_ title: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(title)
                .foregroundStyle(.secondary)
                .frame(width: 78, alignment: .leading)
            Text(value)
                .foregroundStyle(.primary)
            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private func disabledPlaceholder(_ text: String) -> some View {
        Button(text) { }
            .disabled(true)
    }

    @ViewBuilder
    private var statusItem: some View {
        Label(localizedServiceLabel,
              systemImage: app.serviceHealthy ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
            .foregroundStyle(app.serviceHealthy ? .green : .secondary)
    }

    /// Bring the main window to the front.
    private func activate() {
        NSApplication.shared.activate(ignoringOtherApps: true)
        for window in NSApplication.shared.windows where window.canBecomeMain {
            window.makeKeyAndOrderFront(nil)
            break
        }
    }

    private func containerName(for snapshot: ContainerSnapshot) -> String {
        app.containerStyle(for: snapshot).displayName(fallback: snapshot.id)
    }

    private func navigate(to section: AppSection) {
        ui.navigate(to: section)
    }

    private func route(_ action: PendingAction) {
        ui.dispatch(action)
    }

    private func openSectionOrMorph(_ section: AppSection, morph: UIState.ToolbarMorph) {
        if app.settings.usesPanelNavigation {
            ui.toggleMorph(morph)
        } else {
            ui.navigate(to: section)
        }
    }

    private func openSettings(to page: SettingsContent.SettingsPage) {
        ui.settingsPage = page
        if app.settings.usesPanelNavigation {
            ui.openSettings(to: page)
        } else {
            ui.navigate(to: .settings)
        }
    }

    /// Reveal the resolved `container` binary in Finder (honoring the CLI-path override).
    private func revealCLIBinary() {
        guard let url = CLILocator.locate(override: app.settings.cliPathOverride) else { return }
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
}
