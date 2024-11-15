// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "modules",
  platforms: [.iOS(.v18)],
  products: [
    .library(name: "ApiClient", targets: ["ApiClient"]),
    .library(name: "ApiClientLive", targets: ["ApiClientLive"]),
    .library(name: "ListFeature", targets: ["ListFeature"]),
    .library(name: "Model", targets: ["Model"]),
    .library(name: "StatusFeature", targets: ["StatusFeature"]),
    .library(name: "Styleguide", targets: ["Styleguide"])
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-navigation", from: "2.2.2"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.5.2"),
    .package(url: "https://github.com/pointfreeco/swift-identified-collections", from: "1.1.0")
  ],
  targets: [
    .target(
      name: "ApiClient",
      dependencies: [
        "Model",
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies")
      ]
    ),
    .target(
      name: "ApiClientLive",
      dependencies: [
        "ApiClient",
        .product(name: "Dependencies", package: "swift-dependencies")
      ]
    ),
    .target(
      name: "ListFeature",
      dependencies: [
        "ApiClient",
        "Styleguide",
        "StatusFeature",
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "SwiftUINavigation", package: "swift-navigation"),
        //        .product(name: "IdentifiedCollections", package: "swift-identified-collections")
      ]
    ),
    .target(
      name: "Model"
    ),
    .target(
      name: "StatusFeature",
      dependencies: [
        "ApiClient",
        "Styleguide",
        .product(name: "Dependencies", package: "swift-dependencies")
      ]
    ),
    .target(name: "Styleguide"),
    .testTarget(
      name: "ListFeatureTests",
      dependencies: ["ListFeature"]
    ),
    .testTarget(
      name: "StatusFeatureTests",
      dependencies: ["StatusFeature"]
    ),
  ]
)
