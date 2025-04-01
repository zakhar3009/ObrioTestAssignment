//
//  CurrencyRate+CoreDataClass.swift
//  ObrioTestAssignment
//
//  Created by Zakhar Litvinchuk on 01.04.2025.
//
//

import Foundation
import CoreData

@objc(CurrencyRate)
public class CurrencyRate: NSManagedObject {
    convenience init(context: NSManagedObjectContext, model: CurrencyRateModel) {
        self.init(context: context)
        self.rate = NSDecimalNumber(decimal: model.rate)
        self.lastUpdate = model.lastUpdate
    }
}
