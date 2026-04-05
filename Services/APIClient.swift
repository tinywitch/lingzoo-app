import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodedError(Error)
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "The URL provided is invalid."
        case .invalidResponse: return "The server response was invalid."
        case .decodedError(let error): return "Failed to decode the response: \(error.localizedDescription)"
        case .serverError(let message): return message
        }
    }
}

class APIClient {
    static let shared = APIClient()
    private init() {}
    
    private let keychainService = "com.lingzoo.token"
    private let keychainAccount = "lingzoo"
    
    private var accessToken: String? {
        if let data = KeychainHelper.standard.read(service: keychainService, account: keychainAccount),
           let token = String(data: data, encoding: .utf8) {
            return token
        }
        return nil
    }
    
    func saveToken(_ token: String) {
        if let data = token.data(using: .utf8) {
            KeychainHelper.standard.save(data, service: keychainService, account: keychainAccount)
        }
    }
    
    func clearToken() {
        KeychainHelper.standard.delete(service: keychainService, account: keychainAccount)
    }
    
    var isLoggedIn: Bool {
        return accessToken != nil
    }

    /// Performs a network request using the provided endpoint, method, and parameters.
    func request<T: Codable>(path: String, method: String = "GET", body: Data? = nil, isMultipart: Bool = false) async throws -> T {
        guard let url = URL(string: Environment.baseURL + path) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        // Add Authorization header if we have a token
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if isMultipart {
            // Content-Type is set by the multipart encoder caller
        } else {
            if method != "GET" {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }
        
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            // Try to decode error message from server
            if let errorResponse = try? JSONDecoder().decode(BaseResponse<String>.self, from: data), let msg = errorResponse.message {
                throw NetworkError.serverError(msg)
            }
            throw NetworkError.serverError("Server returned status code \(httpResponse.statusCode)")
        }
        
        do {
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            return decodedData
        } catch {
            print("Decoding Error: \(error)")
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON: \(jsonString)")
            }
            throw NetworkError.decodedError(error)
        }
    }
    
    /// Helper to send form-data or JSON, simply by using the request method
    /// If we need multipart (for Avatar), we will build a multipart body builder.
    func requestMultipart<T: Codable>(path: String, method: String = "POST", parameters: [String: String], imageData: Data? = nil, imageKey: String = "avatar", fileName: String = "avatar.jpg") async throws -> T {
        guard let url = URL(string: Environment.baseURL + path) else {
            throw NetworkError.invalidURL
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        var body = Data()
        
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        if let imageData = imageData {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(imageKey)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            if let errorResponse = try? JSONDecoder().decode(BaseResponse<String>.self, from: data), let msg = errorResponse.message {
                throw NetworkError.serverError(msg)
            }
            throw NetworkError.serverError("Server returned status code \(httpResponse.statusCode)")
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("Decoding Error: \(error)")
            throw NetworkError.decodedError(error)
        }
    }
}
