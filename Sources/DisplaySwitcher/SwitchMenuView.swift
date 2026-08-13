import SwiftUI

struct SwitchMenuView: View {
  let controller: SwitchController

  var body: some View {
    VStack(alignment: .leading) {
      Text("显示器切换")
        .font(.headline)

      HStack {
        Button("全部切到 Mac", systemImage: "macmini", action: switchAllToMac)
          .buttonStyle(.borderedProminent)
        Button("全部切到 Windows", systemImage: "desktopcomputer", action: switchAllToWindows)
          .buttonStyle(.borderedProminent)
      }

      Divider()

      ForEach(DisplayTarget.allCases) { display in
        DisplaySwitchRow(
          display: display,
          isDisabled: controller.isSwitching,
          switchToMac: { switchDisplay(display, to: .mac) },
          switchToWindows: { switchDisplay(display, to: .windows) }
        )
      }

      Divider()

      StatusView(status: controller.status)

      HStack {
        Spacer()
        Button("退出", systemImage: "power", action: quit)
          .buttonStyle(.plain)
      }
    }
    .padding()
    .frame(width: 360)
    .disabled(controller.isSwitching)
  }

  private func switchAllToMac() {
    controller.switchAll(to: .mac)
  }

  private func switchAllToWindows() {
    controller.switchAll(to: .windows)
  }

  private func switchDisplay(_ display: DisplayTarget, to input: ComputerInput) {
    controller.switchDisplay(display, to: input)
  }

  private func quit() {
    NSApplication.shared.terminate(nil)
  }
}
