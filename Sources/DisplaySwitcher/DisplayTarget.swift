enum DisplayTarget: String, CaseIterable, Identifiable, Sendable {
  case mag
  case uhd

  nonisolated var id: Self { self }

  nonisolated var title: String {
    switch self {
    case .mag:
      "MAG 274QR E20"
    case .uhd:
      "UHD HDR"
    }
  }

  nonisolated var tagID: Int {
    switch self {
    case .mag:
      295
    case .uhd:
      2
    }
  }

  nonisolated func inputValue(for computer: ComputerInput) -> Int {
    switch (self, computer) {
    case (.mag, .mac):
      0x12
    case (.mag, .windows):
      0x0F
    case (.uhd, .mac):
      0x0F
    case (.uhd, .windows):
      0x11
    }
  }
}
