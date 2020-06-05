//
//  ViewController.swift
//  VKAlertControllerDemo
//
//  Created by Valentin Kiselev on 6/4/20.
//  Copyright © 2020 Valianstin Kisialiou. All rights reserved.
//

import UIKit
import VKAlertController

final class ViewController: UIViewController {
	
	@IBOutlet weak var includeCancelActionLabel: UILabel!
	@IBOutlet weak var includeDistructiveActionLabel: UILabel!
	@IBOutlet weak var actionsCountLabel: UILabel!
	@IBOutlet weak var stackView: UIStackView!
	@IBOutlet weak var blurEffectPickerView: UIPickerView!
	@IBOutlet weak var alertColorPickerView: UIPickerView!
	
	private var prefferedStyle: UIAlertController.Style = .alert
	private var isCancelActionNeeded: Bool = true
	private var isDestructiveActionNeeded: Bool = true
	private var actionsCount = 1
	private var blurEffect: UIBlurEffect.Style? = nil
	private var alertColor: UIColor = .white
	
	private let effects: [String] = ["None", "Extra Light", "Light", "Dark"]
	
	private let colors: [String: UIColor] = ["white" : .white, "systemYellow" : .systemYellow, "systemBlue" : .systemBlue, "systemRed": .systemRed, "systemPink" : .systemPink, "systemOrange": .systemOrange, "systemPurple" :.systemPurple, "systemTeal": .systemTeal, "systemGreen" : .systemGreen ]

	override func viewDidLoad() {
		super.viewDidLoad()
		blurEffectPickerView.dataSource = self
		blurEffectPickerView.delegate = self
		alertColorPickerView.dataSource = self
		alertColorPickerView.delegate = self
		if let indexPosition = Array(colors.keys).firstIndex(of: "white") {
		  alertColorPickerView.selectRow(indexPosition, inComponent: 0, animated: true)
		}
	}

	@IBAction func showAlertButtonDidTapped(_ sender: Any) {
		
		let ac = VKAlertController(title: "Background color would be changed",
								   message: "Wich color will you select?",
								   image: UIImage(named: "paint"), // nil is default
								   blurEffectStyle: blurEffect, //you can omit this .none is default
								   backgroundColor: alertColor, // .white is default
								   prefferedStyle: prefferedStyle)
		
		
		generateActions().forEach({ac.addAction($0)})
		
		if isCancelActionNeeded {
			let cancel = VKAlertAction(title: "Cancel", style: .cancel)
			ac.addAction(cancel)
		}
		
		if isDestructiveActionNeeded {
			let clear = VKAlertAction(title: "Reset Color", style: .destructive) {
				self.view.backgroundColor = .black
			}
			ac.addAction(clear)
		}
		/*
		//Additional customising
		//ac.tintColor = .black
	//	ac.actionsColor = nil
		ac.actionsColor = (default: UIColor.systemBlue, cancel: nil, destructive: UIColor.systemPink)
		*/
		present(ac, animated: true, completion: nil)
	}

	

	@IBAction func prefferetStyleSwitchValueChanged(_ sender: UISwitch) {
		prefferedStyle = sender.isOn ? .actionSheet : .alert
	}
	@IBAction func includeCancelActionSwitchValueChanged(_ sender: UISwitch) {
		isCancelActionNeeded.toggle()
		includeCancelActionLabel.text = isCancelActionNeeded ? "Include cancel action" : "Do not include cancel action"
	}
	@IBAction func includeDistructiveActionSwitchValueChanged(_ sender: UISwitch) {
		isDestructiveActionNeeded.toggle()
		includeDistructiveActionLabel.text = isDestructiveActionNeeded ? "Include destruclive action" : "Do not include destruclive action"
	}
	@IBAction func actionsStepperValueChanged(_ sender: UIStepper) {
		actionsCount = Int(sender.value)
		actionsCountLabel.text = String(actionsCount)
	}
	
	
	private func generateActions() -> [VKAlertAction] {
		var actions = [VKAlertAction]()

		for _ in 0..<actionsCount {
			var key = Array(colors.keys)[Int.random(in: 0..<colors.count)]
			if key == "white" {
				key = "systemGreen"
			}
			let color = colors[key]!
			let action = VKAlertAction(title: key, style: .default) {
				self.view.backgroundColor = color
			}
			actions.append(action)
		}
		return actions
	}
	
}

extension ViewController: UIPickerViewDelegate {}

extension ViewController: UIPickerViewDataSource {
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		if pickerView == blurEffectPickerView {
			return effects.count
		} else {
			return colors.count
		}
		
	}
	
	func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
		var title = String()
		if pickerView == blurEffectPickerView {
			 title = effects[row]
		} else {
			title = Array(colors.keys)[row]
			
		}
		return NSAttributedString(string: title, attributes: [NSAttributedString.Key.foregroundColor:UIColor.white])
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		if pickerView == blurEffectPickerView {
			 blurEffect = UIBlurEffect.Style.init(rawValue: row - 1)
		} else {
			let key = Array(colors.keys)[row]
			alertColor = colors[key]!
		}
		
	}
	
	
}
