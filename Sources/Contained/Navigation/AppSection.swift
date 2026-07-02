import SwiftUI

enum AppSection: String, CaseIterable, Identifiable, Hashable {
    case containers
    case images
    case build
    case volumes
    case networks
    case system
    case registries
    case templates
    case activity
    case settings

    static let allCases: [AppSection] = [
        .containers,
        .images,
        .build,
        .volumes,
        .networks,
        .system,
        .templates,
        .activity,
        .settings,
    ]

    static func navigableSections(panelNavigationEnabled: Bool) -> [AppSection] {
        allCases.filter { section in
            section.isNavigable(panelNavigationEnabled: panelNavigationEnabled)
        }
    }

    func isNavigable(panelNavigationEnabled: Bool) -> Bool {
        guard panelNavigationEnabled else { return true }
        switch self {
        case .build, .system, .activity, .settings:
            return false
        default:
            return true
        }
    }

    var id: String { rawValue }

    var title: String {
        switch self {
        case .containers: return L10n.text("Containers")
        case .images: return L10n.text("Images")
        case .build: return L10n.text("Build")
        case .volumes: return L10n.text("Volumes")
        case .networks: return L10n.text("Networks")
        case .system: return L10n.text("System")
        case .registries: return L10n.text("Registries")
        case .templates: return L10n.text("Templates")
        case .activity: return L10n.text("Activity")
        case .settings: return L10n.text("Settings")
        }
    }

    var symbol: String {
        switch self {
        case .containers: return "shippingbox"
        case .images: return "square.stack.3d.up"
        case .build: return "hammer"
        case .volumes: return "externaldrive"
        case .networks: return "network"
        case .system: return "gearshape.2"
        case .registries: return "key"
        case .templates: return "bookmark"
        case .activity: return "bell"
        case .settings: return "gearshape"
        }
    }

    var group: AppSectionGroup {
        switch self {
        case .containers, .images, .build, .templates:
            return .workloads
        case .volumes, .networks, .registries:
            return .infra
        case .system, .activity, .settings:
            return .system
        }
    }
}

enum AppSectionGroup: String, CaseIterable, Identifiable {
    case workloads = "Workloads"
    case infra = "Infra"
    case system = "System"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .workloads: return L10n.text("Workloads")
        case .infra: return L10n.text("Infra")
        case .system: return L10n.text("System")
        }
    }
}
