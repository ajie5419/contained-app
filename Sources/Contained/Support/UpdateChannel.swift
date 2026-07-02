import Foundation

/// The Sparkle update channel the user opts into. Each channel maps to a branch-hosted appcast feed
/// at the matching git branch's repo root (raw.githubusercontent.com). Stable and beta publish their
/// own branch feeds; nightly is treated as a superset feed and also receives promoted beta/stable
/// appcast items so Nightly users can see those builds without switching channels.
///
/// Build numbers are retained for promoted commits and Sparkle orders by `CFBundleVersion`, so no
/// `sparkle:channel` tags are needed.
enum UpdateChannel: String, CaseIterable, Identifiable, Codable, Sendable {
    case stable, beta, nightly

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .stable: return L10n.text("Stable")
        case .beta: return L10n.text("Beta")
        case .nightly: return L10n.text("Nightly")
        }
    }

    /// The git branch whose `appcast.xml` (at repo root) backs this channel.
    var branch: String {
        switch self {
        case .stable:  return "stable"
        case .beta:    return "beta"
        case .nightly: return "nightly"
        }
    }

    /// The Sparkle feed for this channel — the branch's `appcast.xml` served raw.
    var feedURL: String {
        "https://raw.githubusercontent.com/\(Links.owner)/\(Links.repo)/\(branch)/appcast.xml"
    }

    /// Sparkle's `allowedChannels(for:)` set. With per-branch feeds the feed selection *is* the
    /// channel, so this stays empty (kept for API completeness; items carry no channel tag).
    var allowedChannels: Set<String> { [] }

    var footnote: String {
        switch self {
        case .stable:  return L10n.text("Only finished releases.")
        case .beta:    return L10n.text("Pre-release builds, ahead of stable. May be rough.")
        case .nightly: return L10n.text("The latest build from every commit. Expect rough edges.")
        }
    }
}
