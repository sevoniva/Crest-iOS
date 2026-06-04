import Foundation
import Observation

@Observable
final class DashboardDetailViewModel {
    var detail: DashboardDetail?
    var isLoading = false
    var errorMessage: String?
    
    private let token: String
    private let nodeId: String
    
    init(token: String, nodeId: String) {
        self.token = token
        self.nodeId = nodeId
    }
    
    func load() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let data = try await DashboardAPI.fetchDetail(token: token, id: nodeId)
            await MainActor.run {
                self.detail = data
                self.isLoading = false
            }
            
            await DashboardCache.save(detail: data, id: nodeId)
        } catch {
            if let cached = await DashboardCache.load(id: nodeId) {
                await MainActor.run {
                    self.detail = cached
                    self.errorMessage = "已加载缓存数据"
                    self.isLoading = false
                }
            } else {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}
