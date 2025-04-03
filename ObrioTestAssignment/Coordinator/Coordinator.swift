//
//  Coordinator.swift
//  ObrioTestAssignment
//
//  Created by Zakhar Litvinchuk on 03.04.2025.
//

import UIKit

protocol Coordinator {
    var navigationController: UINavigationController { get set }
    func start()
}
