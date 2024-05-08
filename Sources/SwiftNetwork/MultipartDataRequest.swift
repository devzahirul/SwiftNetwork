//
//  File.swift
//  
//
//  Created by Hologram1 on 12/20/23.
//

import Foundation




public protocol HTTPBodyMakable {
    var parameter: [String: String] { get }
 
}


extension HTTPBodyMakable {
 public func makeToData() throws -> Data  {
      try JSONSerialization.data(withJSONObject: parameter, options: [.prettyPrinted])
   }
   
   func convertToURLQueryItems() -> [URLQueryItem] {
     parameter.map({
       URLQueryItem(name: $0.key, value: $0.value)
     })
   }
   
   
   var isNotEmpty: Bool {
     !parameter.isEmpty
   }
   
}



