import Foundation
import Testing
@testable import PasteMemo

@Suite("Disabled updates")
struct DisabledUpdatesTests {
    @Test @MainActor
    func manualAndAutomaticEntryPointsStayDisabled() async {
        let updater = UpdateChecker.shared
        let previousCheck = UserDefaults.standard.object(forKey: "lastUpdateCheck") as? Date
        #expect(!UpdateChecker.isEnabled)
        await updater.checkForUpdates()
        await updater.checkForUpdates(userInitiated: true)
        updater.startPeriodicChecks()
        updater.downloadUpdate()
        updater.installAndRestart()
        #expect(!updater.isChecking)
        #expect(!updater.isDownloading)
        #expect(!updater.updateAvailable)
        #expect(!updater.showUpdateDialog)
        #expect(UserDefaults.standard.object(forKey: "lastUpdateCheck") as? Date == previousCheck)
    }
}
