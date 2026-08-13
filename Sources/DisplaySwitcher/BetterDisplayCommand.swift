struct BetterDisplayCommand: Equatable, Sendable {
  nonisolated static let executablePath =
    "/Applications/BetterDisplay.app/Contents/MacOS/BetterDisplay"

  let display: DisplayTarget
  let input: ComputerInput

  nonisolated var arguments: [String] {
    [
      "set",
      "-tagID=\(display.tagID)",
      "-feature=ddc",
      "-vcp=0x60",
      "-value=\(inputValue)",
    ]
  }

  nonisolated private var inputValue: String {
    let value = display.inputValue(for: input)
    return "0x\(String(value, radix: 16, uppercase: true))"
  }
}
