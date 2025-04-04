//
//  Wallet+CoreDataClass.swift
//  ObrioTestAssignment
//
//  Created by Zakhar Litvinchuk on 01.04.2025.
//
//

import Foundation
import CoreData

@objc(Wallet)
public class Wallet: NSManagedObject {
    convenience init(context: NSManagedObjectContext, model: WalletModel) {
        self.init(context: context)
        self.walletId = model.walletId
        self.balance = NSDecimalNumber(decimal: model.balance)
        self.transactions = NSSet(array: model.transactions) 
    }
}
