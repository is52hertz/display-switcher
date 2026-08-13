import SwiftUI

struct DisplaySwitchRow: View {
  let display: DisplayTarget
  let isDisabled: Bool
  let switchToMac: () -> Void
  let switchToWindows: () -> Void

  var body: some View {
    HStack {
      Text(display.title)
        .lineLimit(1)

      Spacer()

      Button("Mac", systemImage: "macmini", action: switchToMac)
      Button("Windows", systemImage: "desktopcomputer", action: switchToWindows)
    }
    .disabled(isDisabled)
  }
}
