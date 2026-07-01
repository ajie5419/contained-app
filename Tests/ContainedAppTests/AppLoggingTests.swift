import Foundation
import Testing
@testable import Contained

@Suite("App logging settings")
@MainActor
struct AppLoggingTests {
    @Test func defaultLoggingSettingsAreUsefulButNotNoisy() {
        let defaults = suiteDefaults()
        let settings = SettingsStore(defaults: defaults)

        #expect(settings.loggingLevel == .important)
        #expect(settings.enabledLogDestinations == [.activity])
        #expect(settings.enabledLogCategories == Set(AppLogCategory.allCases))
        #expect(settings.loggingLevel.includes(.info))
        #expect(settings.loggingLevel.includes(.warning))
        #expect(settings.loggingLevel.includes(.error))
        #expect(!settings.loggingLevel.includes(.debug))
    }

    @Test func loggingSettingsPersistRoundTrip() {
        let defaults = suiteDefaults()
        var settings: SettingsStore? = SettingsStore(defaults: defaults)
        settings?.loggingLevel = .verbose
        settings?.enabledLogDestinations = [.activity, .console]
        settings?.enabledLogCategories = [.compose, .image]
        settings = nil

        let reloaded = SettingsStore(defaults: defaults)
        #expect(reloaded.loggingLevel == .verbose)
        #expect(reloaded.enabledLogDestinations == [.activity, .console])
        #expect(reloaded.enabledLogCategories == [.compose, .image])
        #expect(reloaded.loggingLevel.includes(.debug))
    }

    @Test func errorOnlyLoggingFiltersLowerSeverity() {
        #expect(AppLogLevel.errors.includes(.error))
        #expect(!AppLogLevel.errors.includes(.warning))
        #expect(!AppLogLevel.errors.includes(.info))
        #expect(!AppLogLevel.errors.includes(.debug))
    }

    @Test func simplifiedChineseLocalizationsLoadFromModuleBundle() {
        #expect(L10n.text("Settings", preferredLanguages: ["en"]) == "Settings")
        #expect(L10n.text("Settings", preferredLanguages: ["zh-Hans"]) == "设置")
        #expect(L10n.text("Containers", preferredLanguages: ["zh-CN"]) == "容器")
        #expect(L10n.text("Missing Key", preferredLanguages: ["zh-Hans"]) == "Missing Key")
        #expect(catalogTranslation("Settings") == "设置")
        #expect(catalogTranslation("Containers") == "容器")
    }

    private func suiteDefaults() -> UserDefaults {
        let name = "ContainedTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    private func catalogTranslation(_ key: String) -> String? {
        guard let url = Bundle.module.url(forResource: "Localizable", withExtension: "xcstrings"),
              let data = try? Data(contentsOf: url),
              let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let strings = root["strings"] as? [String: Any],
              let entry = strings[key] as? [String: Any],
              let localizations = entry["localizations"] as? [String: Any],
              let zhHans = localizations["zh-Hans"] as? [String: Any],
              let stringUnit = zhHans["stringUnit"] as? [String: Any] else {
            return nil
        }
        return stringUnit["value"] as? String
    }
}
