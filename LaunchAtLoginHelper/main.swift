import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {
	func applicationDidFinishLaunching(_ notification: Notification) {
		let bundleId = Bundle.main.bundleIdentifier!
		// TODO: Make this more strict by only replacing at the end
		let mainBundleId = bundleId.replacingOccurrences(of: "-LaunchAtLoginHelper", with: "")

		// Ensure the app is not already running
		guard NSRunningApplication.runningApplications(withBundleIdentifier: mainBundleId).isEmpty else {
			NSApp.terminate(nil)
			return
		}

		let pathComponents = (Bundle.main.bundlePath as NSString).pathComponents
		let mainPath = NSString.path(withComponents: Array(pathComponents[0...(pathComponents.count - 5)]))
		let mainURL = URL(fileURLWithPath: mainPath)
		try! NSWorkspace.shared.launchApplication(at: mainURL, options: [.andHide], configuration: [
			.appleEvent: NSAppleEventDescriptor(
				eventClass: UTGetOSTypeFromString("SDSL" as CFString),
				eventID: UTGetOSTypeFromString("LatL" as CFString),
				targetDescriptor: nil,
				returnID: AEReturnID(kAutoGenerateReturnID),
				transactionID: AETransactionID(kAnyTransactionID)
			)
		])
		NSApp.terminate(nil)
	}
}

private let app = NSApplication.shared
private let delegate = AppDelegate()
app.delegate = delegate
app.run()
