import Foundation

enum NativeVoiceTemporaryFiles {
  private static let prefix = "voice-capture-"

  static func makeURL() -> URL {
    FileManager.default.temporaryDirectory
      .appendingPathComponent("\(prefix)\(UUID().uuidString).m4a")
  }

  static func remove(_ url: URL?) {
    guard let url else { return }
    try? FileManager.default.removeItem(at: url)
  }

  static func cleanupOrphans(olderThan age: TimeInterval = 86_400) {
    let directory = FileManager.default.temporaryDirectory
    let cutoff = Date().addingTimeInterval(-age)
    let urls = (try? FileManager.default.contentsOfDirectory(
      at: directory,
      includingPropertiesForKeys: [.contentModificationDateKey]
    )) ?? []
    for url in urls where url.lastPathComponent.hasPrefix(prefix) {
      let modified = try? url.resourceValues(
        forKeys: [.contentModificationDateKey]
      ).contentModificationDate
      if modified == nil || modified! < cutoff { remove(url) }
    }
  }

  static func byteLength(_ url: URL) -> Int64 {
    let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
    return (attributes?[.size] as? NSNumber)?.int64Value ?? 0
  }
}
