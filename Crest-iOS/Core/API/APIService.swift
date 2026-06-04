import Foundation

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodeError
    case serverError(String)
    case networkError(Error)
}

actor APIService {
    static let shared = APIService()
    
    private let baseURL = "https://crest.sevoniva.com"
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: config)
    }
    
    func request<T: Decodable>(
        path: String,
        method: String = "GET",
        body: Encodable? = nil,
        token: String? = nil
    ) async throws -> T {
        guard let url = URL(string: baseURL + path) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("zh-CN", forHTTPHeaderField: "Accept-Language")
        request.setValue("true", forHTTPHeaderField: "X-CREST-MOBILE")
        
        if let token = token {
            request.setValue(token, forHTTPHeaderField: "X-CREST-TOKEN")
        }
        
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.httpError(httpResponse.statusCode)
            }
            
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw APIError.decodeError
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func get<T: Decodable>(path: String, token: String? = nil) async throws -> T {
        try await request(path: path, method: "GET", token: token)
    }
    
    func post<T: Decodable>(path: String, body: Encodable? = nil, token: String? = nil) async throws -> T {
        try await request(path: path, method: "POST", body: body, token: token)
    }
}
