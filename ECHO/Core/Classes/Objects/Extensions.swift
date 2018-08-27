//
//  Extensions.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 17.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

public struct Extensions: ECHOCodable {
    
    enum ExtensionsCodingKeys: String, CodingKey {
        case extensions
    }
    
    fileprivate var extensions = [JSONCodable]()
    
    func size() -> Int {
        return extensions.count
    }
    
    // MARK: ECHOCodable
    
    func toJSON() -> Any? {

        var array = [Any?]()
        extensions.forEach {
            array.append($0.toJSON())
        }
        return array
    }

    func toJSON() -> String? {
        return nil
    }

    func toData() -> Data? {
        return Data(count: 1)
    }
}