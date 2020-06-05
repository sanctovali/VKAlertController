//
//  VKAlertController.swift
//  VKAlertController
//
//  Created by Valentin Kiselev on 6/1/20.
//  Copyright © 2020 Valianstin Kisialiou. All rights reserved.
//

import UIKit
/**
An object that displays an alert message to the user
*/
public class VKAlertController: UIViewController {
	
	//MARK: - Properties -
	//The image of an alert
	private var iconImageView: UIImageView?
	//The title label of an alert
	private var titleLabel: UILabel = {
		let label = UILabel()
		label.numberOfLines = 0
		label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	//The message label of an alert body
	private var messageLabel: UILabel = {
		let label = UILabel()
		label.numberOfLines = 0
		label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	//Actually the alert
	private let alertView: UIView = {
		let view = UIView()
		view.alpha = 0
		view.layer.cornerRadius = 5
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	//The alert view width
	var alertViewWidthAnchorConstraint = NSLayoutConstraint()
	//The scroll view to embed actions if it count > 4
	private var scrollView: UIScrollView?
	//The background visual effect around the alert
	private var visualEffectView: UIVisualEffectView?
	//The container for an actions
	private lazy var actionStack = UIStackView()
	//The constant for set the same horizontal insets for subviews of an aletView
	private let horizontalInset: CGFloat = 16.0
	//The constant for set the same vertical insets for subviews of an aletView
	private let verticalInset: CGFloat = 8.0
	//Is true when all actions was added. And it's the right time to add cancel action
	private var cancelActionWasAdded: Bool = false
	//An VKAlertAction can only have one cancel action
	private var cancelAction: VKAlertAction?
	//The style to use when presenting the alert controller.
	private var prefferedStyle: UIAlertController.Style!
	/**
	The action's title color (applying to all actions)
	*/
	public lazy var tintColor: UIColor = .white
	/**
	The Background color of the action button.
	Sets the background color of the action depending on its style:
	- default is for UIAlertAction.Style.default
	- cancel is for UIAlertAction.Style.cancel
	- destructive is for UIAlertAction.Style.destructive
	nil is for clear.
	*/
	public lazy var actionsColor: (default: UIColor?, cancel: UIColor?, destructive: UIColor?)? = (
		default: UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0),
		cancel: UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 0.7),
		destructive: UIColor(red: 255/255, green: 72/255, blue: 61/255, alpha: 1.0))
	
	//MARK: - Lifecycle -
	
	public override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		iconImageViewAnchorConstraints()
		titleLabelAnchorConstraints()
		bodyLabelAnchorConstraints()
		
		addCancelAction()
		
		embedToScroll()
		
		actionStack.subviews.forEach { (view) in
			if let action = view as? VKAlertAction {
				setupAlertAction(action)
			}
		}
	}
	
