import Testing

@testable import DisplaySwitcher

struct BetterDisplayCommandTests {
  @Test("MAG uses hardware-verified input mappings")
  func magArguments() {
    let mac = BetterDisplayCommand(display: .mag, input: .mac)
    let windows = BetterDisplayCommand(display: .mag, input: .windows)

    #expect(mac.arguments.last == "-value=0x12")
    #expect(windows.arguments.last == "-value=0xF")
    #expect(mac.arguments.contains("-tagID=295"))
  }

  @Test("UHD uses write value 0x11 for Windows")
  func uhdArguments() {
    let mac = BetterDisplayCommand(display: .uhd, input: .mac)
    let windows = BetterDisplayCommand(display: .uhd, input: .windows)

    #expect(mac.arguments.last == "-value=0xF")
    #expect(windows.arguments.last == "-value=0x11")
    #expect(windows.arguments.contains("-tagID=2"))
  }

  @Test("Commands can only write VCP input source")
  func commandScope() {
    for display in DisplayTarget.allCases {
      for input in [ComputerInput.mac, .windows] {
        let arguments = BetterDisplayCommand(display: display, input: input).arguments

        #expect(arguments.first == "set")
        #expect(arguments.contains("-feature=ddc"))
        #expect(arguments.contains("-vcp=0x60"))
        #expect(arguments.count == 5)
      }
    }
  }
}
