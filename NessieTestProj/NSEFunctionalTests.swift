//
//  NSEFunctionalTests.swift
//  Nessie-iOS-Wrapper
//
//  Created by Mecklenburg, William on 5/19/15.
//  Copyright (c) 2015 Nessie. All rights reserved.
//

import Foundation
import NessieFmwk

class AccountTests {
    let client = NSEClient.sharedInstance

    init() {
        client.setKey("de82890c016c38778c4ffb8fc48847d2")
        testAccountGets()
        testAccountPost()
    }

    func testAccountGets() {
        
        //Test with my key
        
        var getAllRequest = AccountRequest(block: {(builder) in
            builder.requestType = HTTPType.GET
        })
        
        getAllRequest?.send({(result) in
            var accounts = result.getAllAccounts()
            print("Accounts created:\(accounts)\n")
            let accountToGet = accounts![0]
            let accountToUpdateThenDelete = accounts![1]
            self.testAccountGetOne(accountToGet.accountId)
            self.testAccountPutDelete(accountToUpdateThenDelete.accountId)
        })
    }
    
    func testAccountGetOne(identifier:String) {
        var getOneRequest = AccountRequest(block: {(builder) in
            builder.requestType = HTTPType.GET
            builder.accountId = identifier
        })
        
        getOneRequest?.send({(result) in
            var account = result.getAccount()
            print("Account fetched:\(account)\n")
        })
    }
    
    func testAccountPost() {
        var accountPostRequest = AccountRequest(block: {(builder:AccountRequestBuilder) in
            builder.requestType = HTTPType.POST
            builder.accountType = AccountType.SAVINGS
            builder.balance = 100
            builder.nickname = "Madelyn's Savings Account"
            builder.rewards = 20000
            builder.customerId = "55dd3baef8d87732af4687af"
        })
        
        accountPostRequest?.send({(result:AccountResult) in
            //Should not be any result, should NSLog a message in console saying it was successful
        })
    }
    
    func testAccountPutDelete(identifier:String) {
        var accountPutRequest = AccountRequest(block: {(builder:AccountRequestBuilder) in
            builder.requestType = HTTPType.PUT
            builder.accountId = identifier
            builder.nickname = "Victor"
        })
        
        accountPutRequest?.send({(result:AccountResult) in
            //should not be any result
            
            var accountDeleteRequest = AccountRequest(block: {(builder:AccountRequestBuilder) in
                builder.requestType = HTTPType.DELETE
                builder.accountId = identifier
            })
            
            accountDeleteRequest?.send({(result:AccountResult) in
                //no result
            })
        })
    }
}

class ATMTests {
    let client = NSEClient.sharedInstance

    init() {
        client.setKey("de82890c016c38778c4ffb8fc48847d2")

        testATMGetAll()
    }

    func testATMGetAll() {
        var atmGetAllRequest = ATMRequest(block: {(builder:ATMRequestBuilder) in
            builder.requestType = HTTPType.GET
            builder.latitude = 38.9283
            builder.longitude = -77.1753
            builder.radius = "1"
        })
        
        atmGetAllRequest?.send({(result:ATMResult) in
            var atms = result.getAllATMs()
            print("ATMs fetched:\(atms)\n")
            
            var atmToGetID = atms![0].atmId
            var getOneATMRequest = ATMRequest(block: {(builder:ATMRequestBuilder) in
                builder.requestType = HTTPType.GET
                builder.atmId = atmToGetID
            })
            
            getOneATMRequest?.send({(result:ATMResult) in
                var atm = result.getATM()
                print("ATM fetched:\(atm)\n")
            })
        })
        
    }
}

class BillTests {
    let client = NSEClient.sharedInstance
    
    init() {
        client.setKey("de82890c016c38778c4ffb8fc48847d2")

        testGetAllBills()
    }
    
    var accountToAccess:Account!
    var accountToPay:Account!
    
