import PackageDescription

let package = Package(
    name: "Time",
    dependencies: [
        .Package(url: "https://github.com/OhItsShaun/syncDataTask", majorVersion: 0),
    ]
)
