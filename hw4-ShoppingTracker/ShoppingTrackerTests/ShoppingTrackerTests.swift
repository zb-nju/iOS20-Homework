//
//  ShoppingTrackerTests.swift
//  ShoppingTrackerTests
//
//  Created by zb-nju on 2020/11/11.
//

import XCTest
@testable import ShoppingTracker

class ShoppingTrackerTests: XCTestCase {
    
    //MARK: Product Class Tests
    //Confirm that the Product initializer returns a Product object when passed valid parameters.
    func testProductInitializationSucceeds(){
        //Zero rating
        let zeroRatingProduct = Product.init(name: "Zero", photo: nil, rating: 0)
        XCTAssertNotNil(zeroRatingProduct)
        
        //Highest positive rating
        let positiveRatingProduct = Product.init(name: "Positive", photo: nil, rating: 5)
        XCTAssertNotNil(positiveRatingProduct)
    }
    
    //Confirm that the Product  initialier returns nil when passed a negative rating or an empty name.
    func testProductInitializationFails(){
        //Negative rating
        let negativeRatingProduct = Product.init(name: "Negative", photo: nil, rating: -1)
        XCTAssertNil(negativeRatingProduct)
        
        //Rating exceeds maximum
        let largeRatingProduct = Product.init(name: "Large", photo: nil, rating: 6)
        XCTAssertNil(largeRatingProduct)
        
        //Empty String
        let emptyStringProduct = Product.init(name: "", photo: nil, rating: 0)
        XCTAssertNil(emptyStringProduct)
    }
}
