//
//  DrawableView.swift
//  GridSystemTouchMac
//
//  Created by Zeeta Andrade on 17/03/22.
//

import Cocoa

enum Tasks {
    case draw
    case move
    case zoom
    case drag
}

enum Position: String {
    case front = "Move to Front"
    case back = "Move to back"
    case oneAhead = "Move one Ahead"
    case oneBack = "Move one back"
}

protocol PopupMenuDelegate {
    func popupMenu()
    func selectOption()
    func setSliderValue(value: Int)
}

class ContainerView: DrawableView {
  override var isFlipped: Bool { return true }
}

class DrawableView: NSView {
    
    var delegate: PopupMenuDelegate?
    
    var startPoint: NSPoint?
    var endPoint: NSPoint?
    var currentClickPoint: NSPoint?
    var currentLayer: CAShapeLayer?
    var arrayOfLayers: [CAShapeLayer] = []
    
    var task: Tasks = .draw
    var position: Position = .front
    var isSelected: Bool = false
    var sliderValue: Int = 0
    
    var width: CGFloat?
    var height: CGFloat?
    var zCount: CGFloat = 0
    var dict: [CAShapeLayer: Int] = [:]
    
    var currentEditingView: ResizableView? = nil
    var lastEditedView: ResizableView? = nil
    
    var timerFlag: Bool = false
    var userResizableView: ResizableView?
    
    var scaledImageSize: CGSize?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        
        NotificationCenter.default.addObserver(forName: NSWindow.didResizeNotification, object: nil, queue: OperationQueue.main) { (notification) in
            print("didRsize")

            print(self.window?.frame.size)
            print(self.bounds.size)
            print(self.frame.size)
            if self.imageSize != nil {
                self.resetImage()
            }
            
        }
    }
    
    var imageSize: CGSize?
    var frameSize: CGSize?
    
    func resetImage() {
        
        frameSize = CGSize(width: self.frame.size.width, height: self.frame.size.height)
        let aspectRatioFrame = frameSize!.width / frameSize!.height
        let aspectRatioImage = imageSize!.width / imageSize!.height
        var computedImageWidth: CGFloat = 0
        var computedImageHeight: CGFloat = 0
        var verticalSpace: CGFloat = 0
        var horizontalSpace: CGFloat = 0
        
        if (aspectRatioImage <= aspectRatioFrame){
            computedImageWidth = frameSize!.height * aspectRatioImage;
            computedImageHeight = frameSize!.height;
            verticalSpace = 0;
            horizontalSpace = (frameSize!.width - computedImageWidth)/2;
        } else {
            computedImageWidth = frameSize!.width;
            computedImageHeight = frameSize!.width / aspectRatioImage;
            horizontalSpace = 0;
            verticalSpace = (frameSize!.height - computedImageHeight)/2;
        }
        currentLayer?.frame = CGRect(x: horizontalSpace, y: verticalSpace, width: computedImageWidth, height: computedImageHeight)
       
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        drawGrid()
        performAction()
    }
    
    func performAction() {
        switch task {
        case .draw:
            print("draw")
            drawRect()
            startPoint = nil
            endPoint = nil
        case .move:
            movingLayers(currentClickPostition: currentClickPoint)
        case .drag:
            print("Drag")
        case .zoom:
            zoomLayer()
        }
    }
    
    func drawGrid() {
//        for i in 1...(Int(self.bounds.size.height) / 10)
        let heightDivWidth = self.bounds.size.height / self.bounds.size.width
        let aspectRationHeight = heightDivWidth * 10
        let widthDivHeight = self.bounds.size.width / self.bounds.size.height
        let aspectRatioWidth = widthDivHeight * 10
        print(heightDivWidth, aspectRationHeight, "\n", widthDivHeight, aspectRatioWidth)
        
        let cellRatio = CGFloat(10/10)
        let heightOfRow = self.bounds.size.width / cellRatio
        
        let ratio = self.bounds.size.width / 20
        let scaledHeight = 20 * ratio
        
        
        for i in 0...10 {
            NSColor.init(red: 100/255.0, green: 149/255.0, blue: 237/255.0, alpha: 0.1).set()
            NSBezierPath.strokeLine(from: CGPoint(x: 0, y: CGFloat(i) * ((self.bounds.size.height) / 10)), to: CGPoint(x: self.bounds.size.width, y: CGFloat(i) * ((self.bounds.size.height) / 10)))
        }
        
//        needsDisplay = true
//        for i in 1...(Int(self.bounds.size.width) / 10)
        for i in 1...10 {
            NSColor.init(red: 100/255.0, green: 149/255.0, blue: 237/255.0, alpha: 0.1).set()
            NSBezierPath.strokeLine(from: CGPoint(x: CGFloat(i) * ((self.bounds.size.width) / 10), y:0), to: CGPoint(x: CGFloat(i) * ((self.bounds.size.width) / 10), y: self.bounds.size.height))
        }
        needsDisplay = true
        
//        for i in 1...5 {
//            NSColor.init(red: 100/255.0, green: 149/255.0, blue: 237/255.0, alpha: 0.1).set()
//            NSBezierPath.strokeLine(from: CGPoint(x: CGFloat(i) * 10 * aspectRatioWidth, y:0), to: CGPoint(x: CGFloat(i) * 10 * aspectRatioWidth, y: self.bounds.size.height))
//        }
    }
    
    func drawRect() {
        if let theStart = startPoint,
           let theEnd = endPoint {
            
            let rectFrame = NSRect(x: theStart.x - self.frame.origin.x, y: theEnd.y - self.frame.origin.y, width: theEnd.x - theStart.x, height: theStart.y - theEnd.y)
            
            // adding Shape layer
            let imageLayer = createShapeLayer(frame: rectFrame)
            self.layer?.addSublayer(imageLayer)
            
            sort(shapeLayer: imageLayer)
            currentLayer = imageLayer
            
            self.delegate?.selectOption()
        }
    }
}


