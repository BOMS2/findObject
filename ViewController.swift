//
//  ViewController.swift
//  FindFingerprint
//
//  Created by 김삼복 on 14/06/2019.
//  Copyright © 2019 김삼복. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    @IBOutlet var gifview: UIImageView!
    
    @IBAction func unwindToRootViewController(segue: UIStoryboardSegue) {
        print("Unwind to Root View Controller")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gifview.loadGif(name: "40")
              
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}


