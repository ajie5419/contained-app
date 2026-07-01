import Foundation

enum L10n {
    private static let catalog = StringCatalog.load()

    static func text(_ key: String) -> String {
        text(key, preferredLanguages: Locale.preferredLanguages)
    }

    static func text(_ key: String, preferredLanguages: [String]) -> String {
        catalog.localizedValue(for: key, preferredLanguages: preferredLanguages) ?? key
    }

    static func text(_ key: String, _ arguments: CVarArg...) -> String {
        String(format: text(key), locale: Locale.current, arguments: arguments)
    }

    static func text(_ key: String, preferredLanguages: [String], _ arguments: CVarArg...) -> String {
        String(format: text(key, preferredLanguages: preferredLanguages), locale: Locale.current, arguments: arguments)
    }
}

private struct StringCatalog {
    private let strings: [String: [String: String]]

    static func load() -> StringCatalog {
        guard let url = Bundle.module.url(forResource: "Localizable", withExtension: "xcstrings"),
              let data = try? Data(contentsOf: url),
              let catalog = try? JSONDecoder().decode(StringCatalogFile.self, from: data) else {
            return StringCatalog(strings: [:])
        }

        var strings: [String: [String: String]] = [:]
        for (key, entry) in catalog.strings {
            let localizations = entry.localizations?.compactMapValues { $0.stringUnit?.value } ?? [:]
            if !localizations.isEmpty { strings[key] = localizations }
        }
        return StringCatalog(strings: strings)
    }

    func localizedValue(for key: String, preferredLanguages: [String]) -> String? {
        guard let localizations = strings[key] else { return nil }
        for language in preferredLanguages {
            if let exact = localizations[language] { return exact }
            let canonical = Locale.identifier(.bcp47, from: language).replacingOccurrences(of: "_", with: "-")
            if let exact = localizations[canonical] { return exact }
            if let match = bestPrefixMatch(for: canonical, in: localizations) { return match }
        }
        return nil
    }

    private func bestPrefixMatch(for language: String, in localizations: [String: String]) -> String? {
        let lowercased = language.lowercased()
        if lowercased.hasPrefix("zh-hans") || lowercased == "zh-cn" || lowercased == "zh-sg" {
            return localizations["zh-Hans"]
        }
        if lowercased.hasPrefix("zh-hant") || lowercased == "zh-tw" || lowercased == "zh-hk" || lowercased == "zh-mo" {
            return localizations["zh-Hant"] ?? localizations["zh-Hans"]
        }
        if lowercased == "zh" || lowercased.hasPrefix("zh-") {
            return localizations["zh-Hans"]
        }

        let prefix = lowercased.split(separator: "-").first.map(String.init)
        guard let prefix else { return nil }
        return localizations.first { $0.key.lowercased() == prefix || $0.key.lowercased().hasPrefix("\(prefix)-") }?.value
    }
}

private struct StringCatalogFile: Decodable {
    let strings: [String: StringCatalogEntry]
}

private struct StringCatalogEntry: Decodable {
    let localizations: [String: StringCatalogLocalization]?
}

private struct StringCatalogLocalization: Decodable {
    let stringUnit: StringCatalogStringUnit?
}

private struct StringCatalogStringUnit: Decodable {
    let value: String
}
