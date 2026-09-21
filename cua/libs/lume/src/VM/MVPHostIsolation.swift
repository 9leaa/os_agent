import Foundation

/// Project-local M0 guard. Set only on the developer-owned VM manager process.
/// This is not the tool policy for the agent running inside the guest.
enum MVPHostIsolation {
    static let enabled = ProcessInfo.processInfo.environment["LUME_MVP_HOST_ISOLATION"] == "1"

    static func validate(
        displayMode: DisplayMode, clipboard: Bool, hasHostAttachments: Bool,
        isolationEnabled: Bool = enabled
    ) throws {
        guard isolationEnabled else { return }
        guard displayMode == .none, !clipboard, !hasHostAttachments else {
            throw VMError.internalError(
                "MVP host isolation requires --display none, no clipboard, and no host attachments")
        }
    }
}
