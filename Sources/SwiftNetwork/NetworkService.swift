//
//  File.swift
//  
//
//  Created by Hologram1 on 1/25/24.
//

import Foundation

/// API request methods
public enum HTTPMethod: String {
    /// GET for get request
    case GET
    /// POST for post request. In post request
    /// data pass in httpBody
    case POST
    case PUT
    case DELETE
    case PATCH
    case MULTIPART
}


/// A protocol for making URLRequest
public protocol APIEndpointProtocol_V {
    var path: String { get }
    var parameter: [String: String]? { get }
    var method: HTTPMethod { get }
    var parameterEncoder: ParameterEncodable { get }
    func createURLRequest(
        for apiEnvironment: APIEnvironment
    ) -> URLRequest
    
}

/// A protocol for making request
/// parameters to queryable ,
/// then attach with `URLRequest`
public protocol ParameterEncodable {
    func encodeParameter(parameter: [String: String],
                         method: HTTPMethod,
                         for request: inout URLRequest)
    func encodeParameterForStripe(parameter: [String : String],
                                         method: HTTPMethod,
                                         for request: inout URLRequest)
}

/// Default encode for 
/// `URLRequest` parameters
public struct JSONSerializableParameterEncoder: ParameterEncodable {
    
    public init () {}
        
        /// A function for making
    /// encode and attach into `Request`
    public func encodeParameter(parameter: [String : String],
                         method: HTTPMethod,
                         for request: inout URLRequest) {
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameter, options: [])
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        } catch {
            print("PARAMETR encode error: \(error.localizedDescription)")
        }
    }
    
    
        /// A function for making
        /// encode and attach into `Request`
    public func encodeParameterForStripe(parameter: [String : String],
                                method: HTTPMethod,
                                for request: inout URLRequest) {
        do {
            
            let bodyString = parameter.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
            
            request.httpBody = bodyString.data(using: .utf8)
            request.addValue("application/json", forHTTPHeaderField: "Accept")
           
        } catch {
            print("PARAMETR encode error: \(error.localizedDescription)")
        }
    }

}

/// Default implementation 
/// for `APIEndpointProtocol_V`
public struct APIEndPoint_V: APIEndpointProtocol_V {
    public var path: String
    public var parameter: [String : String]? = nil
    public var method: HTTPMethod = .GET
    public var parameterEncoder: ParameterEncodable
    
    @available(*, deprecated, message: "please set authToken using `StylePickAPISDKConfig`")
    public init(
        path: String,
        parameter: [String : String]? = nil,
        method: HTTPMethod = .GET,
        parameterEncoder: ParameterEncodable = JSONSerializableParameterEncoder(),
        authToken: String? = nil
    ) {
        self.path = path
        self.parameter = parameter
        self.method = method
        self.parameterEncoder = parameterEncoder
       
    }
    
    public init(
        path: String,
        parameter: [String : String]? = nil,
        method: HTTPMethod = .GET,
        parameterEncoder: ParameterEncodable = JSONSerializableParameterEncoder()
    ) {
        self.path = path
        self.parameter = parameter
        self.method = method
        self.parameterEncoder = parameterEncoder
       
    }
    
   public  func createURLRequest(
        for apiEnvironment: APIEnvironment
    ) -> URLRequest {
        if method == .GET {
            var url = URL(string: "\(apiEnvironment.baseURL)\(path)")
            
            var urlComponent = URLComponents(url: url!, resolvingAgainstBaseURL: false)
            
            urlComponent?.queryItems = self.method == .GET ? parameter?.getURLQueryItems() ?? [] : []
            
            var urlRequest = URLRequest(url: urlComponent!.url!)
            
            print("URL: \(urlRequest.url?.absoluteString)")
            urlRequest.httpMethod = method.rawValue
            return urlRequest
        }
        var url = URL(string: "\(apiEnvironment.baseURL)\(path)")
        var urlRequest = URLRequest(url: url!)
        
        if method == .MULTIPART {
            return urlRequest
        }
        
        
        urlRequest.httpMethod = method.rawValue
        if  method == .POST {
            if apiEnvironment == .Stripe {
                parameterEncoder.encodeParameterForStripe(parameter: parameter ?? [:], method: .POST, for: &urlRequest)
            } else {
                parameterEncoder.encodeParameter(parameter: parameter ?? [:], method: .POST, for: &urlRequest)
            }
        }
        
        return urlRequest
    }
}


