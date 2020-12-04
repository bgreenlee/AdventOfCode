// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AdventOfCode2020",
    products: [
        .executable(name: "reportRepair",       targets: ["01-ReportRepair"]),
        .executable(name: "passwordPhilosophy", targets: ["02-PasswordPhilosophy"]),
        .executable(name: "tobogganTrajectory", targets: ["03-TobogganTrajectory"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(name: "01-ReportRepair",       resources: [.copy("data")]),
        .target(name: "02-PasswordPhilosophy", resources: [.copy("data")]),
        .target(name: "03-TobogganTrajectory", resources: [.copy("data")]),
    ]
)
