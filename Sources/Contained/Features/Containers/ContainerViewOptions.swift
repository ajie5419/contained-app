import Foundation

/// How the Containers page buckets its cards. Driven by the page filter control.
enum ContainerGrouping: String, CaseIterable, Identifiable, Codable, Sendable {
    case network, volume, image, flat

    var id: String { rawValue }

    /// Short noun shown in the toolbar subtitle and the menu ("by Network").
    var title: String {
        switch self {
        case .network: return L10n.text("Network")
        case .volume:  return L10n.text("Volume")
        case .image:   return L10n.text("Image")
        case .flat:    return L10n.text("Flat")
        }
    }

    var symbol: String {
        switch self {
        case .network: return "network"
        case .volume:  return "externaldrive"
        case .image:   return "shippingbox"
        case .flat:    return "square.grid.2x2"
        }
    }
}

/// How containers are ordered within each group (and how the groups themselves sort, where relevant).
enum ContainerSort: String, CaseIterable, Identifiable, Codable, Sendable {
    case name, status, image

    var id: String { rawValue }

    var title: String {
        switch self {
        case .name:   return L10n.text("Name")
        case .status: return L10n.text("Status")
        case .image:  return L10n.text("Image")
        }
    }

    var symbol: String {
        switch self {
        case .name:   return "textformat"
        case .status: return "bolt"
        case .image:  return "shippingbox"
        }
    }
}
