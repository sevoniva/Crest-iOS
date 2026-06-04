import Foundation

actor DashboardCache {
    private static let cacheDirectory: URL = {
        let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return urls[0].appendingPathComponent("com.sevoniva.crest.dashboards")
    }()
    
    static func setup() {
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    static func save(detail: DashboardDetail, id: String) async {
        setup()
        let url = cacheDirectory.appendingPathComponent("\(id).json")
        if let data = try? JSONEncoder().encode(detail) {
            try? data.write(to: url)
        }
    }
    
    static func load(id: String) async -> DashboardDetail? {
        let url = cacheDirectory.appendingPathComponent("\(id).json")
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(DashboardDetail.self, from: data)
    }
    
    static func clear() async {
        try? FileManager.default.removeItem(at: cacheDirectory)
    }
}