    func testGetAllBills() {
        var getAllRequest = AccountRequest(block: {(builder:AccountRequestBuilder) in
            builder.requestType = HTTPType.GET
        })
        
        getAllRequest?.send({(result:AccountResult) in
            var accounts = result.getAllAccounts()
            self.accountToAccess = accounts![2]
            self.accountToPay = accounts![1]
            self.testPostBill()

            /*********************
            Get bills for customer
            **********************/
            
            BillRequest(block: {(builder:BillRequestBuilder) in
                builder.requestType = HTTPType.GET
                builder.customerId = self.accountToAccess.customerId
            })?.send(completion: {(result:BillResult) in
                var bills = result.getAllBills()
            })

            
            
            //create and then send shortcut
            BillRequest(block: {(builder:BillRequestBuilder) in
                builder.requestType = HTTPType.GET
                builder.accountId = self.accountToAccess.accountId
            })?.send(completion: {(result:BillResult) in
                var bills = result.getAllBills()
                let billToGet = bills![0]
                let billToPutDelete = bills![0]
                /*********************
                Get bill by ID
                **********************/
                self.testGetOneBill(billToGet)
                
                /*********************
                Put bill
                **********************/
                self.testPutBill(billToPutDelete)
            })
            

        })
    }
    
    func testGetOneBill(bill:Bill) {
        BillRequest(block: {(builder:BillRequestBuilder) in
            builder.requestType = HTTPType.GET
            builder.billId = bill.billId
        })?.send(completion: {(result:BillResult) in
            var billresult = result.getBill()
        })
    }
    
    func testPostBill() {
        BillRequest(block: {(builder:BillRequestBuilder) in
            builder.requestType = HTTPType.POST
            builder.status = BillStatus.RECURRING
            builder.accountId = self.accountToAccess.accountId
            builder.recurringDate = 15
            builder.paymentAmount = 10
            builder.payee = self.accountToPay.accountId
            builder.nickname = "bill"
        })?.send(completion: {(result:BillResult) in
            
        })
    }
    
    func testPutBill(bill:Bill) {
        BillRequest(block: {(builder:BillRequestBuilder) in
            builder.billId = bill.billId
            builder.nickname = "newbill"
            builder.requestType = HTTPType.PUT
        })?.send(completion: {(result:BillResult) in
            self.testDeleteBill(bill)
        })
    }
    
    func testDeleteBill(bill:Bill) {
        BillRequest(block: {(builder:BillRequestBuilder) in
            builder.billId = bill.billId
            builder.requestType = HTTPType.DELETE
        })?.send(completion: {(result) in
            
        })
    }
}

class BranchTests {
    let client = NSEClient.sharedInstance

    init() {
        client.setKey("de82890c016c38778c4ffb8fc48847d2")

        testBranchGetAll()
    }
    
    func testBranchGetAll() {
        /*********************
        Get branches
        **********************/
        BranchRequest(block: {(builder:BranchRequestBuilder) in
            builder.requestType = HTTPType.GET
        })?.send({(result:BranchResult) in
            var branches = result.getAllBranches()
            
            var branchToGetID = branches![0].branchId
            /*********************
            Get 1 branch
            **********************/
            BranchRequest(block: {(builder:BranchRequestBuilder) in
                builder.requestType = HTTPType.GET
                builder.branchId = branchToGetID
            })?.send({(result:BranchResult) in
                var branch = result.getBranch()
            })
        })
    }
}

class CustomerTests {
    let client = NSEClient.sharedInstance
    
    init() {
        client.setKey("de82890c016c38778c4ffb8fc48847d2")
        
        testGetAllCustomers()
    }
    
