//
//  ViewController.swift
//  GridSystemTouchMac
//
//  Created by Zeeta Andrade on 17/03/22.
//

import Cocoa


class ViewController: NSViewController {
    
    @IBOutlet weak var drawableView: DrawableView!
    @IBOutlet weak var selctButton: NSButton!
    
    var drawButton = NSButton()
    var dragButton = NSButton()
    var zoomButton = NSButton()
    var slider = NSSlider()
    var moveButton = NSPopUpButton()
    var filterButton = NSButton()
    var stackView = NSStackView()
    
    let items: Array<String> = ["Move to Front", "Move to back", "Move one Ahead", "Move one back"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
    }
   
    override func viewDidAppear() {
        var frame = self.view.window?.frame
        frame?.size = NSSize(width: 480, height:270)
        guard let frameSize = frame else {
            return
        }
        DispatchQueue.main.async {
        self.view.window?.setFrame(frameSize, display: true, animate: true)
        }
        
    }
    
    @objc func drawButtonClicked() {
        print("Draw button clicked")
        self.drawableView.task = .draw
        self.drawableView.isSelected = false
        self.stackView.isHidden = true
        self.slider.isHidden = true
    }
    
    @objc func dragButtonClicked() {
        print("Move button clicked")
        self.drawableView.task = .drag
        self.slider.isHidden = true
    }
    
    @objc func moveButtonClicked() {
        print("Move button clicked")
        self.drawableView.task = .move
        self.drawableView.position = Position(rawValue: self.moveButton.titleOfSelectedItem!)!
        self.drawableView.needsDisplay = true
        self.slider.isHidden = true
    }
    
    
    @objc func zoomButtomClicked() {
        print("Zoom Button clicked")
        self.drawableView.task = .zoom
        slider.isHidden = false
    }
    
    @objc func sliderClicked(slider: NSSlider) {
        print("Slider Button clicked \(slider.integerValue)")
        let value = slider.integerValue
        self.drawableView.sliderValue = value
        self.drawableView.needsDisplay = true
    }
    
    @IBAction func selectButtonClicked(_ sender: Any) {
        print("select button clicked")
        drawableView.isSelected = true
    }
    
    func initialSetup() {
        setView()
        items.forEach(moveButton.addItem)
        drawableView.delegate = self
        
        self.selctButton.isEnabled = false
        stackView.isHidden = true
        stackView.addSubview(drawButton)
        stackView.addSubview(moveButton)
        stackView.addSubview(dragButton)
        stackView.addSubview(zoomButton)
        stackView.addSubview(slider)
        self.view.addSubview(stackView)
    }
    
    func setView() {
        stackView = NSStackView(frame: NSRect(x: 0, y: 10, width: self.drawableView.frame.width, height: self.drawableView.frame.height))
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        drawButton = NSButton(title: "Draw", target: self, action: #selector(drawButtonClicked))
        drawButton.frame = NSRect(x: 0, y: 0, width: 70, height: 20)
        moveButton = NSPopUpButton(title: "Move Back", target: self, action: #selector(moveButtonClicked))
        moveButton.frame = NSRect(x: 71, y: 0, width: 140, height: 20)
        dragButton = NSButton(title: "Drag", target: self, action: #selector(dragButtonClicked))
        dragButton.frame = NSRect(x: 212, y: 0, width: 70, height: 20)
        zoomButton = NSButton(title: "Zoom", target: self, action: #selector(zoomButtomClicked))
        zoomButton.frame = NSRect(x: 280, y: 0, width: 80, height: 20)
        slider = NSSlider(value: 0, minValue: 10, maxValue: 100, target: self, action: #selector(sliderClicked(slider:)))
        slider.frame = NSRect(x: 360, y: 0, width: 200, height: 20)
        slider.isHidden = true
    }

  
}

// MARK: - Update View Selegate

extension ViewController: PopupMenuDelegate {
    func setSliderValue(value: Int) {
        self.slider.integerValue = value
    }
    
    func selectOption() {
        self.selctButton.isEnabled = true
    }
    
    func popupMenu() {
        self.stackView.isHidden = false
    }
}

