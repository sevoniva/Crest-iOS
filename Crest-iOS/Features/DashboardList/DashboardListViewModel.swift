import Foundation
import Observation

@Observable
final class DashboardListViewModel {
    var nodes: [DashboardNode] = []
    var isLoading = false
    var errorMessage: String?
    
    private let token: String
    
    init(token: String) {
        self.token = token
    }
    
    func load() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let data = try await DashboardAPI.fetchTree(token: token)
            await MainActor.run {
                self.nodes = data
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func flattenedNodes() -> [DashboardNode] {
        var result: [DashboardNode] = []
        for node in nodes {
            result.append(contentsOf: flatten(node: node))
        }
        return result
    }
    
    private func flatten(node: DashboardNode) -> [DashboardNode] {
        var result: [DashboardNode] = []
        if node.nodeType == "leaf" {
            result.append(node)
        }
        if let children = node.children {
            for child in children {
                result.append(contentsOf: flatten(node: child))
            }
        }
        return result
    }
}