// MARK: - Mouse events

extension DrawableView {
    
    func fireTimer() {
        print(timerFlag, "in timer")
        if timerFlag {
            print("superview Long pressed")
            task = .drag
            userResizableView?.borderView?.isHidden = true
            userResizableView?.removeFromSuperview()
        } else {
            task = .draw
        }
        
    }
    
    override func mouseDown(with event: NSEvent) {
        print("Mouse down")
        
        
        if isSelected {
            self.timerFlag = true
            task = .draw
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                print("Inside dispatch", self.timerFlag)
                self.fireTimer()
                print("fire")
            }
            
//            userResizableView?.borderView?.isHidden = false
            
            //find layer
            currentClickPoint = event.locationInWindow
            currentLayer = getTheLayer(point: currentClickPoint!)
            guard let currentLayer = currentLayer else { return }
            print("\nCurrent layer\n", currentLayer)
            
            sliderValue = getSliderValue(layer: currentLayer)
            self.delegate?.setSliderValue(value: sliderValue)
            
            //pop up the menu
            self.delegate?.popupMenu()
                    
//            self.createDashedPatternLayer(imageLayer: currentLayer)
            
            //create resizableview
            createResizableView(layer: currentLayer)
            
            performAction()
        } else {
            if startPoint != nil && endPoint != nil {
                return
            }
            if startPoint == nil || endPoint != nil {
                startPoint = event.locationInWindow
            } else {
                endPoint = event.locationInWindow
                //call redraw method (draw)
                needsDisplay = true
            }
            print("Start: ",startPoint ?? 0, "End: ",endPoint ?? 0)
        }
    }
    
    func createResizableView(layer: CAShapeLayer) {
        if userResizableView != nil {
            userResizableView?.removeFromSuperview()
        }
        let imageFrame = layer.frame
        userResizableView = ResizableView(frame: imageFrame)
        userResizableView?.contentViewLayer = layer
        userResizableView?.setZposition(zpos: layer.zPosition)
        userResizableView?.delegate = self
        self.addSubview(userResizableView!)
    }
    
    override func mouseDragged(with event: NSEvent) {
        print("SuperView drag")
//        timerFlag = false
        
        print(task)
        print(timerFlag)
        if timerFlag && task == .drag {
            print("SuperView dragging")

            var currentLocation: NSPoint
            currentLocation = event.locationInWindow
//            if isOutOfView(currentLocation: currentLocation) {
                currentLayer?.frame.origin = currentLocation
//            }
//            CATransform3DMakeTranslation(<#T##tx: CGFloat##CGFloat#>, <#T##ty: CGFloat##CGFloat#>, <#T##tz: CGFloat##CGFloat#>)
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        print("Mouse up called")
        timerFlag = false
        task = .draw
    }
    
    override func mouseExited(with event: NSEvent) {
        self.currentClickPoint = nil
    }
}


extension DrawableView: ResizableViewDelegate {
    func singlePress() {
        print("Single press")
        task = .draw
        timerFlag = false
    }
    
    func longPressed() {
        print("Delegate for resize")
        task = .drag
        timerFlag = true
    }
    
    func userResizableViewDidBeginEditing(_ userResizableView: ResizableView) {
        currentEditingView?.hideEditingHandles()
        currentEditingView = userResizableView
    }
    
    func userResizableViewDidEndEditing(_ userResizableView: ResizableView) {
        lastEditedView = userResizableView
    }
}

