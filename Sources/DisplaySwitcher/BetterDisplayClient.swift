import Foundation

struct BetterDisplayClient: Sendable {
  func execute(_ command: BetterDisplayCommand) async throws {
    guard FileManager.default.isExecutableFile(atPath: BetterDisplayCommand.executablePath) else {
      throw SwitchError.betterDisplayMissing
    }

    let result = await Task.detached(priority: .userInitiated) {
      let process = Process()
      let outputPipe = Pipe()

      process.executableURL = URL(fileURLWithPath: BetterDisplayCommand.executablePath)
      process.arguments = command.arguments
      process.standardOutput = outputPipe
      process.standardError = outputPipe

      do {
        try process.run()
        process.waitUntilExit()
      } catch {
        return CommandResult(exitCode: -1, output: error.localizedDescription)
      }

      let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
      let output = String(decoding: data, as: UTF8.self)
        .trimmingCharacters(in: .whitespacesAndNewlines)
      return CommandResult(exitCode: process.terminationStatus, output: output)
    }.value

    guard result.exitCode == 0, result.output != "Failed." else {
      throw SwitchError.commandFailed(display: command.display, output: result.output)
    }
  }
}
