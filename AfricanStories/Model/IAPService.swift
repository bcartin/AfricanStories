//
//  IAPService.swift
//  AfricanStories
//
//  Created by Bernie Cartin on 1/17/19.
//  Copyright © 2019 garsontech. All rights reserved.
//

import Foundation
import StoreKit

var productsPrice: [String:NSDecimalNumber] = [:]

class IAPService: NSObject {
    
    private override init() {}
    static let shared = IAPService()
    
    var products = [SKProduct]()
    let paymentQueue = SKPaymentQueue.default()
    
    func getBooks(booksSet: Set<String>) {
        let request = SKProductsRequest(productIdentifiers: booksSet)
        request.delegate = self
        request.start()
        paymentQueue.add(self)
    }
    
    func purchaseStory(product: String) {
        guard let productToPurchase = products.filter({ $0.productIdentifier == product }).first else {return}
        let payment = SKPayment(product: productToPurchase)
        paymentQueue.add(payment)
    }
    
    func restorePurchases() {
        paymentQueue.restoreCompletedTransactions()
    }
    
}

extension IAPService: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
        for product in response.products {
            productsPrice[product.productIdentifier] = product.price
            print(product.productIdentifier, product.price)
        }
    }
}

extension IAPService: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            print(transaction.transactionState.status(), transaction.payment.productIdentifier)
            switch transaction.transactionState {
            case .purchasing: break
            case .purchased:
                let storyDict = [C_STORYID:transaction.payment.productIdentifier]
                NotificationCenter.default.post(name: .purchaseSuccesful, object: nil, userInfo: storyDict)
                queue.finishTransaction(transaction)
            case .failed:
                print(transaction.error?.localizedDescription as Any)
                NotificationCenter.default.post(name: .purchaseFailed, object: nil)
                queue.finishTransaction(transaction)
            case .restored:
                let storyDict = [C_STORYID:transaction.payment.productIdentifier]
                NotificationCenter.default.post(name: .purchaseSuccesful, object: nil, userInfo: storyDict)
                queue.finishTransaction(transaction)
            default: queue.finishTransaction(transaction)
            }
            //add logic to download story when purchase is complete
        }
    }
}

extension SKPaymentTransactionState {
    func status() -> String {
        switch self {
        case .deferred: return C_DEFERRED
        case .failed: return C_FAILED
        case .purchased: return C_PURCHASED
        case .purchasing: return C_PURCHASING
        case .restored: return C_RESTORED
        }
    }
}
