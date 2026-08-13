enum ComputerInput: String, Sendable {
  case mac
  case windows

  var title: String {
    switch self {
    case .mac:
      "Mac"
    case .windows:
      "Windows"
    }
  }
}
