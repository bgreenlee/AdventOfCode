// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AdventOfCode2020",
    products: [
        .executable(name: "reportRepair",           targets: ["01-ReportRepair"]),
        .executable(name: "passwordPhilosophy",     targets: ["02-PasswordPhilosophy"]),
        .executable(name: "tobogganTrajectory",     targets: ["03-TobogganTrajectory"]),
        .executable(name: "passportProcessing",     targets: ["04-PassportProcessing"]),
        .executable(name: "binaryBoarding",         targets: ["05-BinaryBoarding"]),
        .executable(name: "customCustoms",          targets: ["06-CustomCustoms"]),
        .executable(name: "handyHaversacks",        targets: ["07-HandyHaversacks"]),
        .executable(name: "handheldHalting",        targets: ["08-HandheldHalting"]),
        .executable(name: "encodingError",          targets: ["09-EncodingError"]),
        .executable(name: "adapterArray",           targets: ["10-AdapterArray"]),
        .executable(name: "seatingSystem",          targets: ["11-SeatingSystem"]),
        .executable(name: "rainRisk",               targets: ["12-RainRisk"]),
        .executable(name: "shuttleSearch",          targets: ["13-ShuttleSearch"]),
        .executable(name: "dockingData",            targets: ["14-DockingData"]),
        .executable(name: "rambunctiousRecitation", targets: ["15-RambunctiousRecitation"]),
        .executable(name: "ticketTranslation",      targets: ["16-TicketTranslation"]),
        .executable(name: "conwayCubes",            targets: ["17-ConwayCubes"]),
        .executable(name: "operationOrder",         targets: ["18-OperationOrder"]),
        .executable(name: "monsterMessages",        targets: ["19-MonsterMessages"]),
        .executable(name: "jurassicJigsaw",         targets: ["20-JurassicJigsaw"]),
        .executable(name: "allergenAssessment",     targets: ["21-AllergenAssessment"]),
        .executable(name: "crabCombat",             targets: ["22-CrabCombat"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/attaswift/BigInt.git", from: "5.2.1")
    ],
    targets: [
        .target(name: "Shared"),
        .target(name: "01-ReportRepair",           dependencies: ["Shared"], resources: [.copy("data")]),
        .target(name: "02-PasswordPhilosophy",     dependencies: ["Shared"], resources: [.copy("data")]),
        .target(name: "03-TobogganTrajectory",     dependencies: ["Shared"], resources: [.copy("data")]),
        .target(name: "04-PassportProcessing",     dependencies: ["Shared"], resources: [.copy("data")]),
        .target(name: "05-BinaryBoarding",         dependencies: ["Shared"], resources: [.copy("data")]),
        .target(name: "06-CustomCustoms",          dependencies: ["Shared"], resources: [.copy("data")]),
        .target(name: "07-HandyHaversacks",        dependencies: ["Shared"], resources: [.copy("data")]),
        .target(name: "08-HandheldHalting",        dependencies: ["Shared"], resources: [.copy("data")]),
        .target(name: "09-EncodingError",          dependencies: ["Shared"], resources: [.copy("data")]),
        .target(name: "10-AdapterArray",           dependencies: ["Shared"], resources: [.copy("data")]),
        .target(name: "11-SeatingSystem",          dependencies: ["Shared"], resources: [.copy("data")]),
        .target(name: "12-RainRisk",               dependencies: ["Shared"], resources: [.copy("data")]),
        .target(name: "13-ShuttleSearch",          dependencies: ["Shared", "BigInt"], resources: [.copy("data")]),
        .target(name: "14-DockingData",            dependencies: ["Shared"], resources: [.copy("data")]),
        .target(name: "15-RambunctiousRecitation", dependencies: ["Shared"], resources: [.copy("data")]),
        .target(name: "16-TicketTranslation",      dependencies: ["Shared"], resources: [.copy("data")]),
        .target(name: "17-ConwayCubes",            dependencies: ["Shared"], resources: [.copy("data")]),
        .target(name: "18-OperationOrder",         dependencies: ["Shared"], resources: [.copy("data")]),
        .target(name: "19-MonsterMessages",        dependencies: ["Shared"], resources: [.copy("data")]),
        .target(name: "20-JurassicJigsaw",         dependencies: ["Shared"], resources: [.copy("data")]),
        .target(name: "21-AllergenAssessment",     dependencies: ["Shared"], resources: [.copy("data")]),
        .target(name: "22-CrabCombat",             dependencies: ["Shared"], resources: [.copy("data")]),
    ]
)
