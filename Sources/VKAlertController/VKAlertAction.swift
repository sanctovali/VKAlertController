//
//  VKAlertAction.swift
//  VKAlertController
//
//  Created by Valentin Kiselev on 6/1/20.
//  Copyright © 2020 Valianstin Kisialiou. All rights reserved.
//

import UIKit
/**
An action that can be performed when the user taps a button on alert
*/
public class VKAlertAction: UIButton {
	
	//MARK: - Properties -
	private var action: (() -> Void)?
	
	private(set) var actionStyle : UIAlertAction.Style
	
	//MARK: - Initialization -
	init() {
		self.actionStyle = .cancel
		super.init(frame: .zero)
	}
	/**
	Create an instance and return of VKAlertAction t with the specified title and behavior
	- Parameter title: The text to use for the button title. The value you specify should be localized for the user’s current language. This parameter must not be nil
	- Parameter style: Additional styling information to apply to the button. Use the style information to convey the type of action that is performed by the button. For a list of possible values, see the constants in UIAlertAction.Style.
	- Parameter action: A block to execute when the user selects the action. By default is nil just to dissmis an alert.
	*/
	public convenience init(title: String, style: UIAlertAction.Style, action: (() -> Void)? = nil) {
		self.init()
		self.action = action
		addTarget(self, action: #selector(performAction(_:)), for: .touchUpInside)
		setTitle(title, for: [])
		actionStyle = style
		layer.cornerRadius = 5.0
		switch actionStyle {
		case .cancel:
			titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
		default:
			titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
		}
		heightAnchor.constraint(equalToConstant: 44).isActive = true
	}
	
	required public init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	//MARK: - obj-c methods -
	//Perform the action was attached to the alert
	@objc private func performAction(_ sender: VKAlertAction) {
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
			self?.action?()
		}
	}
}