    func testGetAllCustomers() {

        
        
//        self.testPostCustomer()

        /*********************
        Get all customers
        **********************/
        CustomerRequest(block: {(builder:CustomerRequestBuilder) in
            builder.requestType = HTTPType.GET
        })?.send({(result:CustomerResult) in
            var customers = result.getAllCustomers()
            print("Customers fetched:\(customers)\n")
            var customerToGet = customers![3]
            var customerToGetFromAccount = customers![customers!.count-1]
            /*********************
            Get 1 customer
            **********************/
            self.testGetOneCustomer(customerToGet)

            /*********************
            Get customer from account
            **********************/
            self.testGetCustomerFromAccount(customerToGetFromAccount)

            /*********************
            Get accounts from customer
            **********************/
            self.testGetAccountsFromCustomer(customerToGetFromAccount)

            /*********************
            Get put customer
            **********************/
            self.testUpdateCustomer(customerToGet)
        })

    }
    
    func testGetOneCustomer(customer:Customer) {
        CustomerRequest(block: {(builder:CustomerRequestBuilder) in
            builder.requestType = HTTPType.GET
            builder.customerId = customer.customerId
        })?.send({(result:CustomerResult) in
            var customer = result.getCustomer()
            print("Customer fetched:\(customer)\n")
        })
    }

    func testGetCustomerFromAccount(customer:Customer) {
        CustomerRequest(block: {(builder:CustomerRequestBuilder) in
            builder.requestType = HTTPType.GET
            builder.accountId = customer.accountIds?[0]
        })?.send({(result:CustomerResult) in
            var customer = result.getCustomer()
            print("Customer from account fetched:\(customer)\n")
        })
    }

    func testGetAccountsFromCustomer(customer:Customer) {
        AccountRequest(block: {(builder:AccountRequestBuilder) in
            builder.requestType = HTTPType.GET
            builder.customerId = customer.customerId
        })?.send({(result:AccountResult) in
            var accounts = result.getAllAccounts()
            print("Accounts from customer fetched:\(accounts)\n")
        })
    }
    
    func testUpdateCustomer(customer:Customer) {
        CustomerRequest(block: {(builder:CustomerRequestBuilder) in
            builder.requestType = HTTPType.PUT
            builder.customerId = customer.customerId
            builder.address = Address(streetName: "streetname", streetNumber: "123", city: "city", state: "DC", zipCode: "12345")
        })?.send({(result) in
            //no result
        })
    }
    
    func testPostCustomer() {
        CustomerRequest(block: {(builder:CustomerRequestBuilder) in
            builder.requestType = HTTPType.POST
            builder.firstName = "Elliot"
            builder.lastName = "Anderson"
            builder.address = Address(streetName: "streetname", streetNumber: "123", city: "city", state: "DC", zipCode: "12345")
        })?.send({(result) in
            //no result
        })
    }

}

class DepositTests {
    let client = NSEClient.sharedInstance
    
    init() {
        client.setKey("de82890c016c38778c4ffb8fc48847d2")
        
        testGetAllDeposits()
    }
    
    var accountToAccess:Account!
    
    func testGetAllDeposits() {
        
        //get an account
        var getAllRequest = AccountRequest(block: {(builder:AccountRequestBuilder) in
            builder.requestType = HTTPType.GET
        })
        
        getAllRequest?.send({(result:AccountResult) in
            var accounts = result.getAllAccounts()
            self.accountToAccess = accounts![0]
            self.testPostDeposit()
            
            //test get all
        })
    }
    
    func testGetOneDeposit(deposit:Transaction) {
        DepositRequest(block: {(builder:DepositRequestBuilder) in
            builder.requestType = HTTPType.GET
            builder.depositId = deposit.transactionId
        })?.send(completion: {(result:DepositResult) in
            var depositResult = result.getDeposit()
            print(depositResult)
        })
    }
    
