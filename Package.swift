import PackageDescription

let package = Package(
  name:         "SwiftClickHouse",
  targets:      [],
  dependencies: [
      .Package(url: "https://github.com/IBM-Swift/SwiftyJSON", majorVersion: 16, minor: 0),
      .Package(url: "https://github.com/Zig1375/BlueSocket.git", majorVersion: 0, minor: 12)
  ]
)