extension Dictionary where Self.Key == String , Self.Value == String {
    func getURLQueryItems() -> [URLQueryItem] {
        return self.map({URLQueryItem(name: $0.key, value: $0.value)})
    }
}



/// A protocol responsible for 
/// sending `APIRequest` and `ReturnResponse`
 public protocol NetworkService {
    func get<T: Decodable>(
        apiEndpoint: APIEndpointProtocol_V
    ) async throws -> Result<T, Error>
    
     func getData(
        apiEndpoint: APIEndpointProtocol_V
    ) async throws -> Data
    
    func uploadFormData(
        apiEndpoint: APIEndpointProtocol_V, fileThatUpload: FileThatUpload
    ) async throws -> Data
    
}

/// `URLSession` implementation 
/// of `NetworkService`
public struct URLSessionNetworkService: NetworkService {
    let urlSession: URLSession
    let apiEnvironment: APIEnvironment
    let config: RetailAPIConfiguration
    
    public init(urlSession: URLSession = URLSession.shared,
                apiEnvironment: APIEnvironment = .DEV,
                config: RetailAPIConfiguration = RetailAPIConfiguration.shared) {
        self.urlSession = urlSession
        self.apiEnvironment = apiEnvironment
        self.config = config
    }
    
    
    public func get<T>(
        apiEndpoint: APIEndpointProtocol_V
    ) async throws -> Result<T, Error> where T : Decodable {
        var urlRequest = apiEndpoint.createURLRequest(for: apiEnvironment)
        
        if config.authToken != "" {
            urlRequest.setValue("Bearer \(config.getAuthToken(for: apiEnvironment))", forHTTPHeaderField: "Authorization")
        }
        
        if apiEnvironment == .Stripe {
            urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        }
        
        
        urlRequest.setValue("apps", forHTTPHeaderField: "Request-From")
        
        if let body = urlRequest.httpBody {
            print(String(data: body, encoding: .utf8))
        }
        
        
        let (data, _) = try await urlSession.data(for: urlRequest)
        print(try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any])
        return .success( try JSONDecoder().decode(T.self, from: data))
    }
    
    
     public func uploadFormData(
        apiEndpoint: APIEndpointProtocol_V, fileThatUpload: FileThatUpload
    ) async throws -> Data {
        var urlRequest = apiEndpoint.createURLRequest(for: apiEnvironment)
        
        var data: Data = Data()
        
        if config.authToken != "" {
            urlRequest.setValue("Bearer \(config.authToken)", forHTTPHeaderField: "Authorization")
        }
        
        let boundary = BoundaryGenerator.default.makeBoundary()
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let dataParameter = MultipartParameter(parameter: apiEndpoint.parameter ?? [:])
        dataParameter.addInto(body: &data, boundary: boundary)
        fileThatUpload.addInto(body: &data, boundary: boundary)
        
       
        
        urlRequest.httpBody = data
        
        if let body = urlRequest.httpBody {
            print(String(data: body, encoding: .utf8))
        }
        
        
        let (responseData, _) = try await urlSession.data(for: urlRequest)
        print("RESPONSE:  \(String(data: responseData, encoding: .utf8))")
        return responseData
    }
    
     public func getData(
        apiEndpoint: APIEndpointProtocol_V
    ) async throws -> Data {
        var urlRequest = apiEndpoint.createURLRequest(for: apiEnvironment)
        
        if config.authToken != "" {
            urlRequest.setValue("Bearer \(config.authToken)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = urlRequest.httpBody {
            print(String(data: body, encoding: .utf8))
        }
        
        
        let (data, _) = try await urlSession.data(for: urlRequest)
        return data
    }
}

public enum BoundaryGenerator {
    case `default`
    public func makeBoundary() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
}

public struct MultipartParameter: HTTPBodyMakable {
    public let parameter: [String: String]
    
    public init(parameter: [String : String]) {
        self.parameter = parameter
    }
    
    func addInto(body: inout Data, boundary: String) {
        parameter.forEach { pair in
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(pair.key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(pair.value)\r\n".data(using: .utf8)!)
            
        }
    }
    
}


public struct FileThatUpload {
     let name: String
     let data: Data?
     let mimeType: String
     let parameterName: String
    
    public init(name: String, data: Data?, mimeType: String, parameterName: String) {
        self.name = name
        self.data = data
        self.mimeType = mimeType
        self.parameterName = parameterName
    }
    
    public func addInto(body: inout Data, boundary: String) {
        guard let data = data else { return }
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(parameterName)\"; filename=\"\(name)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
    }
    
}

