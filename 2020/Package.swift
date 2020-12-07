// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AdventOfCode2020",
    products: [
        .executable(name: "reportRepair",       targets: ["01-ReportRepair"]),
        .executable(name: "passwordPhilosophy", targets: ["02-PasswordPhilosophy"]),
        .executable(name: "tobogganTrajectory", targets: ["03-TobogganTrajectory"]),
        .executable(name: "passportProcessing", targets: ["04-PassportProcessing"]),
        .executable(name: "binaryBoarding",     targets: ["05-BinaryBoarding"]),
        .executable(name: "customCustoms",      targets: ["06-CustomCustoms"]),
        .executable(name: "handyHaversacks",    targets: ["07-HandyHaversacks"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(name: "Shared"),
        .target(name: "01-ReportRepair",       dependencies: ["Shared"], resources: [.copy("data")]),
        .target(name: "02-PasswordPhilosophy", dependencies: ["Shared"], resources: [.copy("data")]),
        .target(name: "03-TobogganTrajectory", dependencies: ["Shared"], resources: [.copy("data")]),
        .target(name: "04-PassportProcessing", dependencies: ["Shared"], resources: [.copy("data")]),
        .target(name: "05-BinaryBoarding",     dependencies: ["Shared"], resources: [.copy("data")]),
        .target(name: "06-CustomCustoms",      dependencies: ["Shared"], resources: [.copy("data")]),
        .target(name: "07-HandyHaversacks",    dependencies: ["Shared"], resources: [.copy("data")]),
    ]
)
