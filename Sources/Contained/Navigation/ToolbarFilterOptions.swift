enum ImageGrouping: String, CaseIterable, Identifiable {
    case none, registry, status
    var id: String { rawValue }
    var title: String {
        switch self {
        case .none: return L10n.text("None")
        case .registry: return L10n.text("Registry")
        case .status: return L10n.text("Status")
        }
    }
    var symbol: String {
        switch self {
        case .none: return "square.stack.3d.up"
        case .registry: return "globe"
        case .status: return "arrow.triangle.2.circlepath"
        }
    }
}

enum ImageSort: String, CaseIterable, Identifiable {
    case status, name, tags
    var id: String { rawValue }
    var title: String {
        switch self {
        case .status: return L10n.text("Status")
        case .name: return L10n.text("Name")
        case .tags: return L10n.text("Tags")
        }
    }
    var symbol: String {
        switch self {
        case .status: return "bolt"
        case .name: return "textformat"
        case .tags: return "tag"
        }
    }
}

enum ImageFilter: String, CaseIterable, Identifiable {
    case all, updates, errors
    var id: String { rawValue }
    var title: String {
        switch self {
        case .all: return L10n.text("All images")
        case .updates: return L10n.text("Updates only")
        case .errors: return L10n.text("Errors only")
        }
    }
    var symbol: String {
        switch self {
        case .all: return "tray.full"
        case .updates: return "arrow.down.circle"
        case .errors: return "exclamationmark.triangle"
        }
    }
}

enum TemplateGrouping: String, CaseIterable, Identifiable {
    case none, image
    var id: String { rawValue }
    var title: String { self == .none ? L10n.text("None") : L10n.text("Image") }
    var symbol: String { self == .none ? "bookmark" : "shippingbox" }
}

enum TemplateSort: String, CaseIterable, Identifiable {
    case newest, name, image
    var id: String { rawValue }
    var title: String {
        switch self {
        case .newest: return L10n.text("Newest")
        case .name: return L10n.text("Name")
        case .image: return L10n.text("Image")
        }
    }
    var symbol: String {
        switch self {
        case .newest: return "clock"
        case .name: return "textformat"
        case .image: return "shippingbox"
        }
    }
}

enum NetworkGrouping: String, CaseIterable, Identifiable {
    case none, kind, mode
    var id: String { rawValue }
    var title: String {
        switch self {
        case .none: return L10n.text("None")
        case .kind: return L10n.text("Kind")
        case .mode: return L10n.text("Mode")
        }
    }
    var symbol: String {
        switch self {
        case .none: return "network"
        case .kind: return "square.stack"
        case .mode: return "switch.2"
        }
    }
}

enum NetworkSort: String, CaseIterable, Identifiable {
    case name, mode, plugin
    var id: String { rawValue }
    var title: String {
        switch self {
        case .name: return L10n.text("Name")
        case .mode: return L10n.text("Mode")
        case .plugin: return L10n.text("Plugin")
        }
    }
    var symbol: String {
        switch self {
        case .name: return "textformat"
        case .mode: return "switch.2"
        case .plugin: return "puzzlepiece"
        }
    }
}

enum NetworkFilter: String, CaseIterable, Identifiable {
    case all, custom, builtin
    var id: String { rawValue }
    var title: String {
        switch self {
        case .all: return L10n.text("All networks")
        case .custom: return L10n.text("Custom only")
        case .builtin: return L10n.text("Built-in only")
        }
    }
    var symbol: String {
        switch self {
        case .all: return "tray.full"
        case .custom: return "network"
        case .builtin: return "network.badge.shield.half.filled"
        }
    }
}
