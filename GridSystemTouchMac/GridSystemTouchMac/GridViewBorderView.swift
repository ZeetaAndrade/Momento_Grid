//
//  GridViewBorderView.swift
//  GridSystemTouchMac
//
//  Created by Zeeta Andrade on 29/03/22.
//

import Cocoa


enum CurrentEdge {
    case topMiddle
    case middleLeft
    case middleRight
    case bottomMiddle
    case none
}

struct AnchorPoint {
    var adjustsX: CGFloat = 0.0
    var adjustsY: CGFloat = 0.0
    var adjustsH: CGFloat = 0.0
    var adjustsW: CGFloat = 0.0
}

struct AnchorPointPair {
    var point: CGPoint = CGPoint.zero
    var anchorPoint: AnchorPoint = AnchorPoint()
}

protocol ResizableViewDelegate: NSObjectProtocol {
    // Called when the resizable view receives touchesBegan: and activates the editing handles.
    func userResizableViewDidBeginEditing(_ userResizableView: ResizableView)
    
    // Called when the resizable view receives touchesEnded: or touchesCancelled:
    func userResizableViewDidEndEditing(_ userResizableView: ResizableView)
    func longPressed()
    func singlePress()
}


class ResizableView: NSView {
    
    var borderView: GridViewBorderView?
    var _contentView: NSView?
    
    var contentViewLayer: CAShapeLayer? = nil
    
    weak var delegate: ResizableViewDelegate?
    
    let globalInset:CGFloat = 0.0
    let defaultMinWidth:CGFloat = 48.0
    let defaultMinHeight:CGFloat = 48.0
    let interactiveBorderSize:CGFloat = 10.0
    
    var touchStart = CGPoint.zero
    var minWidth: CGFloat = 48.0
    var minHeight: CGFloat = 48.0
    
    var anchorPoint = AnchorPoint()
    
//    private var noResizeAnchorPoint = AnchorPoint(adjustsX: 0.0, adjustsY: 0.0, adjustsH: 0.0, adjustsW: 0.0)
//    private var upperLeftAnchorPoint = AnchorPoint(adjustsX: 1.0, adjustsY: 1.0, adjustsH: -1.0, adjustsW: 1.0)
//    private var upperMiddleAnchorPoint = AnchorPoint(adjustsX: 0.0, adjustsY: 1.0, adjustsH: -1.0, adjustsW: 0.0)
//    private var upperRightAnchorPoint = AnchorPoint(adjustsX: 0.0, adjustsY: 1.0, adjustsH: -1.0, adjustsW: -1.0)
//    private var middleLeftAnchorPoint = AnchorPoint(adjustsX: 1.0, adjustsY: 0.0, adjustsH: 0.0, adjustsW: 1.0)
//    private var middleRightAnchorPoint = AnchorPoint(adjustsX: 0.0, adjustsY: 0.0, adjustsH: 0.0, adjustsW: -1.0)
//    private var lowerLeftAnchorPoint = AnchorPoint(adjustsX: 1.0, adjustsY: 0.0, adjustsH: 1.0, adjustsW: 1.0)
//    private var lowerMiddleAnchorPoint = AnchorPoint(adjustsX: 0.0, adjustsY: 0.0, adjustsH: 1.0, adjustsW: 0.0)
//    private var lowerRightAnchorPoint = AnchorPoint(adjustsX: 0.0, adjustsY: 0.0, adjustsH: 1.0, adjustsW: -1.0)
   
    private var noResizeAnchorPoint = AnchorPoint(adjustsX: 0.0, adjustsY: 0.0, adjustsH: 0.0, adjustsW: 0.0)
    
    private var lowerLeftAnchorPoint = AnchorPoint(adjustsX: 1.0, adjustsY: 1.0, adjustsH: -1.0, adjustsW: 1.0)
    
    private var lowerMiddleAnchorPoint = AnchorPoint(adjustsX: 0.0, adjustsY: 1.0, adjustsH: -1.0, adjustsW: 0.0)
    
    private var lowerRightAnchorPoint = AnchorPoint(adjustsX: 0.0, adjustsY: 1.0, adjustsH: -1.0, adjustsW: -1.0)
    
