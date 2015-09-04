//
//  Purchase.swift
//  Nessie-iOS-Wrapper
//
//  Created by Lopez Vargas, Victor R. (🇲🇽) on 9/3/15.
//  Copyright (c) 2015 Nessie. All rights reserved.
//

import Foundation
public class PurchaseRequestBuilder {
    public var requestType: HTTPType?
    public var accountId: String!
    public var merchantId: String!
    public var payerId: String!
    
    public var purchaseMedium: TransactionMedium?
    public var amount: Int?
    public var purchaseId: String!
    public var description: String?
    public var purchaseDate: String!
    public var status: String!
}

public class PurchaseRequest {
    
    private var request:  NSMutableURLRequest?
    private var getsArray: Bool = true
    private var builder: PurchaseRequestBuilder!
    
    public convenience init?(block: (PurchaseRequestBuilder -> Void)) {
        let initializingBuilder = PurchaseRequestBuilder()
        block(initializingBuilder)
        self.init(builder: initializingBuilder)
    }
    
    private init?(builder: PurchaseRequestBuilder)
    {
        self.builder = builder
        
        if (builder.purchaseId == nil && (builder.requestType == HTTPType.PUT || builder.requestType == HTTPType.DELETE)) {
            NSLog("PUT/DELETE require a deposit id")
            return nil
        }
        
        if ((builder.accountId == nil || builder.merchantId == nil || builder.amount == nil || builder.purchaseMedium == nil) && builder.requestType == HTTPType.POST) {
            if (builder.accountId == nil) {
                NSLog("POST requires accountId")
            }
            if (builder.merchantId == nil) {
                NSLog("POST requires merchantId")
            }
            if (builder.amount == nil) {
                NSLog("POST requires amount")
            }
            if (builder.purchaseMedium == nil) {
                NSLog("POST requires purchaseMedium")
            }
            
            return nil
        }

        if (builder.purchaseId == nil && builder.requestType == HTTPType.PUT) {
            if (builder.purchaseId == nil) {
                NSLog("PUT requires merchant_Id")
            }
            
            return nil
        }
        
        var requestString = buildRequestUrl()
        print("\(requestString)\n")
        buildRequest(requestString)
        
    }
    
    //Methods for building the request.
    
    private func buildRequestUrl() -> String {
        var requestString = "\(baseString)"
        
        if (builder.requestType == HTTPType.PUT) {
            requestString += "/purchases/\(builder.purchaseId)?"
            requestString += "key=\(NSEClient.sharedInstance.getKey())"
            return requestString
        }
        
        if (builder.requestType == HTTPType.DELETE) {
            requestString += "/purchases/\(builder.purchaseId)?"
            requestString += "key=\(NSEClient.sharedInstance.getKey())"
            return requestString
        }
        
        if (builder.accountId != nil) {
            requestString += "/accounts/\(builder.accountId!)/purchases"
        }
        if (builder.purchaseId != nil) {
            self.getsArray = false
            requestString += "/purchases/\(builder.purchaseId!)"
        }
        requestString += "?key=\(NSEClient.sharedInstance.getKey())"
        return requestString
    }
    
    private func buildRequest(url: String) -> NSMutableURLRequest {
        self.request = NSMutableURLRequest(URL: NSURL(string: url)!)
        self.request!.HTTPMethod = builder.requestType!.rawValue
        
        addParamsToRequest();
        
        self.request!.setValue("application/json", forHTTPHeaderField: "content-type")
        
        return request!
    }
    
    private func addParamsToRequest() {
        var params:Dictionary<String, AnyObject> = [:]
        var err: NSError?
        
        if (builder.requestType == HTTPType.POST) {
            
            params = ["merchant_id":builder.merchantId, "medium":builder.purchaseMedium!.rawValue, "amount":builder.amount!]
            if let description = builder.description {
                params["description"] = description
            }
            if let date = builder.purchaseDate {
                params["purchase_date"] = date
            }
            if let status = builder.status {
                params["status"] = status
            }
            self.request!.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
            
        }
        if (builder.requestType == HTTPType.PUT) {
            if let payerId = builder.payerId {
                params["payer_id"] = payerId
            }
            if let medium = builder.purchaseMedium {
                params["medium"] = medium.rawValue
            }
            if let amount = builder.amount {
                params["amount"] = amount
            }
            if let description = builder.description {
                params["description"] = description
            }
            self.request!.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        }
    }
    
    
    //Sending the request
    public func send(#completion: ((PurchaseResult) -> Void)?) {
        
        NSURLSession.sharedSession().dataTaskWithRequest(request!, completionHandler:{(data, response, error) -> Void in
            if error != nil {
                NSLog(error.description)
                return
            }
            if (completion == nil) {
                return
            }
            
            var result = PurchaseResult(data: data)
            completion!(result)
            
        }).resume()
    }
}


public struct PurchaseResult {
    private var dataItem:Transaction?
    private var dataArray:Array<Transaction>?
    private init(data:NSData) {
        var parseError: NSError?
        if let parsedObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error:&parseError) as? Array<Dictionary<String,AnyObject>> {
            
            dataArray = []
            dataItem = nil
            for purchase in parsedObject {
                dataArray?.append(Transaction(data: purchase))
            }
        }
        if let parsedObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error:&parseError) as? Dictionary<String,AnyObject> {
            dataArray = nil
            
            //If there is an error message, the json will parse to a dictionary, not an array
            if let message:AnyObject = parsedObject["message"] {
                NSLog(message.description!)
                if let reason:AnyObject = parsedObject["culprit"] {
                    NSLog("Reasons:\(reason.description)")
                    return
                } else {
                    return
                }
            }
            
            dataItem = Transaction(data: parsedObject)
        }
        
        if (dataItem == nil && dataArray == nil) {
            var datastring = NSString(data: data, encoding: NSUTF8StringEncoding)
            if (data.description == "<>") {
                NSLog("Purchase delete Successful")
            } else {
                NSLog("Could not parse data: \(datastring)")
            }
        }
    }
    
    public func getPurchase() -> Transaction? {
        if (dataItem == nil) {
            NSLog("No single data item found. If you were intending to get multiple items, try getAllPurchases()");
        }
        return dataItem
    }
    
    public func getAllPurchases() -> Array<Transaction>? {
        if (dataArray == nil) {
            NSLog("No array of data items found. If you were intending to get one single item, try getPurchase()");
        }
        return dataArray
    }
}
