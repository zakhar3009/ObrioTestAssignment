//
//  Date+StartOfDay.swift
//  ObrioTestAssignment
//
//  Created by Zakhar Litvinchuk on 04.04.2025.
//

import Foundation

extension Date {
    func startOfDay() -> Date {
        let calendar = Calendar.current
        return calendar.startOfDay(for: self) 
    }
}
