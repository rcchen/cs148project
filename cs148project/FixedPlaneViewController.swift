//
//  FixedPlaneViewController.swift
//  cs148project
//
//  Created by Roger Chen on 8/16/17.
//  Copyright © 2017 Roger Chen. All rights reserved.
//

import UIKit

class FixedPlaneViewController: UIViewController {
    
    @IBAction func endGame(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var bestLabel: UILabel!
}
