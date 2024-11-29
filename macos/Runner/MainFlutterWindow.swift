import Cocoa
import FlutterMacOS
import window_plus

class MainFlutterWindow: NSWindow {
  override public func awakeFromNib() {
    WindowPlusPlugin.handleSingleInstance()

    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }

  override public func order(_ place: NSWindow.OrderingMode, relativeTo otherWin: Int) {
    super.order(place, relativeTo: otherWin)
    WindowPlusPlugin.hideUntilReady()
  }
}