    func testPostDeposit() {
        DepositRequest(block: {(builder:DepositRequestBuilder) in
            builder.requestType = HTTPType.POST
            builder.amount = 10
            builder.depositMedium = TransactionMedium.BALANCE
            builder.description = "test"
            builder.accountId = self.accountToAccess.accountId
            
        })?.send(completion: {(result) in
            DepositRequest(block: {(builder:DepositRequestBuilder) in
                builder.requestType = HTTPType.GET
                builder.accountId = self.accountToAccess.accountId
            })?.send(completion: {(result:DepositResult) in
                var deposits = result.getAllDeposits()
                
                if deposits!.count > 0 {
                    let depositToGet = deposits![deposits!.count-1]
                    var depositToDelete:Transaction? = nil;
                    for deposit in deposits! {
                        if deposit.status == "pending" {
                            depositToDelete = deposit
//                            self.testDeleteDeposit(depositToDelete)
                        }
                    }
                    
                    //                    self.testGetOneDeposit(depositToGet)
                                        self.testPutDeposit(depositToDelete)
                    
                }
            })

        })
    }
    
    func testPutDeposit(deposit:Transaction?) {
        
        if (deposit == nil) {
            return
        }
        DepositRequest(block: {(builder:DepositRequestBuilder) in
            builder.depositId = deposit!.transactionId
            println(deposit!.status)
            builder.requestType = HTTPType.PUT
            builder.amount = 4300
            builder.depositMedium = TransactionMedium.REWARDS
            builder.description = "updated"
            
        })?.send(completion: {(result:DepositResult) in
//            self.testDeleteDeposit(deposit!)
        })
    }
    
    func testDeleteDeposit(deposit:Transaction?) {
        DepositRequest(block: {(builder:DepositRequestBuilder) in
            builder.depositId = deposit!.transactionId
            println(deposit!.status)

            builder.requestType = HTTPType.DELETE
            builder.accountId = self.accountToAccess.accountId
        })?.send(completion: {(result) in
            
        })
    }
}

class PurchaseTests {
    let client = NSEClient.sharedInstance
    
    init() {
        client.setKey("de82890c016c38778c4ffb8fc48847d2")
        
        testGetAllPurchases()
    }
    
    var accountToAccess:Account!
    
    func testGetAllPurchases() {
        
        //get an account
        var getAllRequest = AccountRequest(block: {(builder:AccountRequestBuilder) in
            builder.requestType = HTTPType.GET
        })
        
        getAllRequest?.send({(result:AccountResult) in
            var accounts = result.getAllAccounts()
            self.accountToAccess = accounts![0]
            self.testPostPurchase()
            
            //test get all
        })
    }
    
    func testGetOnePurchase(purchase:Transaction) {
        PurchaseRequest(block: {(builder:PurchaseRequestBuilder) in
            builder.requestType = HTTPType.GET
            builder.purchaseId = purchase.transactionId
        })?.send(completion: {(result:PurchaseResult) in
            var purchaseResult = result.getPurchase()
            print(purchaseResult)
        })
    }
    
    func testPostPurchase() {
        PurchaseRequest(block: {(builder:PurchaseRequestBuilder) in
            builder.requestType = HTTPType.POST
            builder.amount = 10
            builder.purchaseMedium = TransactionMedium.BALANCE
            builder.description = "test"
            builder.accountId = self.accountToAccess.accountId
            builder.merchantId = "55e9b7957bf47e14009404f0"
            
        })?.send(completion: {(result) in
            PurchaseRequest(block: {(builder:PurchaseRequestBuilder) in
                builder.requestType = HTTPType.GET
                builder.accountId = self.accountToAccess.accountId
            })?.send(completion: {(result:PurchaseResult) in
                var purchases = result.getAllPurchases()
                
                if purchases!.count > 0 {
                    let purchaseToGet = purchases![purchases!.count-1]
                    var purchaseToDelete:Transaction? = nil;
                    for purchase in purchases! {
                        if purchase.status == "pending" {
                            purchaseToDelete = purchase
//                            self.testDeletePurchase(purchaseToDelete)
                        }
                    }
                    
                    //self.testGetOnePurchase(purchaseToGet)
                    self.testPutPurchase(purchaseToDelete)
                    
                }
            })
            
        })
    }
    