extension DrawableView: NSGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: NSGestureRecognizer, shouldReceive touch: NSTouch) -> Bool {
        if ((currentEditingView?.hitTest(touch.location(in: currentEditingView))) != nil) {
            return false
        }
        return true
    }
    
    func hideEditingHandles() {
        lastEditedView?.hideEditingHandles()
    }
}

// MARK: - Moving the layer

extension DrawableView {
    func movingLayers(currentClickPostition: NSPoint?) {
        if position == .back {
            print("back")
            moveBack()
        } else if position == .front {
            print("front")
            moveFront()
        } else if position == .oneAhead {
            print("One ahead")
            moveAheadLayer()
        } else {
            print("one back")
            moveOneBackLayer()
        }
    }
    
    func moveFront() {
        for layer in arrayOfLayers {
            if isMousePoint(currentClickPoint!, in: layer.frame) {
                let currentZPosition = layer.zPosition
                print("Current zPosition \(currentZPosition)")
                for items in arrayOfLayers {
                    if items.zPosition == currentZPosition  {
                        layer.zPosition = zCount
                        print("Updated zPosition \(layer.zPosition)")
                    } else if items.zPosition > currentZPosition {
                        items.zPosition -= 1
                    }
                    continue
                }
            } else {
                continue
            }
            return
        }
    }
    
    func moveBack() {
        for layer in arrayOfLayers {
            if isMousePoint(currentClickPoint!, in: layer.frame) {
                let currentZPosition = layer.zPosition
                print("Current zPosition \(currentZPosition)")
                for items in arrayOfLayers {
                    if items.zPosition == currentZPosition  {
                        layer.zPosition = 1
                        print("Updated zPosition \(layer.zPosition)")
                    } else if items.zPosition < currentZPosition {
                        items.zPosition += 1
                    }
                    continue
                }
            } else {
                continue
            }
            return
        }
    }
    
    func moveAheadLayer() {
        for layer in arrayOfLayers {
            if isMousePoint(currentClickPoint!, in: layer.frame) {
                let currentZPosition = layer.zPosition
                print("Current zPosition \(currentZPosition)")
                for items in arrayOfLayers {
                    if items.zPosition == currentZPosition + 1 {
                        items.zPosition = currentZPosition
                        layer.zPosition = currentZPosition + 1
                        print("Updated zPosition \(layer.zPosition)")
                        break
                    }
                }
            } else {
                continue
            }
            return
        }
    }
    
    func moveOneBackLayer() {
        for layer in arrayOfLayers {
            if isMousePoint(currentClickPoint!, in: layer.frame) {
                let currentZPosition = layer.zPosition
                print("Current zPosition \(currentZPosition)")
                for items in arrayOfLayers {
                    if items.zPosition == currentZPosition - 1 {
                        items.zPosition = currentZPosition
                        layer.zPosition = currentZPosition - 1
                        print("Updated zPosition \(layer.zPosition)")
                        break
                    }
                }
            } else {
                continue
            }
            return
        }
    }
    
}


// MARK: - Related methods

extension DrawableView {
    
    func setImageSize() -> NSImage? {
        let image = generateRandomImages()
        let targetSize = CGSize(width: self.bounds.size.width, height: self.bounds.size.height)

        // Compute the scaling ratio for the width and height separately
        let widthScaleRatio = targetSize.width / (image?.size.width)!
        let heightScaleRatio = targetSize.height / (image?.size.height)!

        // To keep the aspect ratio, scale by the smaller scaling ratio
        let scaleFactor = min(widthScaleRatio, heightScaleRatio)

        // Multiply the original image’s dimensions by the scale factor
        // to determine the scaled image size that preserves aspect ratio
        scaledImageSize = CGSize(
            width: (image?.size.width)! * scaleFactor,
            height: (image?.size.height)! * scaleFactor
        )
        return image
    }
    
    func createShapeLayer(frame: CGRect) -> CAShapeLayer {
        guard let image = setImageSize() else { return CAShapeLayer() }
        imageSize = CGSize(width: image.size.width, height: image.size.height)
//        let frameSize = CGRect(origin: .zero, size: scaledImageSize!)
        let imageLayer = CAShapeLayer()
        self.wantsLayer = true
        zCount = zCount + 1
        imageLayer.zPosition = zCount
        imageLayer.backgroundColor = NSColor.random.cgColor
        imageLayer.contents = image
        imageLayer.frame = frame
        imageLayer.contentsGravity = .resizeAspectFill
        imageLayer.masksToBounds = true
        imageLayer.fillColor = nil
        // If setNeedsDisplay is used image is not rendered as a content
       // imageLayer.setNeedsDisplay()
        return imageLayer
    }
    
