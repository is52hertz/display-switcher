import Foundation
import Observation

@MainActor
@Observable
final class SwitchController {
  private(set) var status = SwitchStatus.idle
  private(set) var isSwitching = false

  private let client: BetterDisplayClient

  init(client: BetterDisplayClient = BetterDisplayClient()) {
    self.client = client
  }

  func switchAll(to input: ComputerInput) {
    run(displays: DisplayTarget.allCases, input: input)
  }

  func switchDisplay(_ display: DisplayTarget, to input: ComputerInput) {
    run(displays: [display], input: input)
  }

  private func run(displays: [DisplayTarget], input: ComputerInput) {
    guard !isSwitching else { return }

    isSwitching = true
    status = .switching("正在切到 \(input.title)…")

    Task {
      do {
        for display in displays {
          let command = BetterDisplayCommand(display: display, input: input)
          try await client.execute(command)
        }

        status = .success("已切到 \(input.title)")
      } catch {
        status = .failure(error.localizedDescription)
      }

      isSwitching = false
    }
  }
}