    func testPutPurchase(purchase:Transaction?) {
        
        if (purchase == nil) {
            return
        }
        PurchaseRequest(block: {(builder:PurchaseRequestBuilder) in
            builder.purchaseId = purchase!.transactionId
            println(purchase!.status)
            builder.requestType = HTTPType.PUT
            builder.amount = 4300
            builder.purchaseMedium = TransactionMedium.REWARDS
            builder.description = "updated"
            builder.payerId = "55e94a1af8d877051ab4f6c2"
        })?.send(completion: {(result:PurchaseResult) in
            //            self.testDeletePurchase(purchase!)
        })
    }
    
    func testDeletePurchase(purchase:Transaction?) {
        PurchaseRequest(block: {(builder:PurchaseRequestBuilder) in
            builder.purchaseId = purchase!.transactionId
            println(purchase!.status)
            
            builder.requestType = HTTPType.DELETE
            builder.accountId = self.accountToAccess.accountId
        })?.send(completion: {(result) in
            
        })
    }
}

class TransferTests {
    let client = NSEClient.sharedInstance
    
    init() {
        client.setKey("de82890c016c38778c4ffb8fc48847d2")
        
        testGetAllTransfers()
    }
    
    var accountToAccess:Account!
    
    func testGetAllTransfers() {
        
        //get an account
        var getAllRequest = AccountRequest(block: {(builder:AccountRequestBuilder) in
            builder.requestType = HTTPType.GET
        })
        
        getAllRequest?.send({(result:AccountResult) in
            var accounts = result.getAllAccounts()
            self.accountToAccess = accounts![0]
            self.testPostTransfer()
            
            //test get all
        })
    }
    
    func testGetOneTransfer(transfer:Transfer) {
        TransferRequest(block: {(builder:TransferRequestBuilder) in
            builder.requestType = HTTPType.GET
            builder.transferId = transfer.transferId
        })?.send(completion: {(result:TransferResult) in
            var transferResult = result.getTransfer()
            print(transferResult)
        })
    }
    
    func testPostTransfer() {
        TransferRequest(block: {(builder:TransferRequestBuilder) in
            builder.requestType = HTTPType.POST
            builder.amount = 10
            builder.transferMedium = TransactionMedium.BALANCE
            builder.description = "test"
            builder.accountId = self.accountToAccess.accountId
            builder.payeeId = "55e94a1af8d877051ab4f6c1"
            
        })?.send(completion: {(result) in
            TransferRequest(block: {(builder:TransferRequestBuilder) in
                builder.requestType = HTTPType.GET
                builder.accountId = self.accountToAccess.accountId
            })?.send(completion: {(result:TransferResult) in
                var transfers = result.getAllTransfers()
                
                if transfers!.count > 0 {
                    let transferToGet = transfers![transfers!.count-1]
                    var transferToDelete:Transfer? = nil;
                    for transfer in transfers! {
                        if transfer.status == "pending" {
                            transferToDelete = transfer
                            self.testDeleteTransfer(transferToDelete)
                        }
                    }
                    
                    //self.testGetOneTransfer(transferToGet)
                    //self.testPutTransfer(transferToDelete)
                    
                }
            })
            
        })
    }
    
    func testPutTransfer(transfer:Transfer?) {
        
        if (transfer == nil) {
            return
        }
        TransferRequest(block: {(builder:TransferRequestBuilder) in
            builder.transferId = transfer!.transferId
            println(transfer!.status)
            builder.requestType = HTTPType.PUT
            builder.amount = 4300
            builder.transferMedium = TransactionMedium.REWARDS
            builder.description = "updated"
            builder.payeeId = "55e94a1af8d877051ab4f6c2"
        })?.send(completion: {(result:TransferResult) in
            //            self.testDeleteTransfer(transfer!)
        })
    }
    
