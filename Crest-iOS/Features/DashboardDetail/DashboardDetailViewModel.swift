import Foundation
import Observation

@Observable
final class DashboardDetailViewModel {
    var isLoading = false
    var errorMessage: String?
    
    private let token: String
    private let nodeId: String
    
    init(token: String, nodeId: String) {
        self.token = token
        self.nodeId = nodeId
    }
    
    func preloadCache() async {
        _ = await DashboardCache.load(id: nodeId)
    }
}
