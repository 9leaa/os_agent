import Testing
import Virtualization
@testable import lume

@Test("MVP isolation rejects desktop bridges and host attachments")
func mvpIsolationRejectsHostAccess() throws {
    try MVPHostIsolation.validate(
        displayMode: .none, clipboard: false, hasHostAttachments: false, isolationEnabled: true)
    for (display, clipboard, attachments) in [
        (DisplayMode.native, false, false), (.vnc, false, false),
        (.none, true, false), (.none, false, true)
    ] {
        #expect(throws: (any Error).self) {
            try MVPHostIsolation.validate(
                displayMode: display, clipboard: clipboard,
                hasHostAttachments: attachments, isolationEnabled: true)
        }
    }
}

@MainActor
@Test("MVP isolation removes implicit and requested filesystem devices", .enabled(if: MVPHostIsolation.enabled))
func mvpIsolationHasNoShareDevices() throws {
    #expect(MVPHostIsolation.enabled)
    let devices = BaseVirtualizationService.createDirectorySharingDevices(
        sharedDirectories: [SharedDirectory(hostPath: "/var/empty", tag: "test", readOnly: true)],
        withLiveUpdatePlaceholder: true)
    #expect(devices.isEmpty)
    #expect(!VM.shouldStartClipboardWatcher(
        displayMode: .native, osType: "macOS", explicitlyRequested: true))
}