    func testDeleteTransfer(transfer:Transfer?) {
        TransferRequest(block: {(builder:TransferRequestBuilder) in
            builder.transferId = transfer!.transferId
            println(transfer!.status)
            
            builder.requestType = HTTPType.DELETE
            builder.accountId = self.accountToAccess.accountId
        })?.send(completion: {(result) in
            
        })
    }
}

class WithdrawalTests {
    let client = NSEClient.sharedInstance
    
    init() {
        client.setKey("de82890c016c38778c4ffb8fc48847d2")
        
        testGetAllWithdrawals()
    }
    
    var accountToAccess:Account!
    
    func testGetAllWithdrawals() {
        
        //get an account
        var getAllRequest = AccountRequest(block: {(builder:AccountRequestBuilder) in
            builder.requestType = HTTPType.GET
        })
        
        getAllRequest?.send({(result:AccountResult) in
            var accounts = result.getAllAccounts()
            self.accountToAccess = accounts![0]
            self.testPostWithdrawal()
            
            //test get all
        })
    }
    
    func testGetOneWithdrawal(withdrawal:Withdrawal) {
        WithdrawalRequest(block: {(builder:WithdrawalRequestBuilder) in
            builder.requestType = HTTPType.GET
            builder.withdrawalId = withdrawal.withdrawalId
        })?.send(completion: {(result:WithdrawalResult) in
            var withdrawalResult = result.getWithdrawal()
            print(withdrawalResult)
        })
    }
    
    func testPostWithdrawal() {
        WithdrawalRequest(block: {(builder:WithdrawalRequestBuilder) in
            builder.requestType = HTTPType.POST
            builder.amount = 10
            builder.withdrawalMedium = TransactionMedium.BALANCE
            builder.description = "test"
            builder.accountId = self.accountToAccess.accountId
            
        })?.send(completion: {(result) in
            WithdrawalRequest(block: {(builder:WithdrawalRequestBuilder) in
                builder.requestType = HTTPType.GET
                builder.accountId = self.accountToAccess.accountId
            })?.send(completion: {(result:WithdrawalResult) in
                var withdrawals = result.getAllWithdrawals()
                
                if withdrawals!.count > 0 {
                    let withdrawalToGet = withdrawals![withdrawals!.count-1]
                    var withdrawalToDelete:Withdrawal? = nil;
                    for withdrawal in withdrawals! {
                        if withdrawal.status == "pending" {
                            withdrawalToDelete = withdrawal
                            //self.testDeleteWithdrawal(withdrawalToDelete)
                        }
                    }
                    
                    //self.testGetOneWithdrawal(withdrawalToGet)
                    self.testPutWithdrawal(withdrawalToDelete)
                    
                }
            })
            
        })
    }
    
    func testPutWithdrawal(withdrawal:Withdrawal?) {
        
        if (withdrawal == nil) {
            return
        }
        WithdrawalRequest(block: {(builder:WithdrawalRequestBuilder) in
            builder.withdrawalId = withdrawal!.withdrawalId
            println(withdrawal!.status)
            builder.requestType = HTTPType.PUT
            builder.amount = 4300
            builder.withdrawalMedium = TransactionMedium.REWARDS
            builder.description = "updated"
        })?.send(completion: {(result:WithdrawalResult) in
            //            self.testDeleteWithdrawal(withdrawal!)
        })
    }
    
    func testDeleteWithdrawal(withdrawal:Withdrawal?) {
        WithdrawalRequest(block: {(builder:WithdrawalRequestBuilder) in
            builder.withdrawalId = withdrawal!.withdrawalId
            println(withdrawal!.status)
            
            builder.requestType = HTTPType.DELETE
            builder.accountId = self.accountToAccess.accountId
        })?.send(completion: {(result) in
            
        })
    }
}

class MerchantTests {
    let client = NSEClient.sharedInstance
    
    init() {
        client.setKey("de82890c016c38778c4ffb8fc48847d2")
        
        testMerchants()
    }
    
