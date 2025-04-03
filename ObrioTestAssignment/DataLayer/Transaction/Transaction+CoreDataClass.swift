//
//  Transaction+CoreDataClass.swift
//  ObrioTestAssignment
//
//  Created by Zakhar Litvinchuk on 01.04.2025.
//
//

import Foundation
import CoreData

@objc(Transaction)
public class Transaction: NSManagedObject {
    convenience init(context: NSManagedObjectContext, model: TransactionModel) {
        self.init(context: context)
        self.date = model.date
        self.type = model.type.rawValue
        self.category = model.category?.rawValue
        self.amount = NSDecimalNumber(decimal: model.amount)
    }
}