    func createDashedPatternLayer(imageLayer: CAShapeLayer) {
        let path = CGMutablePath()
        path.addRect(imageLayer.bounds)
        imageLayer.path = path
        
        imageLayer.strokeColor = NSColor.black.cgColor
        imageLayer.backgroundColor = NSColor.clear.cgColor
//        imageLayer.borderColor = NSColor.white.cgColor
//        imageLayer.borderWidth = 2
        imageLayer.lineDashPattern = [5, 3]
        imageLayer.lineCap = .butt
        imageLayer.lineJoin = .round
        imageLayer.lineWidth = 4
        animateLayer(layer: imageLayer)
    }
     
    func removeDashedPattern(layer: CAShapeLayer?) {
        guard let layer = layer else {
            return
        }
        layer.lineWidth = 0
    }
    
    func animateLayer(layer: CAShapeLayer) {
        let animation = CABasicAnimation(keyPath: "lineDashPhase")
        animation.fromValue = 0
        animation.toValue = layer.lineDashPattern?.reduce(0) { $0 + $1.intValue }
        animation.duration = 1
        animation.repeatCount = Float.greatestFiniteMagnitude
        layer.add(animation, forKey: nil)
    }
    
    func createTextLayer(superLayer: CAShapeLayer) -> CATextLayer {
        let textlayer = CATextLayer()
        textlayer.frame = CGRect(x: superLayer.frame.width / 2 - 10, y: superLayer.frame.height / 2 , width: 20, height: 20)
        textlayer.fontSize = 12
        textlayer.alignmentMode = .center
        textlayer.string = String(Int(zCount))
        textlayer.isWrapped = true
        textlayer.truncationMode = .end
        textlayer.backgroundColor = NSColor.white.cgColor
        textlayer.foregroundColor = NSColor.black.cgColor
        textlayer.contentsScale = NSScreen.main!.backingScaleFactor
        return textlayer
    }
    
    func getTheLayer(point: CGPoint) -> CAShapeLayer? {
        for layer in arrayOfLayers {
            if isMousePoint(point, in: layer.frame) {
                return layer
            }
        }
        return nil
    }
    
    func sort(shapeLayer: CAShapeLayer) {
        var dict: [CAShapeLayer: CGFloat] = [:]
        arrayOfLayers.append(shapeLayer)
        arrayOfLayers.forEach { (layer) in
            let area = layer.frame.width * layer.frame.height
            dict[layer] = area
        }
        let sortedArray = dict.sorted { ($0.value < $1.value) }
        arrayOfLayers = []
        sortedArray.forEach { (value) in
            arrayOfLayers.append(value.key)
        }
    }
   
    func saveSliderValue(layer: CAShapeLayer, value: Int) {
        if dict.keys.contains(layer) {
            dict.updateValue(value, forKey: layer)
        } else {
            dict[layer] = value
        }
    }
    
    func getSliderValue(layer: CAShapeLayer) -> Int {
        guard let value = dict[layer] else { return 0 }
        return value
    }
    
    func zoomLayer() {
        guard let currentLayer = currentLayer else {
            return
        }
        if sliderValue > 0 {
            let zoomMultiplier = CGFloat(sliderValue) / 50
            //        if isOutOfView(currentLocation: (currentLayer?.frame.origin)!) {
            currentLayer.transform = CATransform3DMakeScale(zoomMultiplier, zoomMultiplier, 1)
            let frameSize = currentLayer.frame.size
            print(frameSize)
            saveSliderValue(layer: currentLayer, value: sliderValue)
        //        }
        }
    }
    
    func focusSelectedLayer(currentClickPoint: NSPoint?) {
        if let currentClickPoint = currentClickPoint {
            for layer in arrayOfLayers {
                if isMousePoint(currentClickPoint, in: layer.frame) == true {
                    currentLayer = layer
                    width = currentLayer?.frame.size.width
                    height = currentLayer?.frame.size.height
                }
            }
        }
    }
    
    func isOutOfView(currentLocation: NSPoint) -> Bool {
        if (currentLocation.x < (self.bounds.width - (currentLayer?.bounds.width)!) && currentLocation.x > 0 && currentLocation.y < (self.bounds.height - (currentLayer?.bounds.height)!) && currentLocation.y > 0) {
            return true
        }
        return false
    }
    
    func generateRandomImages() -> NSImage? {
        let random = arc4random_uniform(4) //returns 0 to 2 randomly
        switch random {
        case 0: return NSImage(named: NSImage.Name("1"))
        case 1: return NSImage(named: NSImage.Name("2"))
        case 2: return NSImage(named: NSImage.Name("download"))
        case 3: return NSImage(named: NSImage.Name("cat"))
        default: return NSImage(named: NSImage.Name("cat"))
        }
    }
    
    //Gesture is Not used in this
    @objc func handlePanGesture(gesture: NSPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        print(translation)
        self.currentLayer?.frame.origin += gesture.translation(in: self)
        gesture.setTranslation(.zero, in: self)
    }
}


