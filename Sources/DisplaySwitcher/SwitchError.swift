import Foundation

enum SwitchError: LocalizedError {
  case betterDisplayMissing
  case commandFailed(display: DisplayTarget, output: String)

  var errorDescription: String? {
    switch self {
    case .betterDisplayMissing:
      "未找到 BetterDisplay，请确认它安装在“应用程序”文件夹中。"
    case .commandFailed(let display, let output):
      if output.isEmpty {
        "\(display.title) 切换失败。"
      } else {
        "\(display.title) 切换失败：\(output)"
      }
    }
  }
}