    private var middleLeftAnchorPoint = AnchorPoint(adjustsX: 1.0, adjustsY: 0.0, adjustsH: 0.0, adjustsW: 1.0)
    
    private var middleRightAnchorPoint = AnchorPoint(adjustsX: 0.0, adjustsY: 0.0, adjustsH: 0.0, adjustsW: -1.0)
    
    private var upperLeftAnchorPoint = AnchorPoint(adjustsX: 1.0, adjustsY: 0.0, adjustsH: 1.0, adjustsW: 1.0)
    
    private var upperMiddleAnchorPoint = AnchorPoint(adjustsX: 0.0, adjustsY: 0.0, adjustsH: 1.0, adjustsW: 0.0)
    
    private var upperRightAnchorPoint = AnchorPoint(adjustsX: 0.0, adjustsY: 0.0, adjustsH: 1.0, adjustsW: -1.0)
    
    var isPreventsPositionOutsideSuperview: Bool = true
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
        setupDefaultAttributes()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupDefaultAttributes()
    }
    
//    @objc func dragLayer(gesture: NSPanGestureRecognizer) {
//        print("pan gesture")
//        borderView?.isHidden = true
//        print(gesture.translation(in: self))
//        let translation = gesture.translation(in: self)
//        self.contentViewLayer?.frame.origin += gesture.translation(in: self)
//        borderView?.frame.origin += gesture.translation(in: self)
//        gesture.setTranslation(.zero, in: self)
//    }
    
    func setupDefaultAttributes() {
        
        self.layer?.zPosition = 1
        borderView = GridViewBorderView(frame: bounds)
        borderView?.isHidden = false
        self.addSubview(borderView!)
        
//        contentViewLayer?.frame = bounds
//        self.layer?.addSublayer(contentViewLayer!)

        minWidth = defaultMinWidth
        minHeight = defaultMinHeight
        isPreventsPositionOutsideSuperview = true
    }
    
    func setViewFrame(_ newFrame: CGRect) {
        self.frame = newFrame

        self.contentViewLayer?.frame = newFrame.insetBy(dx: globalInset, dy: globalInset)
        borderView?.frame = bounds.insetBy(dx: globalInset, dy: globalInset)
        
        contentViewLayer?.needsDisplay()
        borderView?.setNeedsDisplay(newFrame)
    }
    
    func setZposition(zpos: CGFloat) {
       self.layer?.zPosition = zpos
    }
    
    private func distanceBetweenTwoPoints(point1: CGPoint, point2: CGPoint) -> CGFloat {
        print(point1, "\n", point2)
        let dx: CGFloat = point2.x - point1.x
        let dy: CGFloat = point2.y - point1.y
        return sqrt(dx * dx + dy * dy)
    }
    
    func anchorPoint(forTouchLocation touchPoint: CGPoint) -> AnchorPoint {
        // (1) Calculate the positions of each of the anchor points.
        let centerPoint = AnchorPointPair(point: CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2), anchorPoint: noResizeAnchorPoint)
        
        let lowerLeft = AnchorPointPair(point: CGPoint(x: 0.0, y: 0.0), anchorPoint: lowerLeftAnchorPoint)
        
        let lowerMiddle = AnchorPointPair(point: CGPoint(x: bounds.size.width / 2, y: 0.0), anchorPoint: lowerMiddleAnchorPoint)
        
        let lowerRight = AnchorPointPair(point: CGPoint(x: bounds.size.width, y: 0.0), anchorPoint: lowerRightAnchorPoint)
        
        let middleLeft = AnchorPointPair(point: CGPoint(x: 0, y: bounds.size.height / 2), anchorPoint: middleLeftAnchorPoint)
        
        let middleRight = AnchorPointPair(point: CGPoint(x: bounds.size.width, y: bounds.size.height / 2), anchorPoint: middleRightAnchorPoint)
        
        let upperLeft = AnchorPointPair(point: CGPoint(x: 0, y: bounds.size.height), anchorPoint: upperLeftAnchorPoint)
        
        let upperMiddle = AnchorPointPair(point: CGPoint(x: bounds.size.width / 2, y: bounds.size.height), anchorPoint: upperMiddleAnchorPoint)
        
        let upperRight = AnchorPointPair(point: CGPoint(x: bounds.size.width, y: bounds.size.height), anchorPoint: upperRightAnchorPoint)
    
        
        // (2) Iterate over each of the anchor points and find the one closest to the user's touch.
        let allPoints: [AnchorPointPair] = [centerPoint, upperLeft, upperMiddle, upperRight, middleLeft, middleRight, lowerLeft, lowerMiddle, lowerRight]
        var smallestDistance: CGFloat = CGFloat(MAXFLOAT)
        var closestPoint: AnchorPointPair = centerPoint
        for i in 0..<9 {
            let distance: CGFloat = distanceBetweenTwoPoints(point1: touchPoint, point2: allPoints[i].point)
            if distance < smallestDistance {
                closestPoint = allPoints[i]
                smallestDistance = distance
            }
        }
        return closestPoint.anchorPoint
    }
    
    func isResizing() -> Bool {
        return (anchorPoint.adjustsH != 0 || anchorPoint.adjustsW != 0 || anchorPoint.adjustsX != 0 || anchorPoint.adjustsY != 0)
    }
    
    func showEditingHandles() {
        borderView?.isHidden = false
//        timerFlag = false
    }
    
    func hideEditingHandles() {
        borderView?.isHidden = false
        
    }
    
    override func mouseDragged(with event: NSEvent) {
//        anchorPoint.adjustsX == 0 && anchorPoint.adjustsY == 0 && anchorPoint.adjustsH == 0 && anchorPoint.adjustsW == 0
//        isDraggable &&

//        if !isResizing() {
//            borderView?.isHidden = true
////            contentViewLayer?.frame.origin = event.locationInWindow
////            guard let ContentFrame = contentViewLayer?.frame.origin else { return }
////            borderView?.frame.origin = ContentFrame
////            needsDisplay = true
//
////            translate(usingTouchLocation: event.locationInWindow)
////            setAnchorPoint(event.locationInWindow)
////            trans(touchPoint: event.locationInWindow)
//        } else

//        if isDraggable {
//
////            contentViewLayer?.frame.origin = event.locationInWindow
////            borderView?.frame.origin = event.locationInWindow
//
//        } else
        timerFlag = false
        if isResizing() {
            timerFlag = false
            if let superView = self.superview {
                resize(usingTouchLocation: event.locationInWindow)
            }
        }
    }
    
    func findLocationInsideImage(clickedInWindow: CGPoint) -> CGPoint {
        let x = self.frame.minX
        let y = self.frame.minY
        
        let relativePoint = CGPoint(x: (clickedInWindow.x - x), y: (clickedInWindow.y - y))
        return relativePoint
    }

    var timerFlag: Bool = false
    var isDraggable: Bool = false
    
    override func mouseDown(with event: NSEvent) {
//        super.moveDown(event)
        
        self.timerFlag = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.fireTimer()
        }

        delegate?.userResizableViewDidBeginEditing(self)
   
        borderView?.isHidden = false

        anchorPoint = anchorPoint(forTouchLocation: findLocationInsideImage(clickedInWindow: event.locationInWindow))
        print(anchorPoint)

        touchStart = event.locationInWindow
        
        if !isResizing() {
            touchStart = event.locationInWindow
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        print("Mouse up in grid")
        timerFlag = false
        if !isResizing() {
            delegate?.singlePress()
        }
    }
    
    func fireTimer() {
        if timerFlag {
            print("Long pressed")
            delegate?.longPressed()
//            borderView?.removeFromSuperview()
            self.removeFromSuperview()
            self.borderView?.isHidden = true
           
        }
    }
    override func mouseExited(with event: NSEvent) {
        delegate?.userResizableViewDidEndEditing(self)
    }
    
    func resize(usingTouchLocation touchPoint: CGPoint) {
        
        var deltaW: CGFloat = anchorPoint.adjustsW * (touchStart.x - touchPoint.x)
        let deltaX: CGFloat = anchorPoint.adjustsX * (-1.0 * deltaW)
        var deltaH: CGFloat = anchorPoint.adjustsH * (touchPoint.y - touchStart.y)
        let deltaY: CGFloat = anchorPoint.adjustsY * (-1.0 * deltaH)
        // (3) Calculate the new frame.
        var newX: CGFloat = frame.origin.x + deltaX
        var newY: CGFloat = frame.origin.y + deltaY
        var newWidth: CGFloat = frame.size.width + deltaW
        var newHeight: CGFloat = frame.size.height + deltaH
        // (4) If the new frame is too small, cancel the changes.
        if newWidth < minWidth {
            newWidth = frame.size.width
            newX = frame.origin.x
        }
        if newHeight < minHeight {
            newHeight = frame.size.height
            newY = frame.origin.y
        }

        // (5) Ensure the resize won't cause the view to move offscreen.
        if isPreventsPositionOutsideSuperview {
            if let superView = self.superview {
                if newX < superView.bounds.origin.x {
                    // Calculate how much to grow the width by such that the new X coordintae will align with the superview.
                    deltaW = self.frame.origin.x - superView.bounds.origin.x
                    newWidth = self.frame.size.width + deltaW
                    newX = superView.bounds.origin.x
                }

                if newX + newWidth > superView.bounds.origin.x + superView.bounds.size.width {
                    newWidth = superView.bounds.size.width - newX
                }

                if newY < superView.bounds.origin.y {
                    // Calculate how much to grow the height by such that the new Y coordintae will align with the superview.
                    deltaH = self.frame.origin.y - superView.bounds.origin.y
                    newHeight = self.frame.size.height + deltaH
                    newY = superView.bounds.origin.y
                }

                if newY + newHeight > superView.bounds.origin.y + superView.bounds.size.height {
                    newHeight = superView.bounds.size.height - newY
                }

            }
        }

        
        self.setViewFrame(CGRect(x: newX, y: newY, width: newWidth, height: newHeight))
        touchStart = touchPoint
    }
    
    func translate(usingTouchLocation touchPoint: CGPoint) {
//        let centerX = contentViewLayer?.frame.midX
//        let centerY = contentViewLayer?.frame.midY
        
//        let position = contentViewLayer?.position
        
        let center = contentViewLayer?.frame.center
        
//        var newCenter = CGPoint(x: center!.x + touchPoint.x - touchStart.x, y: center!.y + touchPoint.y - touchStart.y)
        
        var newCenter = CGPoint(x: touchPoint.x - center!.x, y: touchPoint.y - center!.y)
        
        if isPreventsPositionOutsideSuperview {
            if let superView = self.superview {

                // Ensure the translation won't cause the view to move offscreen.
                let midPointX: CGFloat = bounds.midX
                if newCenter.x > superView.bounds.size.width - midPointX {
                    newCenter.x = superView.bounds.size.width - midPointX
                }
                if newCenter.x < midPointX {
                    newCenter.x = midPointX
                }
                let midPointY: CGFloat = bounds.midY
                if newCenter.y > superView.bounds.size.height - midPointY {
                    newCenter.y = superView.bounds.size.height - midPointY
                }
                if newCenter.y < midPointY {
                    newCenter.y = midPointY
                }
            }
        }
//        center = newCenter
//        self.contentViewLayer?.position = newCenter
        contentViewLayer?.frame.origin = touchPoint
        
       
        needsDisplay = true
    }
    
}



