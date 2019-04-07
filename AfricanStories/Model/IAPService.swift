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
var productCurrencySymbol: String = "$"

class IAPService: NSObject {
    
    private override init() {}
    static let shared = IAPService()
    let dispatchGroup = DispatchGroup()
    
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
        if !response.products.isEmpty {
            productCurrencySymbol = response.products[0].priceLocale.currencySymbol ?? "$"
        }
        for product in response.products {
            productsPrice[product.productIdentifier] = product.price
        }
    }
}

extension IAPService: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        if transactions.isEmpty {
            NotificationCenter.default.post(name: .purchaseSuccesful, object: nil, userInfo: nil)
        }
        else {
            for transaction in transactions {
                print(transaction.transactionState.status(), transaction.payment.productIdentifier)
                switch transaction.transactionState {
                case .purchasing: break
                case .purchased:
                    let storyId = transaction.payment.productIdentifier
                    downloadStoryPages(of: storyId)
                    notifyDownloadComplete()
                    queue.finishTransaction(transaction)
                case .failed:
                    print(transaction.error?.localizedDescription as Any)
                    NotificationCenter.default.post(name: .purchaseFailed, object: nil)
                    queue.finishTransaction(transaction)
                case .restored:
                    let storyId = transaction.payment.productIdentifier
                    downloadStoryPages(of: storyId)
                    notifyDownloadComplete()
                    queue.finishTransaction(transaction)
                default: queue.finishTransaction(transaction)
                }
            }
        }
    }
    
    fileprivate func downloadStoryPages(of storyId: String) {
        let content = DataService.shared.getStoryContent(from: storyId)
        content.forEach { (story) in
            dispatchGroup.enter()
            DataService.shared.downloadStoryPages(of: story) { (error) in
                self.dispatchGroup.leave()
            }
        }
    }
    
    fileprivate func notifyDownloadComplete() {
        dispatchGroup.notify(queue: .main) {
            NotificationCenter.default.post(name: .purchaseSuccesful, object: nil, userInfo: nil)
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
