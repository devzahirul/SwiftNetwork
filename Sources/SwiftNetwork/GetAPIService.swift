//
//  GetAPIService.swift
//  lynkto_retail_iOS
//
//  Created by Hologram1 on 3/20/24.
//

import Foundation

// MARK: - GetAPIServiceProtocol

/// A protocol for handle Get API call and pagination & filters .
public protocol GetAPIServiceProtocol {
    
    // MARK: - Internal
    
    /// A associatedtype which is must be decodable.
    associatedtype Response: Decodable
    
    /// Call fetch if get api has no parameters.
    func fetch() async throws -> Result<Response, Error>
    
    /// Call fetch api with parameters. you can use ``APIParameterable``
    /// Then call key-value, then pass dic parameters
    func fetch(parameters: [String: String]) async throws -> Result<Response, Error>
    
    /// Call fetch with append path like a path getAddress
    /// Then can add additional path getAddress/{id}.
    func fetch(appendPaths: [String]) async throws -> Result<Response, Error>
    
    /// Call if has pagination .
    /// You will get pagination info in ``Meta`` model in ``ListResponse``
    /// Handle the condition from upper view model .
    func addPage(number: Int)
}


// MARK: - GetAPIService

/// Concrete class for handling Get API request with parameters, path & paginations.
 public final class GetAPIService<Response: Decodable>: GetAPIServiceProtocol {
    
     // MARK: - Private
     private var networkService: NetworkService
     private var endpoint: APIEndPoint_V
     private var basePath: String
    
     // MARK: - LifeCycle
     
     public init(
        networkService: NetworkService = URLSessionNetworkService(),
        endpoint: APIEndPoint_V
    ) {
        self.networkService = networkService
        self.endpoint = endpoint
        self.basePath = self.endpoint.path
    }
    
     // MARK: - Public
     
     /// fetch
     public func fetch() async throws -> Result<Response, Error> {
        do {
            return try await self.networkService.get(apiEndpoint: endpoint)
        } catch {
            print("Error Decoding: \(error.localizedDescription)")
        }
        throw DecodeErrorApp.decodableError
    }
     
    
     /// fetch with parameters
    public func fetch(parameters: [String : String]) async throws -> Result<Response, Error> {
        parameters.forEach {
            self.endpoint.parameter?[$0.key] = $0.value
        }
        return try await fetch()
    }
    
     /// fetch with append path
     public func fetch(appendPaths: [String]) async throws -> Result<Response, Error> {
        var currentPath = self.basePath
        
        appendPaths.forEach {
            currentPath += $0
        }
        self.endpoint.path = currentPath
        return try await fetch()
    }
    
     /// addPage then fetch
    public func addPage(number: Int) {
        self.endpoint.parameter?["page"] = "\(number)"
        self.endpoint.parameter?["per_page"] = "10"
    }
}
