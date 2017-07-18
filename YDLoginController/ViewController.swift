//
//  ViewController.swift
//  YDLoginController
//
//  Created by Yuri Doubov on 2017-07-06.
//  Copyright © 2017 Yuri Doubov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	override func viewDidAppear(_ animated: Bool) {
		
		let loginController = YDLoginController.init(nibName: nil, bundle: nil)
		
		// Replace the default background
		loginController.style.imgBackground = #imageLiteral(resourceName: "CustomBackground")
		
		// Replace the default logo
		loginController.style.imgLogo = #imageLiteral(resourceName: "CustomLogo")
		
		// Set the user/password icon tint to orange
		loginController.style.colorIconTint = UIColor.init(red: 234/255, green: 120/255, blue: 37/255, alpha: 1)
		
		self.present(loginController, animated: true, completion: nil)
		
		super.viewDidAppear(animated)
	}

}