	public override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		animateIn()
	}
	
	public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		embedToScroll()
		alertViewWidthAnchorConstraint.constant = calculateAlertViewWidth(invert: true)
	}
	
	//MARK: - Initialization -
	
	public convenience init(title: String?, message: String? = nil, image: UIImage? = nil, blurEffectStyle: UIBlurEffect.Style?, backgroundColor: UIColor = .white, prefferedStyle: UIAlertController.Style = .alert) {
		self.init()
		self.prefferedStyle = prefferedStyle
		self.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
		self.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
		
		//setup background style
		view.backgroundColor = .clear
		if let blurEffect = blurEffectStyle {
			setupVisualEffect(style: blurEffect)
		} else {
			addShadow()
		}
		//setup alertView
		view.addSubview(alertView)
		alertView.backgroundColor = backgroundColor
		alertviewAnchorConstraints()
		
		//setup iconImageView
		if let image = image {
			iconImageView = UIImageView()
			iconImageView!.image = image
			alertView.addSubview(iconImageView!)
		}
		//setup titleLabel
		alertView.addSubview(titleLabel)
		if let title = title {
			titleLabel.text = title
		} else {
			titleLabel.isHidden = true
		}
		
		//
		alertView.addSubview(messageLabel)
		if let body = message {
			messageLabel.text = body
		} else {
			messageLabel.isHidden = true
		}
		
		alertView.addSubview(actionStack)
		actionStack.distribution = .fillEqually
	}
	
	
	//MARK: - Private Methods -
	private func alertviewAnchorConstraints() {
		let isLanscape = UIDevice.current.orientation.isLandscape
		
		//An alert's center at view's center by horizontal axis
		alertView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		
		if prefferedStyle == .alert {
			alertView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: isLanscape ? 32 : 0).isActive = true
		} else { //.actionSheet style
			//allign to bottom
			if #available(iOS 11.0, *) {
				alertView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
			} else {
				alertView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor, constant: 0).isActive = true
			}
		}
		alertViewWidthAnchorConstraint = NSLayoutConstraint(item: alertView, attribute: .width, relatedBy: .equal, toItem: .none, attribute: .notAnAttribute, multiplier: 1.0, constant: calculateAlertViewWidth())
		NSLayoutConstraint.activate([alertViewWidthAnchorConstraint])
	}
	
	private func calculateAlertViewWidth(invert: Bool = false) -> CGFloat {
		let isLanscape = UIDevice.current.orientation.isLandscape
		if prefferedStyle == .alert {
			return isLanscape ? 320.0 : 300.0
		} else {
			//need to invert in case method called from viewWillTransition(size: coordinator:)
			if invert {
				return (isLanscape ? UIScreen.main.bounds.width : UIScreen.main.bounds.height) - 16
			} else {
				return (isLanscape ? UIScreen.main.bounds.height : UIScreen.main.bounds.width) - 16
			}
		}
	}
	
	private func iconImageViewAnchorConstraints() {
		if let iconImageView = iconImageView {
			iconImageView.translatesAutoresizingMaskIntoConstraints = false
			//the frame is square of size 128x128
			iconImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
			iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor).isActive = true
			//image is on the center of top bound of alertview
			iconImageView.centerXAnchor.constraint(equalTo: alertView.centerXAnchor).isActive = true
			//set this to iconImageView height / 2 to place it on the alertView
			iconImageView.centerYAnchor.constraint(equalTo: alertView.topAnchor, constant: 0).isActive = true
		}
	}
	
	private func titleLabelAnchorConstraints() {
		if let iconImageView = iconImageView {
			titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 0).isActive = true
		} else {
			titleLabel.topAnchor.constraint(equalTo: alertView.topAnchor, constant: verticalInset).isActive = true
		}
		titleLabel.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: horizontalInset).isActive = true
		titleLabel.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -horizontalInset).isActive = true
	}
	
	private func bodyLabelAnchorConstraints() {
		messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: verticalInset).isActive = true
		messageLabel.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: horizontalInset).isActive = true
		messageLabel.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -horizontalInset).isActive = true
	}
	
	private func setupVisualEffect(style: UIBlurEffect.Style) {
		visualEffectView = UIVisualEffectView()
		visualEffectView!.effect = UIBlurEffect(style: style)
		view.addSubview(visualEffectView!)
		visualEffectAnchorConstraints()
	}
	
	private func visualEffectAnchorConstraints() {
		if let visualEffectView = visualEffectView {
			visualEffectView.translatesAutoresizingMaskIntoConstraints = false
			visualEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
			visualEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
			visualEffectView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
			visualEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		}
	}
	
	//The shadow around the an alertview. Used only the visualEffect == nil
	private func addShadow(){
		alertView.layer.masksToBounds = false
		alertView.layer.shadowOffset = CGSize(width: 0, height: 0)
		alertView.layer.shadowRadius = 5
		alertView.layer.shadowOpacity = 0.3
	}
	
	private func addCancelAction() {
		cancelActionWasAdded = true
		if let cancelAction = cancelAction {
			addAction(cancelAction)
		}
	}
	
	//
	private func embedToScroll() {
		
		if scrollView != nil {
			scrollView?.removeFromSuperview()
			scrollView = nil
		}
		
		scrollView = UIScrollView(frame: .init(x: 0, y: 0, width: 0, height: 0))
		scrollView?.translatesAutoresizingMaskIntoConstraints = false
		alertView.addSubview(scrollView!)
		scrollView?.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 8).isActive = true
		scrollView?.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: 0).isActive = true
		scrollView?.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 0).isActive = true
		scrollView?.addSubview(actionStack)
		actionStack.translatesAutoresizingMaskIntoConstraints = false
		scrollView?.isPagingEnabled = false
		scrollView?.backgroundColor = .clear
		
		setScrollViewHeight()
		
		scrollView?.bottomAnchor.constraint(equalTo: alertView.bottomAnchor, constant: -8).isActive = true
		actionStack.widthAnchor.constraint(equalTo: scrollView!.widthAnchor).isActive = true
	}
	
	private func setScrollViewHeight() {
		guard let scrollView = scrollView else { return }
		
		//The scroll view height
		var scrollViewHeightAnchorConstraint = NSLayoutConstraint()
		
		let orientation = UIDevice.current.orientation
		
		scrollView.isScrollEnabled = orientation.isLandscape ? true : false
		
		let count = actionStack.arrangedSubviews.count
		let contentHeight = CGFloat(count * 44 + (count - 1) * 8)
		scrollView.contentSize.height = contentHeight
		//44 is the button height
		//An alert view with .actionSheet style has always vertical axis for actions
		let lanscapeHeight: CGFloat = actionStack.arrangedSubviews.count > 2 || prefferedStyle == .actionSheet ? 92 : 44
		var portraiteHeight: CGFloat
		switch count {
		case 1...2:
			portraiteHeight = prefferedStyle == .actionSheet ? 92 : 44
		case 3...5:
			portraiteHeight = contentHeight
		default:
			portraiteHeight = 236
			scrollView.isScrollEnabled = true
		}
		scrollViewHeightAnchorConstraint = NSLayoutConstraint(item: scrollView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: orientation.isLandscape ? lanscapeHeight : portraiteHeight)
		NSLayoutConstraint.activate([scrollViewHeightAnchorConstraint])
	}
	
	//MARK: - Public Methods -
	/**
	Animates the apperance of an alert
	- Parameter duration: The total duration of the animations, measured in seconds. By default is 0.4 second
	*/
	public func animateIn(duration: TimeInterval = 0.4) {
		if prefferedStyle == .alert {
			alertView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
		} else {
			alertView.transform = CGAffineTransform.init(scaleX: 1, y: 0.0)
		}
		UIView.animate(withDuration: duration) {
			self.alertView.alpha = 1
			self.alertView.transform = CGAffineTransform.identity
		}
	}
	/**
	Animates the disapperance of an alert
	- Parameter duration: The total duration of the animations, measured in seconds. By default is 0.4 second
	*/
	public func animateOut(duration: TimeInterval = 0.4) {
		UIView.animate(withDuration: duration,
					   animations: {
						if self.prefferedStyle == .alert {
							self.alertView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
						} else {
							self.alertView.transform = CGAffineTransform.init(scaleX: 1, y: 0.5)
						}
						self.visualEffectView?.alpha = 0
						self.alertView.alpha = 0
		}) { (_) in
			self.alertView.removeFromSuperview()
		}
		dismiss(animated: true, completion: nil)
	}
	/**
	Attaches an action to the alert
	- Parameter alertAction: Button to add to the alert.
	*/
	public func addAction(_ alertAction: VKAlertAction) {
		//The action with style of .cancel will be added lately
		if alertAction.actionStyle == .cancel && !cancelActionWasAdded {
			if cancelAction != nil {
				warnIfCancel()
			}
			cancelAction = alertAction
			return
		}
		
		//The cancel action always on top
		switch alertAction.actionStyle {
		case .cancel:
			actionStack.insertArrangedSubview(alertAction, at: 0)
		default:
			actionStack.addArrangedSubview(alertAction)
		}
		//sets action stack axis
		//An alert view with .actionSheet style has always vertical axis for actions
		switch actionStack.arrangedSubviews.count {
		case let count where count > 2 || prefferedStyle == .actionSheet:
			actionStack.axis = .vertical
			
		default:
			actionStack.axis = .horizontal
		}
		
		actionStack.spacing = 4.0
		
		alertAction.addTarget(self, action: #selector(dissmissAlert), for: .touchUpInside)
	}
	
	private func setupAlertAction(_ action: VKAlertAction) {
		action.setTitleColor(tintColor, for: [])
					
		//Applyes action color to action buttons
		if let colors = actionsColor {
			switch action.actionStyle {
			case .default:
				action.backgroundColor = colors.default ?? .clear
			case .cancel:
				action.backgroundColor = colors.cancel ?? .clear
			case .destructive:
				action.backgroundColor = colors.destructive ?? .clear
			@unknown default:
				break
			}
		} else {
			action.backgroundColor = .clear
		}
	}
	
	//MARK: - obj-c methods -
	@objc private func dissmissAlert() {
		animateOut()
	}
	
	//MARK: - Helper -
	private func warnIfCancel() {
		print("⚠️ WARNING: \(#function) VKAlertController can only have one action with a style of UIAlertAction.Style.cancel.\nPresented only the last added action of UIAlertAction.Style.cancel")
	}
	
}

