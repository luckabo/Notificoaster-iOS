//
//  TemperatureUpdateViewController.swift
//  Notificoaster
//
//  Created by Scott Hetland on 2019-09-07.
//  Copyright © 2019 Scott Hetland. All rights reserved.
//

import UIKit

class TemperatureUpdateViewController: UIViewController
{
    @IBOutlet var foregroundView: UIView!
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var temperatureSlider: UISlider!
    @IBOutlet var confirmTemperatureButton: UIButton!
    
    var targetTemperature: Int!
    var deviceID: String!
    
    @objc func confirmTemperature(sender: UIButton)
    {
        targetTemperature = Int(temperatureSlider.value)
        
        let session = Session()
        let userID = session.fetchUserID()
        let phoneID = session.fetchPhoneID()
        session.save(deviceID: deviceID, userID: userID, targetTemp: targetTemperature, phoneID: phoneID)
        session.updateTargetTemperature(targetTemp: targetTemperature, userID: userID) { (updatedObject) in
            if updatedObject["targetTemperature"] as? Int == self.targetTemperature {
                print("updated")
            }
            else {
                print("not updated")
            }
        }
    
        if let navController = presentingViewController as? UINavigationController {
            let presenter = navController.topViewController as! ReadingViewController
            presenter.targetTemperature = targetTemperature
            presenter.valueLabels[0].text = "\(targetTemperature ?? 0)°C"
            if presenter.readingArray.count > 0 {
                presenter.setChartValues(readings: presenter.readingArray)
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc func sliderValueChanged(sender: UISlider)
    {
        temperatureLabel.text = "\(Int(temperatureSlider.value))°C"
    }
    
    
    // MARK: - UIViewController
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Configure starting text and styling
        temperatureLabel.text = "\(targetTemperature ?? Constants.TargetTemperature)°C"
        temperatureLabel.font = .descriptionLabelFont
        temperatureLabel.textColor = UIColor.white
        confirmTemperatureButton.setTitle(NSLocalizedString("CONFIRM BUTTON TEXT", comment: ""), for: .normal)
        confirmTemperatureButton.confirmButtonStyling(font: .loginButtonFont, height: confirmTemperatureButton.frame.size.height)
        
        foregroundView.backgroundColor = .backgroundColor
        foregroundView.layer.cornerRadius = 8.0
        foregroundView.layer.borderWidth = 2.0
        foregroundView.layer.borderColor = UIColor.gray.cgColor
        foregroundView.clipsToBounds = true
        
        // Configure slider starting temperature
        temperatureSlider.value = Float(targetTemperature)
        
        // set the view to be transparent
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        // add targets to items
        temperatureSlider.addTarget(self, action: #selector(sliderValueChanged(sender:)), for: .allEvents)
        confirmTemperatureButton.addTarget(self, action: #selector(confirmTemperature(sender:)), for: .touchUpInside)
    }
}
