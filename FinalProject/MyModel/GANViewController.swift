//
//  GANViewController.swift
//  FinalProject
//
//  Created by Yirun Zhao on 2020/5/5.
//  Copyright © 2020 Yirun Zhao. All rights reserved.
//

import UIKit

class GANViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBOutlet weak var digits: GanView!
    @IBAction func generate(_ sender: Any) {
        digits.setNeedsDisplay()
    }
    
}