class GridViewBorderView: NSView {
    
    
    let globalInset:CGFloat = 0.0
    let defaultMinWidth:CGFloat = 48.0
    let defaultMinHeight:CGFloat = 48.0
    let interactiveBorderSize:CGFloat = 10.0
    
    weak var delegate: ResizableViewDelegate?
    
    // Will be retained as a subview.
    var contentView: NSView?
    // Default is 48.0 for each.
    var minWidth: CGFloat = 0.0
    var minHeight: CGFloat = 0.0
    // Defaults to YES. Disables the user from dragging the view outside the parent view's bounds.
    var isPreventsPositionOutsideSuperview: Bool = false
    
//    var borderView: GripViewBorderView?
    
    var touchStart = CGPoint.zero
    // Used to determine which components of the bounds we'll be modifying, based upon where the user's touch started.
    var anchorPoint = AnchorPoint()
    
    func hideEditingHandles() {
    }
    
    func showEditingHandles() {
    }
    
    override init(frame: CGRect) {
        // Clear background to ensure the content view shows through.
        super.init(frame: frame)
        self.wantsLayer = true
        self.layer?.backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func animateLayer(layer: CAShapeLayer) {
        let animation = CABasicAnimation(keyPath: "lineDashPhase")
        animation.fromValue = 0
        animation.toValue = layer.lineDashPattern?.reduce(0) { $0 + $1.intValue }
        animation.duration = 1
        animation.repeatCount = Float.greatestFiniteMagnitude
        layer.add(animation, forKey: nil)
    }
    
    func draw() {
        
        self.layer?.sublayers?.forEach({$0.removeFromSuperlayer()})
//        self.layer?.zPosition = 100
        
        let rectLayer = CAShapeLayer()
        let path = CGMutablePath()
        path.addRect(bounds)
        
        rectLayer.path = path
        rectLayer.lineWidth = 5.0
        rectLayer.strokeColor = NSColor.blue.cgColor
        rectLayer.fillColor = nil
        rectLayer.lineDashPattern = [5, 5]
        self.layer?.insertSublayer(rectLayer, above: self.layer)
        animateLayer(layer: rectLayer)
        
        let lowerLeft = CGRect(x: 0.0, y: 0.0, width: interactiveBorderSize, height: interactiveBorderSize)
        let lowerRight = CGRect(x: bounds.size.width - interactiveBorderSize, y: 0.0, width: interactiveBorderSize, height: interactiveBorderSize)
        let upperRight = CGRect(x: bounds.size.width - interactiveBorderSize, y: bounds.size.height - interactiveBorderSize, width: interactiveBorderSize, height: interactiveBorderSize)
        let upperLeft = CGRect(x: 0.0, y: bounds.size.height - interactiveBorderSize, width: interactiveBorderSize, height: interactiveBorderSize)
        let lowerMiddle = CGRect(x: (bounds.size.width - interactiveBorderSize) / 2, y: 0.0, width: interactiveBorderSize, height: interactiveBorderSize)
        let upperMiddle = CGRect(x: (bounds.size.width - interactiveBorderSize) / 2, y: bounds.size.height - interactiveBorderSize, width: interactiveBorderSize, height: interactiveBorderSize)
        let middleLeft = CGRect(x: 0.0, y: (bounds.size.height - interactiveBorderSize) / 2, width: interactiveBorderSize, height: interactiveBorderSize)
        let middleRight = CGRect(x: bounds.size.width - interactiveBorderSize, y: (bounds.size.height - interactiveBorderSize) / 2, width: interactiveBorderSize, height: interactiveBorderSize)
        
        let allPoints: [CGRect] = [upperLeft, upperRight, lowerRight, lowerLeft, upperMiddle, lowerMiddle, middleLeft, middleRight]
        for i in 0..<8 {
            let currPoint: CGRect = allPoints[i]
            
            let ecllipsLayer = CAShapeLayer()
            let path = CGMutablePath()
            path.addEllipse(in: currPoint)
            ecllipsLayer.path = path
            ecllipsLayer.fillColor = NSColor.blue.cgColor
            ecllipsLayer.strokeColor = NSColor.white.cgColor
            ecllipsLayer.lineWidth = 2
            ecllipsLayer.shadowColor = NSColor.white.cgColor
            ecllipsLayer.shadowOffset = CGSize(width: 0.5, height: 0.5)
            ecllipsLayer.shadowOpacity = 1.0
            ecllipsLayer.shadowRadius = 0.0
            self.layer?.insertSublayer(ecllipsLayer, above: rectLayer)
        }
        
    }
    
    override func draw(_ rect: CGRect) {
        draw()
//        let context: CGContext? = NSGraphicsContext.current?.cgContext
//        context?.saveGState()
//
//        // (1) Draw the bounding box.
//        context?.setLineWidth(5.0)
//        context?.setStrokeColor(NSColor.blue.cgColor)
////        context?.addRect(bounds.insetBy(dx: interactiveBorderSize / 2, dy: interactiveBorderSize / 2))
//        context?.addRect(bounds)
////        context?.strokePath()
//
////        context?.saveGState()
//        context?.setLineDash(phase: 0, lengths: [5, 5])
//        context?.setLineCap(.butt)
//        context?.strokePath()
//        context?.restoreGState()
//
//
//
//
////        let layer = CAShapeLayer()
////        let path = CGMutablePath()
////        path.addRect(bounds.insetBy(dx: interactiveBorderSize / 2, dy: interactiveBorderSize / 2))
////
////        layer.path = path
////        layer.lineWidth = 1.0
////        layer.strokeColor = NSColor.blue.cgColor
////        layer.fillColor = nil
////        self.layer?.insertSublayer(layer, above: self.layer)
//
//        // (2) Calculate the bounding boxes for each of the anchor points.
//        let lowerLeft = CGRect(x: 0.0, y: 0.0, width: interactiveBorderSize, height: interactiveBorderSize)
//        let lowerRight = CGRect(x: bounds.size.width - interactiveBorderSize, y: 0.0, width: interactiveBorderSize, height: interactiveBorderSize)
//        let upperRight = CGRect(x: bounds.size.width - interactiveBorderSize, y: bounds.size.height - interactiveBorderSize, width: interactiveBorderSize, height: interactiveBorderSize)
//        let upperLeft = CGRect(x: 0.0, y: bounds.size.height - interactiveBorderSize, width: interactiveBorderSize, height: interactiveBorderSize)
//        let lowerMiddle = CGRect(x: (bounds.size.width - interactiveBorderSize) / 2, y: 0.0, width: interactiveBorderSize, height: interactiveBorderSize)
//        let upperMiddle = CGRect(x: (bounds.size.width - interactiveBorderSize) / 2, y: bounds.size.height - interactiveBorderSize, width: interactiveBorderSize, height: interactiveBorderSize)
//        let middleLeft = CGRect(x: 0.0, y: (bounds.size.height - interactiveBorderSize) / 2, width: interactiveBorderSize, height: interactiveBorderSize)
//        let middleRight = CGRect(x: bounds.size.width - interactiveBorderSize, y: (bounds.size.height - interactiveBorderSize) / 2, width: interactiveBorderSize, height: interactiveBorderSize)
//
//        // (3) Create the gradient to paint the anchor points.
//        let colors: [CGFloat] = [0.4, 0.8, 1.0, 1.0, 0.0, 0.0, 1.0, 1.0]
//        let baseSpace: CGColorSpace? = CGColorSpaceCreateDeviceRGB()
//        let gradient: CGGradient = CGGradient(colorSpace: baseSpace!, colorComponents: colors, locations: nil, count: 2)!
//
//        // (4) Set up the stroke for drawing the border of each of the anchor points.
//        context?.setLineWidth(2)
//        context!.setShadow(offset: CGSize(width: 0.5, height: 0.5), blur: 1)
//        context?.setStrokeColor(NSColor.white.cgColor)
//
////        layer.lineWidth = 2
////        layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
////        layer.strokeColor = NSColor.white.cgColor
////        self.layer?.addSublayer(layer)
//
//        // (5) Fill each anchor point using the gradient, then stroke the border.
//        let allPoints: [CGRect] = [upperLeft, upperRight, lowerRight, lowerLeft, upperMiddle, lowerMiddle, middleLeft, middleRight]
//        for i in 0..<8 {
//            let currPoint: CGRect = allPoints[i]
//            context?.saveGState()
//            //context?.addEllipse(in: currPoint)
//            let currentPoint = CGRect(x: currPoint.origin.x, y: currPoint.origin.y, width: 10, height: 10);
//            context?.addEllipse(in: currentPoint)
//            context?.clip()
//
////            path.addEllipse(in: currentPoint)
////            layer.path = path
////            layer.fillColor = NSColor.blue.cgColor
////            layer.fillRule = .evenOdd
//
//
//            let startPoint = CGPoint(x: currentPoint.midX, y: currentPoint.minY)
//            let endPoint = CGPoint(x: currentPoint.midX, y: currentPoint.maxY)
//            context?.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
//            context?.restoreGState()
//            context?.strokeEllipse(in: currentPoint.insetBy(dx: 1, dy: 1))
//
////            layer.setNeedsDisplay()
////            needsDisplay = true
//        }
//        context?.restoreGState()
////        needsDisplay = true
    }
}

extension CGRect {
    var center: CGPoint { .init(x: midX, y: midY) }
}
