import SwiftUI

struct StatusView: View {
  let status: SwitchStatus

  var body: some View {
    HStack {
      if case .switching = status {
        ProgressView()
          .controlSize(.small)
      } else {
        Image(systemName: status.systemImage)
          .accessibilityHidden(true)
      }

      Text(status.message)
        .font(.callout)
        .foregroundStyle(statusStyle)
        .lineLimit(2)
    }
    .accessibilityElement(children: .combine)
  }

  private var statusStyle: HierarchicalShapeStyle {
    .secondary
  }
}
