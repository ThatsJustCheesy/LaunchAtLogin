import Foundation
import ServiceManagement

public struct LaunchAtLogin {
	private static let id = "\(Bundle.main.bundleIdentifier!)-LaunchAtLoginHelper"

	public static var isEnabled: Bool {
		get {
			guard let jobs = (SMCopyAllJobDictionaries(kSMDomainUserLaunchd).takeRetainedValue() as? [[String: AnyObject]]) else {
				return false
			}

			let job = jobs.first { $0["Label"] as! String == id }

			return job?["OnDemand"] as? Bool ?? false
		}
		set {
			SMLoginItemSetEnabled(id as CFString, newValue)
		}
	}
	
	public static func listenWhetherLaunchedAtLogin() {
		NSAppleEventManager.shared().setEventHandler(
			appleEventHandler,
			andSelector: #selector(AppleEventHandler.handleLaunchedAtLoginEvent(_:reply:)),
			forEventClass: UTGetOSTypeFromString("SDSL" as CFString),
			andEventID: UTGetOSTypeFromString("LatL" as CFString)
		)
	}
	
	@objc
	private class AppleEventHandler: NSObject {
		@objc
		func handleLaunchedAtLoginEvent(_ event: NSAppleEventDescriptor, reply: NSAppleEventDescriptor) {
			LaunchAtLogin.wasLaunchedAtLogin = true
		}
	}
	
	private static var appleEventHandler = AppleEventHandler()
	/**
	Whether the app was launched at login. Always `false` unless
	`LaunchAtLogin.listenWhetherLaunchedAtLogin()` is called early in the
	app lifecycle, and the app was, in fact, launched at login using the
	LaunchAtLogin helper app.
	*/
	public static var wasLaunchedAtLogin: Bool = false
}
