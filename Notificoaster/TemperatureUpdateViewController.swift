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
        Session().save(deviceID: deviceID, targetTemp: targetTemperature)
        
        if let navController = presentingViewController as? UINavigationController {
            let presenter = navController.topViewController as! ReadingViewController
            presenter.targetTemperature = targetTemperature
            presenter.valueLabels[0].text = "\(targetTemperature ?? 0)°C"            
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
        
        // update label and slider values to match current target temperature
        temperatureLabel.text = "\(targetTemperature ?? Constants.TargetTemperature)°C"
        temperatureSlider.value = Float(targetTemperature)
        
        // set the view to be transparent
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        
        // add targets to items
        temperatureSlider.addTarget(self, action: #selector(sliderValueChanged(sender:)), for: .allEvents)
        confirmTemperatureButton.addTarget(self, action: #selector(confirmTemperature(sender:)), for: .touchUpInside)
    }
}
