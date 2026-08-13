// swift-tools-version: 6.2
import PackageDescription

let package = Package(
  name: "DisplaySwitcher",
  platforms: [
    .macOS(.v14)
  ],
  products: [
    .executable(name: "DisplaySwitcher", targets: ["DisplaySwitcher"])
  ],
  targets: [
    .executableTarget(
      name: "DisplaySwitcher",
      swiftSettings: [
        .defaultIsolation(MainActor.self)
      ]
    ),
    .testTarget(
      name: "DisplaySwitcherTests",
      dependencies: ["DisplaySwitcher"],
      swiftSettings: [
        .defaultIsolation(MainActor.self)
      ]
    ),
  ]
)
