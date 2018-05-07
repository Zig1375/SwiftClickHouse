import PackageDescription

let package = Package(
  name:         "SwiftClickHouse",
  targets:      [],
  dependencies: [
      .Package(url: "https://github.com/IBM-Swift/SwiftyJSON", majorVersion: 17, minor: 0),
      .Package(url: "https://github.com/IBM-Swift/BlueSocket.git", majorVersion: 1, minor: 0)
  ]
)