//
//  APIParameterable.swift
//  lynkto_retail_iOS
//
//  Created by Hologram1 on 3/20/24.
//

import Foundation

// MARK: - APIParameterable

/// A protocol for provide key-value pair when API needs parameters
/// This used in enum to confirm and return key value pair
/// Then , convert to ``APIEndPoint_V`` parameter
public protocol APIParameterable {
    
    
    // MARK: - Internal
    var pair: (String, String) { get }
}
