import Foundation

struct TreeRequest: Codable {
    let busiFlag: String
    let leafOnly: Bool = false
}

struct DashboardNode: Codable, Identifiable {
    let id: String
    let name: String
    let pid: String?
    let nodeType: String
    let type: String?
    let mobileLayout: Bool?
    let status: Bool?
    let children: [DashboardNode]?
}

struct DashboardTreeResponse: Codable {
    let code: Int
    let data: [DashboardNode]?
}

struct DashboardDetailRequest: Codable {
    let id: String
    let busiFlag: String
}

struct DashboardDetail: Codable {
    let id: String?
    let name: String?
    let canvasStyleData: CanvasStyleData?
    let componentData: [ComponentData]?
    let mobileLayout: Bool?
}

struct CanvasStyleData: Codable {
    let width: Int?
    let height: Int?
    let scale: Double?
    let background: String?
}

struct ComponentData: Codable, Identifiable {
    let id: String
    let component: String
    let name: String?
    let style: ComponentStyle?
    let propValue: PropValue?
    let viewInfo: ChartViewInfo?
}

struct ComponentStyle: Codable {
    let width: Int?
    let height: Int?
    let top: Int?
    let left: Int?
}

struct PropValue: Codable {
    let text: String?
    let url: String?
}

struct ChartViewInfo: Codable {
    let id: String?
    let title: String?
    let type: String?
    let tableId: String?
}

struct DashboardDetailResponse: Codable {
    let code: Int
    let data: DashboardDetail?
}

struct ChartDataRequest: Codable {
    let chartId: String?
    let chartType: String?
    let busiFlag: String?
}

struct ChartDataResponse: Codable {
    let code: Int
    let data: ChartData?
}

struct ChartData: Codable {
    let data: [[String: AnyCodable]]?
}

struct AnyCodable: Codable {
    let value: Any
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            value = string
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else {
            value = ""
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let string = value as? String {
            try container.encode(string)
        } else if let int = value as? Int {
            try container.encode(int)
        } else if let double = value as? Double {
            try container.encode(double)
        } else if let bool = value as? Bool {
            try container.encode(bool)
        }
    }
}
