import SwiftUI

@main
struct DisplaySwitcherApp: App {
  @State private var controller = SwitchController()

  var body: some Scene {
    MenuBarExtra("DisplaySwitcher", systemImage: "display.2") {
      SwitchMenuView(controller: controller)
    }
    .menuBarExtraStyle(.window)
  }
}
