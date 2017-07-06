//
//  YDLoginController.swift
//  YDLoginController
//
//  Created by Yuri Doubov on 03 April 2017.
//  Copyright © 2017 Yuri Doubov. All rights reserved.
//

import UIKit
import LocalAuthentication
import Security

// MARK: - YDLoginControllerDelegate
public protocol YDLoginControllerDelegate: class {
	func login(withUsername username: String, andPassword password: String)
	func signup(withUsername username: String, andPassword password: String)
	func forgotPassword(withEmail email: String)
	func aboutTapped()
}

public struct YDLoginControllerStyle {
	
	/** The styling to be applied to the buttons. 
		- Subtle only applies the text color and font styles to the buttons. 
		- Standout also applies background and border styles. */
	public enum YDButtonStyle {
		case subtle
		case standout
	}
	
	/** Default styles applied to buttons */
	public var styleLoginButton = YDButtonStyle.standout
	public var styleSignupButton = YDButtonStyle.subtle
	public var styleForgotPasswordButton = YDButtonStyle.standout
	public var styleAboutButton = YDButtonStyle.subtle
	
	/** The color for highlighting UITextFields when an input is invalid */
	public var colorInvalidTextField: UIColor = UIColor.init(colorLiteralRed: 0.7, green: 0, blue: 0, alpha: 0.5)
	
	/** The color for highlighting UITextFields in normal state */
	public var colorValidTextField: UIColor = UIColor.init(colorLiteralRed: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
	
	/** The color for the username and password icon tint */
	public var colorIconTint: UIColor = UIColor.white
	
	/** The image to be used for the background, try to preserve the aspect ratio of 9:16 */
	public var imgBackground: UIImage = UIImage.init(named: "backgroundPlaceholder", in: Bundle.init(for: YDLoginController.self), compatibleWith: nil)!
	
	/** The image to be used for the logo, try to preserve the aspect ratio of 5:4 */
	public var imgLogo: UIImage = UIImage.init(named: "logoPlaceholder", in: Bundle.init(for: YDLoginController.self), compatibleWith: nil)!
	
	/** The color for the button normal state */
	public var colorButtonText: UIColor = UIColor.white
	
	/** The color for the button disabled state */
	public var colorButtonTextDisabled: UIColor = UIColor.gray
	
	/** The font to be used for button text */
	public var fontButton: UIFont = UIFont(name: "Avenir-Medium", size: 16)!
	
	/** The color for the textfield text */
	public var colorTextFieldText: UIColor = UIColor.white
	
	/** The color for the textfield placeholder text */
	public var colorTextFieldPlaceholderText: UIColor = UIColor.init(colorLiteralRed: 0.5, green: 0.5, blue: 0.5, alpha: 0.7)
	
	/** The font to be used for textfields text & placeholder */
	public var fontTextField: UIFont = UIFont(name: "Avenir-Medium", size: 16)!
	
	/* If the button style is "standout", apply this background color to all buttons */
	public var buttonBackgroundColor: UIColor = UIColor.black.withAlphaComponent(0.5)
	
	/* If the button style is "standout", apply this border width to all buttons */
	public var buttonBorderWidth: CGFloat = 1
	
	/** The height of the username and password textfields */
	public var textFieldHeight: CGFloat = 44
}

extension UITextField {
	func animatePop() -> Void {
		let originalFrame = self.frame
		UIView.animate(withDuration: 0.15, animations: {
			self.frame = CGRect(x: originalFrame.origin.x - originalFrame.size.width*0.02,
			                    y: originalFrame.origin.y - originalFrame.size.height*0.02,
			                    width: originalFrame.size.width*1.04,
			                    height: originalFrame.size.height*1.04)
		}) { _ in
			UIView.animate(withDuration: 0.15, animations: {
				self.frame = originalFrame
			})
		}
	}
}

extension YDLoginController : UITextFieldDelegate {
	// MARK: - UITextFieldDelegate
	public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField == _txtUsername {
			_txtPassword.becomeFirstResponder()
			return true
		}
		
		self.backgroundTapped(self.view)
		self.loginTapped(_btnLogin)
		return true
	}
	
