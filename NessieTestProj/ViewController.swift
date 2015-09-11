//
//  ViewController.swift
//  NessieTestProj
//
//  Created by Mecklenburg, William on 4/20/15.
//  Copyright (c) 2015 Nessie. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Running multiple tests in one pass can cause async issues
        //var test1 = AccountTests()
        //var test2 = ATMTests()
        //var test3 = BillTests()
        //var test4 = BranchTests()
        //var test5 = CustomerTests()
        var test6 = DepositTests()
        //var test7 = PurchaseTests()
        //var test8 = TransferTests()
        //var test9 = WithdrawalTests()
        //var test10 = MerchantTests()
        //var test11 = TransactionTests()
        //var test12 = EnterpriseTests()
    }
}
