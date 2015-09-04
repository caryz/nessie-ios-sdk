//
//  Transfer.swift
//  Nessie-iOS-Wrapper
//
//  Created by Lopez Vargas, Victor R. (CONT) on 9/3/15.
//  Copyright (c) 2015 Nessie. All rights reserved.
//

import Foundation
public class TransferRequestBuilder {
    public var requestType: HTTPType?
    public var accountId: String!
    public var payeeId: String!
    
    public var transferMedium: TransactionMedium?
    public var amount: Int?
    public var transferId: String!
    public var description: String?
    public var transferDate: String!
    public var status: String!
}

public class TransferRequest {
    
    private var request:  NSMutableURLRequest?
    private var getsArray: Bool = true
    private var builder: TransferRequestBuilder!
    
    public convenience init?(block: (TransferRequestBuilder -> Void)) {
        let initializingBuilder = TransferRequestBuilder()
        block(initializingBuilder)
        self.init(builder: initializingBuilder)
    }
    
    private init?(builder: TransferRequestBuilder)
    {
        self.builder = builder
        
        if (builder.transferId == nil && (builder.requestType == HTTPType.PUT || builder.requestType == HTTPType.DELETE)) {
            NSLog("PUT/DELETE require a transferId")
            return nil
        }
        
        if ((builder.accountId == nil || builder.payeeId == nil || builder.transferMedium == nil || builder.amount == nil) && builder.requestType == HTTPType.POST) {
            if (builder.accountId == nil) {
                NSLog("POST requires accountId")
            }
            if (builder.transferMedium == nil) {
                NSLog("POST requires transferMedium")
            }
            if (builder.amount == nil) {
                NSLog("POST requires amount")
            }
            if (builder.payeeId == nil) {
                NSLog("POST requires payeeId")
            }
            
            return nil
        }

        if (builder.transferId == nil && builder.requestType == HTTPType.PUT) {
            if (builder.transferId == nil) {
                NSLog("PUT requires transferId")
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
            requestString += "/transfers/\(builder.transferId)?"
            requestString += "key=\(NSEClient.sharedInstance.getKey())"
            return requestString
        }
        
        if (builder.requestType == HTTPType.DELETE) {
            requestString += "/transfers/\(builder.transferId)?"
            requestString += "key=\(NSEClient.sharedInstance.getKey())"
            return requestString
        }
        
        if (builder.accountId != nil) {
            requestString += "/accounts/\(builder.accountId!)/transfers"
        }
        if (builder.transferId != nil) {
            self.getsArray = false
            requestString += "/transfers/\(builder.transferId!)"
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
            params = ["medium":builder.transferMedium!.rawValue, "payee_id":builder.payeeId, "amount":builder.amount!]
            if let description = builder.description {
                params["description"] = description
            }
            if let date = builder.transferDate {
                params["transaction_date"] = date
            }
            if let status = builder.status {
                params["status"] = status
            }
            self.request!.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
            
        }
        if (builder.requestType == HTTPType.PUT) {
            if let medium = builder.transferMedium {
                params["medium"] = medium.rawValue
            }
            if let payeeId = builder.payeeId {
                params["payee_id"] = payeeId
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
    public func send(#completion: ((TransferResult) -> Void)?) {
        
        NSURLSession.sharedSession().dataTaskWithRequest(request!, completionHandler:{(data, response, error) -> Void in
            if error != nil {
                NSLog(error.description)
                return
            }
            if (completion == nil) {
                return
            }
            
            var result = TransferResult(data: data)
            completion!(result)
            
        }).resume()
    }
}


public struct TransferResult {
    private var dataItem:Transaction?
    private var dataArray:Array<Transaction>?
    private init(data:NSData) {
        var parseError: NSError?
        if let parsedObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error:&parseError) as? Array<Dictionary<String,AnyObject>> {
            
            dataArray = []
            dataItem = nil
            for transfer in parsedObject {
                dataArray?.append(Transaction(data: transfer))
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
                NSLog("Transfer delete Successful")
            } else {
                NSLog("Could not parse data: \(datastring)")
            }
        }
    }
    
    public func getTransfer() -> Transaction? {
        if (dataItem == nil) {
            NSLog("No single data item found. If you were intending to get multiple items, try getAllTransfers()");
        }
        return dataItem
    }
    
    public func getAllTransfers() -> Array<Transaction>? {
        if (dataArray == nil) {
            NSLog("No array of data items found. If you were intending to get one single item, try getTransfer()");
        }
        return dataArray
    }
}