	@objc @discardableResult fileprivate func validateFields(_ forceValidation:Bool = false) -> Bool {
		
		if let username = _txtUsername.text, let password = _txtPassword.text {
			if username.characters.count > 0 && password.characters.count > 0 {
				_txtUsername.backgroundColor = style.colorValidTextField
				_txtPassword.backgroundColor = style.colorValidTextField
				_btnLogin.isEnabled = true
				return true
			}
		}
		
		if !forceValidation {
			return false
		}
		
		if _txtUsername.text?.characters.count == 0 {
			_txtUsername.animatePop()
			_txtUsername.backgroundColor = style.colorInvalidTextField
		}
		else {
			_txtUsername.backgroundColor = style.colorValidTextField
		}
		
		if _txtPassword.text?.characters.count == 0 {
			_txtPassword.animatePop()
			_txtPassword.backgroundColor = style.colorInvalidTextField
		}
		else {
			_txtPassword.backgroundColor = style.colorValidTextField
		}
		
		return false
	}
}

// MARK: - YDLoginController
open class YDLoginController: UIViewController {

	public var delegate: YDLoginControllerDelegate?
	
	public var style: YDLoginControllerStyle = YDLoginControllerStyle()
	
	/** The information text to be displayed in case of a login failure, passing nil hides the field */
	public var infoText:String? {
		set {
			if let `infoText` = newValue {
				_lblInfo.text = infoText
				_lblInfo.isHidden = false
			}
			else {
				_lblInfo.text = nil
				_lblInfo.isHidden = true
			}
		}
		get {
			return _lblInfo.text
		}
	}
	
	fileprivate var _lblInfo: UILabel!
	fileprivate var _txtUsername: UITextField!
	fileprivate var _txtPassword: UITextField!
	fileprivate var _imgvUsernameIcon: UIImageView!
	fileprivate var _imgvPasswordIcon: UIImageView!
	fileprivate var _imgvLogo: UIImageView!
	fileprivate var _imgvBackground: UIImageView!
	fileprivate var _btnLogin: UIButton!
	fileprivate var _btnSignup: UIButton!
	fileprivate var _btnForgotPassword: UIButton!
	fileprivate var _btnAbout: UIButton!

