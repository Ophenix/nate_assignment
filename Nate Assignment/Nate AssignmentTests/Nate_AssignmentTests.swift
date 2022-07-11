//
//  Nate_AssignmentTests.swift
//  Nate AssignmentTests
//
//  Created by Kalin Spassov on 09/07/2022.
//

import XCTest
@testable import Nate_Assignment

class Nate_AssignmentTests: XCTestCase {
    var productsJson: ProductsModelContainer!
    
    
    override func setUpWithError() throws {
        
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_productsParsing() throws {
        if let url = Bundle(for: type(of: self)).url(forResource: "validPayloadJson", withExtension: "json") {
                do {
                    let data = try Data(contentsOf: url)
                    let decoder = JSONDecoder()
                    let jsonData = try decoder.decode(ProductsModelContainer.self, from: data)
                    productsJson = jsonData
                } catch {
                    print("error:\(error)")
                }
            }
        
        XCTAssertTrue(productsJson != nil, "Failed to parse ProductsModelContainer")
    }
    
    func test_productsParsingNoIdFail() throws {
        if let url = Bundle(for: type(of: self)).url(forResource: "noIdPayloadJson", withExtension: "json") {
                do {
                    let data = try Data(contentsOf: url)
                    let decoder = JSONDecoder()
                    let jsonData = try decoder.decode(ProductsModelContainer.self, from: data)
                    productsJson = jsonData
                } catch {
                    print("error:\(error)")
                }
            }
        
        XCTAssertFalse(productsJson != nil, "Failed to parse ProductsModelContainer")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