    func testMerchants() {
        
        self.testPostMerchant()
        
        var merchantGetAllRequest = MerchantRequest(block: {(builder:MerchantRequestBuilder) in
            builder.requestType = HTTPType.GET
            builder.latitude = 38.9283
            builder.longitude = -77.1753
            builder.radius = "1000"
        })
        
        merchantGetAllRequest?.send({(result:MerchantResult) in
            var merchants = result.getAllMerchants()
            print("Merchants fetched:\(merchants)\n")
            var merchantID = merchants![0].merchantId
            
            self.testPutMerchant(merchants![0])
            
            var getOneMerchantRequest = MerchantRequest(block: {(builder:MerchantRequestBuilder) in
                builder.requestType = HTTPType.GET
                builder.merchantId = merchantID
            })
            
            getOneMerchantRequest?.send({(result:MerchantResult) in
                var merchant = result.getMerchant()
                print("Merchant fetched:\(merchant)\n")
            })
            
        })

    }
    
    func testPutMerchant(merchant:Merchant?) {
        
        if (merchant == nil) {
            return
        }
        MerchantRequest(block: {(builder:MerchantRequestBuilder) in
            builder.merchantId = merchant!.merchantId
            builder.requestType = HTTPType.PUT
            builder.name = "Victorrrrr"
            builder.address = Address(streetName: "1", streetNumber: "1", city: "1", state: "DC", zipCode: "12312")
            builder.latitude = 38.9283
            builder.longitude = -77.1753
            
        })?.send({(result:MerchantResult) in

        })
    }
    
    func testPostMerchant() {
        
        MerchantRequest(block: {(builder:MerchantRequestBuilder) in
            builder.requestType = HTTPType.POST
            builder.name = "Fun Merchant"
            builder.address = Address(streetName: "1", streetNumber: "1", city: "1", state: "DC", zipCode: "12312")
            builder.latitude = 38.9283
            builder.longitude = -77.1753
            
        })?.send({(result:MerchantResult) in
            
        })
    }
}

class TransactionTests {
    let client = NSEClient.sharedInstance
    
    init() {
        client.setKey("de82890c016c38778c4ffb8fc48847d2")
        
        testGetAllTransactions()
    }
    
    var accountToAccess:Account!
    var accountToPay:Account!

    func testGetAllTransactions() {
        
        //get an account
        var getAllRequest = AccountRequest(block: {(builder:AccountRequestBuilder) in
            builder.requestType = HTTPType.GET
        })
        
        getAllRequest?.send({(result:AccountResult) in
            var accounts = result.getAllAccounts()
            self.accountToAccess = accounts![0]
            self.accountToPay = accounts![1]

            self.testPostTransaction()
            
            //test get all
            TransactionRequest(block: {(builder:TransactionRequestBuilder) in
                builder.requestType = HTTPType.GET
                builder.accountId = self.accountToAccess.accountId
            })?.send(completion: {(result:TransactionResult) in
                var transactions = result.getAllTransactions()
                
                let transactionToGet = transactions![0]
                var transactionToDelete:Transaction? = nil;
                for transaction in transactions! {
                    if transaction.status == "pending" {
                        transactionToDelete = transaction
                    }
                }
                
                self.testGetOneTransaction(transactionToGet)
                self.testPutTransaction(transactionToDelete)
                
            })
        })
    }
    
    func testGetOneTransaction(transaction:Transaction) {
        TransactionRequest(block: {(builder:TransactionRequestBuilder) in
            builder.requestType = HTTPType.GET
            builder.accountId = self.accountToAccess.accountId
            builder.transactionId = transaction.transactionId
        })?.send(completion: {(result:TransactionResult) in
            var transactionResult = result.getTransaction()
        })
    }
    
    func testPostTransaction() {
        TransactionRequest(block: {(builder:TransactionRequestBuilder) in
            builder.requestType = HTTPType.POST
            builder.amount = 10
            builder.transactionMedium = TransactionMedium.BALANCE
            builder.description = "test"
            builder.accountId = self.accountToAccess.accountId
            builder.payeeId = self.accountToPay.accountId
        })?.send(completion: {(result) in
            
        })
    }
    