	// MARK: Initialization
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		initialize()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		initialize()
	}
	
	private func initialize() {
		_lblInfo = UILabel.init()
		_lblInfo.textColor = UIColor.red
		_lblInfo.numberOfLines = 2
		_lblInfo.lineBreakMode = .byTruncatingTail
		_lblInfo.font = UIFont.boldSystemFont(ofSize: 15)
		_lblInfo.textAlignment = .center
		
		_txtUsername = UITextField.init()
		_txtUsername.delegate = self
		_txtUsername.returnKeyType = .next
		_txtUsername.autocorrectionType = .no
		_txtUsername.autocapitalizationType = .none
		_txtUsername.clearButtonMode = .always
		_txtUsername.keyboardType = .emailAddress
		
		_txtPassword = UITextField.init()
		_txtPassword.delegate = self
		_txtPassword.returnKeyType = .send
		_txtPassword.isSecureTextEntry = true
		_txtPassword.autocorrectionType = .no
		_txtPassword.clearButtonMode = .always
		_txtPassword.autocapitalizationType = .none
		
		NotificationCenter.default.addObserver(self, selector: #selector(validateFields), name: .UITextFieldTextDidChange, object: nil)
		
		let bundle = Bundle.init(for: YDLoginController.self)
		
		_imgvUsernameIcon = UIImageView.init(image: UIImage.init(named: "usernameIcon", in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate))
		_imgvPasswordIcon = UIImageView.init(image: UIImage.init(named: "passwordIcon", in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate))
		
		_imgvLogo = UIImageView.init()
		_imgvLogo.contentMode = .scaleAspectFit
		
		_imgvBackground = UIImageView.init()
		_imgvBackground.contentMode = .scaleAspectFill
		_imgvBackground.isUserInteractionEnabled = true
		
		let tapGR = UITapGestureRecognizer.init(target: self,
		                                        action: #selector(backgroundTapped(_:)))
		_imgvBackground.addGestureRecognizer(tapGR)
		
		_btnAbout = UIButton.init(type: .custom)
		self.applyStyle(self.style.styleAboutButton, toButton: _btnAbout)
		_btnLogin = UIButton.init(type: .custom)
		self.applyStyle(self.style.styleLoginButton, toButton: _btnLogin)
		_btnSignup = UIButton.init(type: .custom)
		self.applyStyle(self.style.styleSignupButton, toButton: _btnSignup)
		_btnForgotPassword = UIButton.init(type: .custom)
		self.applyStyle(self.style.styleForgotPasswordButton, toButton: _btnForgotPassword)
	}
	
	// MARK: - View lifecycle
    override open func viewDidLoad() {
        super.viewDidLoad()
		
		// Keep background as the first view
		self.view.addSubview(_imgvBackground)
		
		// Now all the other views
		self.view.addSubview(_lblInfo)
		self.view.addSubview(_txtUsername)
		self.view.addSubview(_txtPassword)
		self.view.addSubview(_imgvLogo)
		self.view.addSubview(_btnForgotPassword)
		self.view.addSubview(_btnSignup)
		self.view.addSubview(_btnLogin)
		self.view.addSubview(_btnAbout)
		self.view.addSubview(_imgvUsernameIcon)
		self.view.addSubview(_imgvPasswordIcon)
		
		// Apply the style elements
		_imgvLogo.image = style.imgLogo
		_imgvBackground.image = style.imgBackground
		_txtUsername.backgroundColor = style.colorValidTextField
		_txtPassword.backgroundColor = style.colorValidTextField
		
		// Backgrounds for icons
		_imgvUsernameIcon.tintColor = style.colorIconTint
		_imgvPasswordIcon.tintColor = style.colorIconTint
		
		let buttonAttr:[String:Any] = [NSFontAttributeName : style.fontButton,
		                               NSForegroundColorAttributeName : style.colorButtonText]
		
		let disabledButtonAttr:[String:Any] = [NSFontAttributeName : style.fontButton,
		                                       NSForegroundColorAttributeName : style.colorButtonTextDisabled]
		
		_btnLogin.setAttributedTitle(NSAttributedString.init(string: "Login", attributes: buttonAttr), for: .normal)
		_btnLogin.setAttributedTitle(NSAttributedString.init(string: "Login", attributes: disabledButtonAttr), for: .disabled)
		_btnSignup.setAttributedTitle(NSAttributedString.init(string: "Don't have an account yet? Sign up.", attributes: buttonAttr), for: .normal)
		_btnForgotPassword.setAttributedTitle(NSAttributedString.init(string: "Forgot password?", attributes: buttonAttr), for: .normal)
		_btnAbout.setAttributedTitle(NSAttributedString.init(string: "About", attributes: buttonAttr), for: .normal)
		
		let textFieldAttr:[String:Any] = [NSFontAttributeName : style.fontTextField,
		                                  NSForegroundColorAttributeName : style.colorTextFieldText]
		let textFieldPlcAttr:[String:Any] = [NSFontAttributeName : style.fontTextField,
		                                     NSForegroundColorAttributeName : style.colorTextFieldPlaceholderText]
		
		_txtUsername.attributedPlaceholder = NSAttributedString.init(string: "username", attributes: textFieldPlcAttr)
		_txtPassword.attributedPlaceholder = NSAttributedString.init(string: "password", attributes: textFieldPlcAttr)
		
		_txtUsername.defaultTextAttributes = textFieldAttr
		_txtPassword.defaultTextAttributes = textFieldAttr
		
		// Set these for autolayout
		_imgvBackground.translatesAutoresizingMaskIntoConstraints = false
		_lblInfo.translatesAutoresizingMaskIntoConstraints = false
		_txtPassword.translatesAutoresizingMaskIntoConstraints = false
		_txtUsername.translatesAutoresizingMaskIntoConstraints = false
		_imgvLogo.translatesAutoresizingMaskIntoConstraints = false
		_btnForgotPassword.translatesAutoresizingMaskIntoConstraints = false
		_btnSignup.translatesAutoresizingMaskIntoConstraints = false
		_imgvUsernameIcon.translatesAutoresizingMaskIntoConstraints = false
		_imgvPasswordIcon.translatesAutoresizingMaskIntoConstraints = false
		_btnLogin.translatesAutoresizingMaskIntoConstraints = false
		_btnAbout.translatesAutoresizingMaskIntoConstraints = false
		
		// Button actions
		_btnLogin.addTarget(self, action: #selector(loginTapped(_:)), for: .touchUpInside)
		_btnSignup.addTarget(self, action: #selector(signupTapped(_:)), for: .touchUpInside)
		_btnForgotPassword.addTarget(self, action: #selector(forgotPasswordTapped(_:)), for: .touchUpInside)
		_btnAbout.addTarget(self, action: #selector(aboutTapped(_:)), for: .touchUpInside)
		
		// Hide unused buttons
		_btnSignup.isHidden = true
		_btnForgotPassword.isHidden = true
		
		// Disable the login button by default
		_btnLogin.isEnabled = false
		
		// Layout the constraints
		self.setConstraints()
    }
	
	// MARK: - Interface actions
	@objc fileprivate func backgroundTapped(_ sender:Any) {
		self.view.endEditing(true)
	}
	
	@objc fileprivate func loginTapped(_ sender:UIButton) {
		
		if self.validateFields(true) {
			
			// Login
			self.delegate?.login(withUsername: _txtUsername.text!, andPassword: _txtPassword.text!)
		}
	}	
	
	@objc fileprivate func signupTapped(_ sender: UIButton) {
		
		if let username = _txtUsername.text, let password = _txtPassword.text {
			self.delegate?.signup(withUsername: username, andPassword: password)
		}
	}
	
	@objc fileprivate func forgotPasswordTapped(_ sender: UIButton) {
		
		if let username = _txtUsername.text, let password = _txtPassword.text {
			self.delegate?.signup(withUsername: username, andPassword: password)
		}
	}
	
	@objc fileprivate func aboutTapped(_ sender: UIButton) {
		self.delegate?.aboutTapped()
	}
	
	// MARK: - Private methods
	
	private func applyStyle(_ style: YDLoginControllerStyle.YDButtonStyle, toButton button: UIButton) {
		if style == .standout {
			button.layer.cornerRadius = 5
			button.layer.borderWidth = self.style.buttonBorderWidth
			button.backgroundColor = self.style.buttonBackgroundColor
			button.layer.borderColor = self.style.colorButtonText.cgColor
		}
	}
	
	private func setConstraints() {
		let views:[String:UIView] = ["view" : self.view,
		                             "_lblInfo" : _lblInfo,
		                             "_txtUsername" : _txtUsername,
		                             "_txtPassword" : _txtPassword,
		                             "_imgvBackground" : _imgvBackground,
		                             "_imgvLogo" : _imgvLogo,
		                             "_imgvUsernameIcon" : _imgvUsernameIcon,
		                             "_imgvPasswordIcon" : _imgvPasswordIcon,
		                             "_btnForgotPassword" : _btnForgotPassword,
		                             "_btnLogin" : _btnLogin,
		                             "_btnSignup" : _btnSignup,
		                             "_btnAbout": _btnAbout]
		
		// Stretch background
		self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[_imgvBackground]-(0)-|", options: .directionLeadingToTrailing, metrics: nil, views: views))
		self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[_imgvBackground]-(0)-|", options: .directionLeadingToTrailing, metrics: nil, views: views))
		
		// Logo image left and right spacing >=20
		self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(>=20)-[_imgvLogo]-(>=20)-|", options: .directionLeadingToTrailing, metrics: nil, views: views))
		
		// Logo height <= 150
		_imgvLogo.addConstraint(NSLayoutConstraint.init(item: _imgvLogo, attribute: .height, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 150))
		
		// Align logo center X to main view
		self.view.addConstraint(NSLayoutConstraint.init(item: _imgvLogo, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0))
		
		// VERTICAL 44 - LOGO - INFO - USERNAME - PASSWORD - LOGIN - FORGOT PASSWORD
		self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(44)-[_imgvLogo]-(8)-[_lblInfo]-(4)-[_txtUsername]-(8)-[_txtPassword]-(8)-[_btnLogin]-(8)-[_btnForgotPassword]", options: .directionLeadingToTrailing, metrics: nil, views: views))
		
		// Info label left and right spacing 20
		self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[_lblInfo]-(20)-|", options: .directionLeadingToTrailing, metrics: nil, views: views))
		
		// 20 - PASSWORD ICON - PASSWORD FIELD - 20
		self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[_imgvPasswordIcon]-(4)-[_txtPassword]-(20)-|", options: .directionLeadingToTrailing, metrics: nil, views: views))
		
		// 20 - USERNAME ICON - USERNAME FIELD - 20
		self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[_imgvUsernameIcon]-(4)-[_txtUsername]-(20)-|", options: .directionLeadingToTrailing, metrics: nil, views: views))
		
		// LOGIN BUTTON LEFT ALIGNED TO PASSWORD TEXTFIELD
		self.view.addConstraint(NSLayoutConstraint.init(item: _btnLogin, attribute: .leadingMargin, relatedBy: .equal, toItem: _txtPassword, attribute: .leadingMargin, multiplier: 1, constant: 0))
		
		// LOGIN BUTTON CENTER X
		self.view.addConstraint(NSLayoutConstraint.init(item: _btnLogin, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0))
		
		// LOGIN button height 44
		_btnLogin.addConstraint(NSLayoutConstraint.init(item: _btnLogin, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 44))
		
		// SIGN UP BUTTON LEFT AND RIGHT ALIGN LOGIN
		self.view.addConstraint(NSLayoutConstraint.init(item: _btnSignup, attribute: .leadingMargin, relatedBy: .equal, toItem: _btnLogin, attribute: .leadingMargin, multiplier: 1, constant: 0))
		self.view.addConstraint(NSLayoutConstraint.init(item: _btnSignup, attribute: .trailingMargin, relatedBy: .equal, toItem: _btnLogin, attribute: .trailingMargin, multiplier: 1, constant: 0))

		// FORGOT PASSWORD BUTTON LEFT AND RIGHT ALIGN LOGIN
		self.view.addConstraint(NSLayoutConstraint.init(item: _btnForgotPassword, attribute: .leadingMargin, relatedBy: .equal, toItem: _btnLogin, attribute: .leadingMargin, multiplier: 1, constant: 0))
		self.view.addConstraint(NSLayoutConstraint.init(item: _btnForgotPassword, attribute: .trailingMargin, relatedBy: .equal, toItem: _btnLogin, attribute: .trailingMargin, multiplier: 1, constant: 0))
		
		// FORGOT PASSWORD button height 44
		_btnForgotPassword.addConstraint(NSLayoutConstraint.init(item: _btnForgotPassword, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 44))
		
		// Password text field height according to textFieldHeight (Default: 44)
		_txtPassword.addConstraint(NSLayoutConstraint.init(item: _txtPassword, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: style.textFieldHeight))
		
		// Username text field height according to textFieldHeight (Default: 44)
		_txtUsername.addConstraint(NSLayoutConstraint.init(item: _txtUsername, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: style.textFieldHeight))
		
		// Sign up button height 44
		_btnSignup.addConstraint(NSLayoutConstraint.init(item: _btnSignup, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 44))
		
		// Username icon height 28
		_imgvUsernameIcon.addConstraint(NSLayoutConstraint.init(item: _imgvUsernameIcon, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 28))
		
		// Username icon aspect ratio 1:1
		_imgvUsernameIcon.addConstraint(NSLayoutConstraint.init(item: _imgvUsernameIcon, attribute: .width, relatedBy: .equal, toItem: _imgvUsernameIcon, attribute: .height, multiplier: 1, constant: 0))
		
		// Username icon centerY - Username text field centerY
		self.view.addConstraint(NSLayoutConstraint.init(item: _imgvUsernameIcon, attribute: .centerY, relatedBy: .equal, toItem: _txtUsername, attribute: .centerY, multiplier: 1, constant: 0))
		
		// Password icon height 28
		_imgvPasswordIcon.addConstraint(NSLayoutConstraint.init(item: _imgvPasswordIcon, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 28))
		
		// Password icon aspect ratio 1:1
		_imgvPasswordIcon.addConstraint(NSLayoutConstraint.init(item: _imgvPasswordIcon, attribute: .width, relatedBy: .equal, toItem: _imgvPasswordIcon, attribute: .height, multiplier: 1, constant: 0))
		
		// Password icon centerY - Password text field centerY
		self.view.addConstraint(NSLayoutConstraint.init(item: _imgvPasswordIcon, attribute: .centerY, relatedBy: .equal, toItem: _txtPassword, attribute: .centerY, multiplier: 1, constant: 0))
		
		// Sign up button bottom spacing 20
		self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[_btnSignup]-(20)-|", options: .directionLeadingToTrailing, metrics: nil, views: views))
		
		// About button bottom spacing 8
		self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[_btnAbout]-(0)-|", options: .directionLeadingToTrailing, metrics: nil, views: views))
		// About button leading spacing 8
		self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(8)-[_btnAbout]", options: .directionLeadingToTrailing, metrics: nil, views: views))
	}
}
