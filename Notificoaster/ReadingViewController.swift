//
//  ReadingViewController.swift
//  Notificoaster
//
//  Created by Scott Hetland on 2018-12-17.
//  Copyright © 2018 Scott Hetland. All rights reserved.
//

import UIKit
import Charts

fileprivate let intervalTime = 30.0


class ReadingViewController: UIViewController
{
    @IBOutlet var valueLabels : [UILabel] = []
    @IBOutlet var descriptionLabels : [UILabel] = []
    @IBOutlet var lineChartView : LineChartView!
    @IBOutlet weak var updateTemperatureButton: UIBarButtonItem!
    
    var readingArray = [Reading]();
    var deviceId: String = ""
    
    lazy var dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter
    }()
    
    lazy var dateFormatter2 : DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    @objc func updateTemperature(sender:UIButton)
    {
        let modalViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "temperatureUpdateViewController") as! TemperatureUpdateViewController
        modalViewController.targetTemperature = Constants.TargetTemperature // this will need to be updated
        modalViewController.modalPresentationStyle = .overCurrentContext
        self.present(modalViewController, animated: true, completion: nil)
    }

    @objc func requestReadings() -> Void
    {
        ReadingRequest().getReadings(deviceId: deviceId, completion: { (readings) -> Void in
            if readings.count > 0 {
                self.readingArray = readings
                self.updatePage(readings: self.readingArray)
                self.setChartValues(readings: self.readingArray)
            } else {
                print("error")
            }
        })
    }
    
     func updatePage(readings: [Reading]) -> Void
     {
        // Update the labels
        DispatchQueue.main.async {
            let temperatureReading = readings.last?.temp ?? 0
            self.valueLabels[1].text = String(format: "%.1f", temperatureReading)
        }
    }
    
    func setChartValues(readings: [Reading]) -> Void
    {
        let values = (0..<readings.count).map { (i) -> ChartDataEntry in
            let val = Double(readings[i].temp)
            return ChartDataEntry(x: Double(i), y: val)
        }

        let dataSet = LineChartDataSet(values: values, label: nil)
        
        // make straight horizontal line dataset of two items
        let horizontalPoint1 = ChartDataEntry(x: 0, y: Double(Constants.TargetTemperature))
        let horizontalPoint2 = ChartDataEntry(x: (values.last?.x)!, y: Double(Constants.TargetTemperature))
        let dataSet2 = LineChartDataSet(values: [horizontalPoint1, horizontalPoint2], label: nil)

        
        let data = LineChartData(dataSets: [dataSet, dataSet2])
        
        var dateStrings = [String]()
        
        for reading in readings {
            let date = dateFormatter.date(from: reading.createdAt)
            let dateString = dateFormatter2.string(from: date!)
            dateStrings.append(dateString)
        }
        
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dateStrings)
        lineChartView.xAxis.granularity = 4
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.lineChartView.setNeedsDisplay()
        })

        dataSet.drawCirclesEnabled = false
        dataSet.drawValuesEnabled = false
        dataSet.lineWidth = 3.0
        dataSet.setColor(.graphHorizonColor, alpha: 0.8)
        dataSet.fill = Fill.fillWithCGColor(UIColor.clear.cgColor)
        dataSet.drawFilledEnabled = true
        dataSet.mode = .horizontalBezier
        dataSet.highlightEnabled = false
        
        dataSet2.drawCirclesEnabled = false
        dataSet2.drawValuesEnabled = false
        dataSet2.lineWidth = 1.0
        dataSet2.setColor(UIColor.gray, alpha: 0.8)
        dataSet2.fill = Fill.fillWithCGColor(UIColor.clear.cgColor)
        dataSet2.drawFilledEnabled = true
        dataSet2.mode = .horizontalBezier
        dataSet2.highlightEnabled = false

        self.lineChartView.data = data
    }
    
    
    // MARK: - UIViewController
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParentViewController {
            Session().delete()
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Style the lables and set initial value
        valueLabels[0].text = Constants.TargetTemperatureText
        valueLabels[1].text = NSLocalizedString("VALUE LABEL INITIAL TEXT 1", comment: "")
        valueLabels[2].text = NSLocalizedString("VALUE LABEL INITIAL TEXT 2", comment: "")
        
        descriptionLabels[0].text = NSLocalizedString("DESCRIPTION LABEL INITIAL TEXT 0", comment: "")
        descriptionLabels[1].text = NSLocalizedString("DESCRIPTION LABEL INITIAL TEXT 1", comment: "")
        descriptionLabels[2].text = NSLocalizedString("DESCRIPTION LABEL INITIAL TEXT 2", comment: "")
        
        for label in valueLabels {
            label.font = .valueLabelFont
            label.textColor = .defaultFontColor
        }
        for label in descriptionLabels {
            label.font = .descriptionLabelFont
            label.textColor = .defaultFontColor
        }
        
        // Style the view controller
        let logo = UIImage(named: "logo.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        self.view.backgroundColor = .backgroundColor
        
        // Setup initial chart stuff
        lineChartView.noDataText = ""
        lineChartView.translatesAutoresizingMaskIntoConstraints = false
        lineChartView.isUserInteractionEnabled = true
        lineChartView.scaleYEnabled = false
        lineChartView.backgroundColor = UIColor.clear
        
        lineChartView.xAxis.enabled = true
        lineChartView.xAxis.labelFont = .axisLabelFont
        lineChartView.xAxis.labelTextColor = UIColor.white
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.avoidFirstLastClippingEnabled = false

        lineChartView.leftAxis.enabled = true
        lineChartView.leftAxis.labelFont = .axisLabelFont
        lineChartView.leftAxis.labelTextColor = UIColor.white
        lineChartView.leftAxis.drawGridLinesEnabled = false
        lineChartView.leftAxis.drawAxisLineEnabled = false
        lineChartView.rightAxis.enabled = false
        lineChartView.legend.enabled = false
        lineChartView.chartDescription?.enabled = false

        // Fire a timer to keep requesting new information from data table
        let readingRequestTimer = Timer.scheduledTimer(timeInterval: intervalTime, target: self, selector: #selector(self.requestReadings), userInfo: nil, repeats: true)
        readingRequestTimer.fire()
        
        // Add target to the update temperature button
        updateTemperatureButton.title = NSLocalizedString("NAVIGATION BAR RIGHT BUTTON TITLE", comment: "")
        updateTemperatureButton.target = self
        updateTemperatureButton.action = #selector(updateTemperature)
    }
}