    func testPutTransaction(transaction:Transaction?) {
        
        if (transaction == nil) {
            return
        }
        TransactionRequest(block: {(builder:TransactionRequestBuilder) in
            builder.transactionId = transaction!.transactionId
            println(transaction!.status)
            builder.requestType = HTTPType.PUT
            builder.accountId = self.accountToAccess.accountId
            builder.transactionMedium = TransactionMedium.REWARDS
            builder.description = "updated"
            
        })?.send(completion: {(result:TransactionResult) in
            self.testDeleteTransaction(transaction!)
        })
    }
    
    func testDeleteTransaction(transaction:Transaction) {
        TransactionRequest(block: {(builder:TransactionRequestBuilder) in
            builder.transactionId = transaction.transactionId
            println(transaction.status)
            
            builder.requestType = HTTPType.DELETE
            builder.accountId = self.accountToAccess.accountId
        })?.send(completion: {(result) in
            
        })
    }
}

class EnterpriseTests {
    let client = NSEClient.sharedInstance
    
    init() {
        client.setKey("de82890c016c38778c4ffb8fc48847d2")
        
        testEnterpriseGets()
    }
    
    func testEnterpriseGets() {
        EnterpriseAccountRequest()?.send({(result:AccountResult) in
            var accounts = result.getAllAccounts()
            var bills = 0
            for tmp in accounts! {
                if (tmp.billIds != nil) {
                    bills += tmp.billIds!.count
                }
            }
            EnterpriseAccountRequest(accountId: accounts![0].accountId)?.send({(result:AccountResult) in
                var account = result.getAccount()
            })
        })
        
        EnterpriseBillRequest()?.send({(result:BillResult) in
            var bills = result.getAllBills()
            var x:NSMutableSet = NSMutableSet()
            for bill in bills! {
                x.addObject(bill.billId)
            }
            EnterpriseBillRequest(billId: bills![0].billId)?.send({(result:BillResult) in
                var bill = result.getBill()
            })
        })
        
        EnterpriseCustomerRequest()?.send({(result:CustomerResult) in
            var customers = result.getAllCustomers()
            EnterpriseCustomerRequest(customerId: customers![0].customerId)?.send({(result:CustomerResult) in
                var customer = result.getCustomer()
            })
        })
        
        EnterpriseTransferRequest()?.send({(result:TransferResult) in
            var transfers = result.getAllTransfers()
            print("\(transfers)\n")
            EnterpriseTransferRequest(transactionId: transfers![0].transferId)?.send({(result:TransferResult) in
                var transfer = result.getTransfer()
                print("\(transfer)\n")
            })
        })
        EnterpriseDepositRequest()?.send({(result:DepositResult) in
            var deposits = result.getAllDeposits()
            print("\(deposits)\n")
            EnterpriseDepositRequest(transactionId: deposits![0].transactionId)?.send({(result:DepositResult) in
                var deposit = result.getDeposit()
                print("\(deposit)\n")
            })
        })
        EnterpriseWithdrawalRequest()?.send({(result:WithdrawalResult) in
            var withdrawals = result.getAllWithdrawals()
            print("\(withdrawals)\n")
            EnterpriseWithdrawalRequest(transactionId: withdrawals![0].withdrawalId)?.send({(result:WithdrawalResult) in
                var withdrawal = result.getWithdrawal()
                print("\(withdrawal)\n")
            })
        })
        EnterpriseMerchantRequest()?.send({(result:MerchantResult) in
            var merchants = result.getAllMerchants()
            print("\(merchants)\n")
            EnterpriseMerchantRequest(merchantId: merchants![0].merchantId)?.send({(result:MerchantResult) in
                var merchant = result.getMerchant()
                print("\(merchant)\n")
            })
        })
    }
}


