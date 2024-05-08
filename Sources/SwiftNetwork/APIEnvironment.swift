//
//  File.swift
//  
//
//  Created by Hologram1 on 12/19/23.
//

import Foundation

// MARK: - APIEnvironment

/// A enum define network environment which is provide base url for app network
/// You can define new environment case if needed
/// in ``baseURL`` return the main api url which will use all network call .
public enum APIEnvironment {
    
    // MARK: - Internal
    
    
    case DEV
    case LIVE
    case TESTING
    case Stripe
    case local
  
    // MARK: - Public
    
    /// Get base url based on environment used current build .
    public var baseURL: String {
      switch self {
          case .DEV:        return "https://retail-api.stylepick.net/api/"
          case .LIVE:       return "https://retail-api.stylepick.net/api/"
          case .TESTING:    return "https://retail-api.stylepick.net/api/"
          case .local:      return "http://192.168.0.111:8000/api/"
          case .Stripe:     return "https://api.stripe.com/v1/"
      }
  }
  
  
  public static var testing: String {
    APIEnvironment.TESTING.baseURL
  }
  
}
