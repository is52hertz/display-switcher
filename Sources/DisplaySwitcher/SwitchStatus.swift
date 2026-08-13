enum SwitchStatus: Equatable {
  case idle
  case switching(String)
  case success(String)
  case failure(String)

  var message: String {
    switch self {
    case .idle:
      "准备就绪"
    case .switching(let message), .success(let message), .failure(let message):
      message
    }
  }

  var systemImage: String {
    switch self {
    case .idle:
      "circle"
    case .switching:
      "arrow.trianglehead.2.clockwise.rotate.90"
    case .success:
      "checkmark.circle.fill"
    case .failure:
      "exclamationmark.triangle.fill"
    }
  }
}
