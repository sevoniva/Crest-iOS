import Foundation

enum DashboardAPI {
    static func fetchTree(token: String, busiFlag: String = "dashboard") async throws -> [DashboardNode] {
        let request = TreeRequest(busiFlag: busiFlag)
        let response: DashboardTreeResponse = try await APIService.shared.post(
            path: "/data-visualization/tree",
            body: request,
            token: token
        )
        guard response.code == 0 else {
            throw APIError.serverError("获取仪表板列表失败")
        }
        return response.data ?? []
    }
    
    static func fetchDetail(token: String, id: String, busiFlag: String = "dashboard") async throws -> DashboardDetail {
        let request = DashboardDetailRequest(id: id, busiFlag: busiFlag)
        let response: DashboardDetailResponse = try await APIService.shared.post(
            path: "/data-visualization/detail",
            body: request,
            token: token
        )
        guard response.code == 0, let data = response.data else {
            throw APIError.serverError("获取仪表板详情失败")
        }
        return data
    }
    
    static func fetchChartData(token: String, chartId: String, chartType: String? = nil) async throws -> ChartData {
        let request = ChartDataRequest(chartId: chartId, chartType: chartType, busiFlag: "dashboard")
        let response: ChartDataResponse = try await APIService.shared.post(
            path: "/chart-data/data",
            body: request,
            token: token
        )
        guard response.code == 0 else {
            throw APIError.serverError("获取图表数据失败")
        }
        return response.data ?? ChartData(data: [])
    }
}
