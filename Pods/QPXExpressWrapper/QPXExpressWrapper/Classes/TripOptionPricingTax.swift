//
//  TripOptionPricingTax.swift
//  Flights
//
//  Created by Kyle Yoon on 3/5/16.
//  Copyright © 2016 Kyle Yoon. All rights reserved.
//

import Foundation
import Gloss

public struct TripOptionPricingTax: Decodable {
    
    public let kind: String
    public let identifier: String?
    public let chargeType: String?
    public let code: String?
    public let country: String?
    public let salePrice: String?
    
    public init?(json: JSON) {
        guard let kind: String = "kind" <~~ json else {
            return nil
        }
        self.kind = kind
        self.identifier = "id" <~~ json
        self.chargeType = "chargeType" <~~ json
        self.code = "code" <~~ json
        self.country = "country" <~~ json
        self.salePrice = "salePrice" <~~ json
    }

}

extension TripOptionPricingTax: Equatable {}

public func ==(lhs: TripOptionPricingTax, rhs: TripOptionPricingTax) -> Bool {
    return lhs.kind == rhs.kind &&
        lhs.identifier == rhs.identifier &&
        lhs.chargeType == rhs.chargeType &&
        lhs.code == rhs.code &&
        lhs.country == rhs.country &&
        lhs.salePrice == rhs.salePrice
}
