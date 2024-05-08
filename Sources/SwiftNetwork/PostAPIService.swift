//
//  PostAPIService.swift
//  lynkto_retail_iOS
//
//  Created by Hologram1 on 3/20/24.
//

import Foundation

public protocol PostAPIServiceProtocol {
    associatedtype Parameter: APIParameterable
    associatedtype Response: Decodable
    func send(parameters: [Parameter]) async throws -> Result<Response, Error>
}



public class PostAPIService<P: APIParameterable>: PostAPIServiceProtocol {
    
    private var networkService: NetworkService
    private var endpoint: APIEndPoint_V
    
    public typealias Response = String
    
    public init(
        networkService: NetworkService = URLSessionNetworkService(),
        endpoint: APIEndPoint_V
    ) {
        self.networkService = networkService
        self.endpoint = endpoint
    }
    
    public  func send(parameters: [P]) async throws -> Result<String, Error> {
        return try await callAPI(parameters: parameters)
    }
    private  func callAPI(parameters: [P]) async throws -> Result<String, Error> {
        
        endpoint.method = .POST
        
        parameters.map({$0.pair}).forEach({
            endpoint.parameter?[$0.0] = $0.1
        })
        
        
        let responseData = try await self.networkService.getData(apiEndpoint: endpoint)
        print("ResponseData: \(String(data: responseData, encoding: .utf8))")
        return .success("a")
    }
}


public class DecodablePostAPIService<Response: Decodable, P: APIParameterable>: PostAPIServiceProtocol {
    
    private var networkService: NetworkService
    private var endpoint: APIEndPoint_V
    
    
    
    public init(
        networkService: NetworkService = URLSessionNetworkService(),
        endpoint: APIEndPoint_V
    ) {
        self.networkService = networkService
        self.endpoint = endpoint
    }
    
    public  func send(parameters: [P]) async throws -> Result<Response, Error> {
        return try await callAPI(parameters: parameters)
    }
    private  func callAPI(parameters: [P]) async throws -> Result<Response, Error> {
        
        endpoint.method = .POST
        
        parameters.map({$0.pair}).forEach({
            endpoint.parameter?[$0.0] = $0.1
        })
        
        
        return try await self.networkService.get(apiEndpoint: endpoint)
    }
}
