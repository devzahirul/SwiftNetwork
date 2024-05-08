//
//  APIResponse.swift
//  lynkto_retail_iOS
//
//  Created by Hologram1 on 3/20/24.
//

import Foundation

// MARK: - Typealias

/// A Type to confirm both Decodable & Identifiable
public typealias DecodableIdentifiable = Decodable & Identifiable

// MARK: - Meta

/// A model to handle api paging response
public struct Meta: Decodable {
    
    // MARK: - Internal
    
    public let current_page: Int?
    public let last_page: Int?
    public let total: Int?
}

// MARK: - ErrorMessage

/// Decode error message from api response
public struct ErrorMessage: Decodable {
    
    // MARK: - Public
    
    public let message: String
}


// MARK: - ListResponse

/// Decode data list API response
/// This is base response structure for list API Response
/// Generic ``T`` is decodable what is actually a Item model of list response.
/// @Example
///   A api response is like bellow
///   {
///   data: [
///     {name: "", age: "", created_at: ""}
///   ],
///
///}
///Here is name, age, create_at is a model that will pass as ListResponse T
///Here how you will define
///   struct Person: Decodable {
///   let name: String // must be  response key name  & value type must match
///   let age: String
///   let created_at: String
///}
///typealias PersonListResponse = ListResponse<Person>
public struct ListResponse<T: Decodable>: Decodable {
    
    // MARK: - Public
    
    public let data: [T]?
    public let meta: Meta?
    public let error: [ErrorMessage]?
}


// MARK: - DetailsResponse

/// A base struct for handle Details API response
/// Example
/// {data: {name:"", age: "", "create_at": ""}}
/// For handling this type of response
///
///typealias PersonDetailsResponse = DetailsResponse<Person>
public struct DetailsResponse<T: Decodable>: Decodable {
    
    // MARK: - Public
    public let data: T
}

