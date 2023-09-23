//
//  MainViewController.swift
//  MiBand5
//
//  Created by Aitor Zubizarreta on 2023-09-22.
//

import UIKit

class MainViewController: UIViewController {

    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bleManager = BLEManager.shared
        
        bleManager.startScanning()
    }
    
}
