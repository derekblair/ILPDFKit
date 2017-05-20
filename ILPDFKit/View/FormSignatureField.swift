//
//  PDFFormFieldSignature.swift
//  Pods
//
//  Created by Chris Anderson on 6/1/16.
//
//

import UIKit


@objc open class FormSignatureField: ILPDFWidgetAnnotationView {
    
    open var name: String?
    
    fileprivate var signatureView: PDFFormFieldSignatureCaptureView?
    fileprivate var signatureOverlay: UIView?
    fileprivate let signatureExtraPadding: CGFloat = 22.0
    
    lazy fileprivate var signButton:UIButton = {
        var button = UIButton(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        button.setTitle("Tap To Sign", for: UIControlState())
        button.tintColor = UIColor.black
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        button.setTitleColor(UIColor.black, for: UIControlState())
        button.addTarget(self, action: #selector(self.addSignature), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        button.isExclusiveTouch = true
        return button
    }()
    
    lazy fileprivate var signImage:UIImageView = {
        var image = UIImageView(frame: CGRect(
            x: 0,
            y: -self.signatureExtraPadding,
            width: self.frame.width,
            height: self.frame.height + self.signatureExtraPadding * 2
            )
        )
        image.contentMode = .scaleAspectFit
        image.backgroundColor = UIColor.clear
        return image
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(red: 0.7, green: 0.85, blue: 1.0, alpha: 0.7)
        
        addSubview(signImage)
        addSubview(signButton)
        
        bringSubview(toFront: signButton)
    }
    
    override open func removeFromSuperview() {
        removeSignatureBox()
        super.removeFromSuperview()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didSetValue(_ value: AnyObject?) {
        if let value = value as? UIImage {
            signImage.image = value
        }
    }
    
    func addSignature() {
        let bounds = UIScreen.main.bounds
        
        /// Overlay
        let view = UIView()
        view.frame = bounds
        view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        window?.addSubview(view)
        signatureOverlay = view
        
        let width = bounds.width
        let height = width / frame.width * frame.height + 44.0 + signatureExtraPadding * 2
        
        if let window = UIApplication.shared.keyWindow {
            let signatureView = PDFFormFieldSignatureCaptureView(frame:
                CGRect(
                    x: (bounds.width - width) / 2,
                    y: bounds.height - height,
                    width: width,
                    height: height
                )
            )
            signatureView.delegate = self
            signatureView.layer.shadowColor = UIColor.black.cgColor
            signatureView.layer.shadowOpacity = 0.4
            signatureView.layer.shadowRadius = 3.0
            signatureView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
            window.addSubview(signatureView)
            self.signatureView = signatureView
        }
    }
    
    func removeSignatureBox() {
        if let signatureView = self.signatureView {
            signImage.image = signatureView.getSignature()
            value = signatureView.getSignature()
            delegate?.widgetAnnotationValueChanged(self)
            
            signatureOverlay?.removeFromSuperview()
            self.signatureView?.removeFromSuperview()
            self.signatureView = nil
            signButton.alpha = 0.0
        }
        
    }
    
    func renderInContext(_ context: CGContext) {
        var frame = self.frame
        frame.origin.y -= signatureExtraPadding
        frame.size.height += signatureExtraPadding * 2
        
        signImage.image?.draw(in: frame)
    }
}

extension FormSignatureField: PDFFormSignatureViewDelegate {
    func completedSignatureDrawing(_ field: PDFFormFieldSignatureCaptureView) {
        removeSignatureBox()
    }
}

protocol PDFFormSignatureViewDelegate {
    func completedSignatureDrawing(_ field: PDFFormFieldSignatureCaptureView)
}

class PDFFormFieldSignatureCaptureView: UIView {
    var delegate: PDFFormSignatureViewDelegate?
    
    // MARK: - Public properties
    var strokeWidth: CGFloat = 2.0 {
        didSet {
            path.lineWidth = strokeWidth
        }
    }
    
    var strokeColor: UIColor = UIColor.black {
        didSet {
            strokeColor.setStroke()
        }
    }
    
    var signatureBackgroundColor: UIColor = UIColor.white {
        didSet {
            backgroundColor = signatureBackgroundColor
        }
    }
    
    var containsSignature: Bool {
        get {
            if path.isEmpty {
                return false
            } else {
                return true
            }
        }
    }
    
    // MARK: - Private properties
    fileprivate var path = UIBezierPath()
    fileprivate var pts = [CGPoint](repeating: CGPoint(), count: 5)
    fileprivate var ctr = 0
    
    
    lazy fileprivate var doneButton: UIBarButtonItem = UIBarButtonItem(
        title: "Done",
        style: .plain,
        target: self,
        action: #selector(PDFFormFieldSignatureCaptureView.finishSignature)
    )
    
    lazy fileprivate var clearButton:UIBarButtonItem = UIBarButtonItem(
        title: "Clear",
        style: .plain,
        target: self,
        action: #selector(PDFFormFieldSignatureCaptureView.clearSignature)
    )
    
    // MARK: - Init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    func setupUI() {
        backgroundColor = signatureBackgroundColor
        path.lineWidth = strokeWidth
        path.lineJoinStyle = .round
        
        let spacerStart = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
        spacerStart.width = 10.0
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let spacerEnd = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
        spacerEnd.width = 10.0
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: frame.height - 44.0, width: frame.width, height: 44.0))
        toolbar.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        toolbar.setItems([spacerStart, clearButton, spacer, doneButton, spacerEnd], animated: false)
        addSubview(toolbar)
    }
    
    // MARK: - Draw
    override func draw(_ rect: CGRect) {
        strokeColor.setStroke()
        path.stroke()
    }
    
    // MARK: - Touch handling functions
    override func touchesBegan(_ touches: Set <UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first {
            let touchPoint = firstTouch.location(in: self)
            ctr = 0
            pts[0] = touchPoint
        }
    }
    
    override func touchesMoved(_ touches: Set <UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first {
            let touchPoint = firstTouch.location(in: self)
            ctr += 1
            pts[ctr] = touchPoint
            if (ctr == 4) {
                pts[3] = CGPoint(x: (pts[2].x + pts[4].x)/2.0, y: (pts[2].y + pts[4].y)/2.0)
                path.move(to: pts[0])
                path.addCurve(to: pts[3], controlPoint1: pts[1], controlPoint2: pts[2])
                
                setNeedsDisplay()
                pts[0] = pts[3]
                pts[1] = pts[4]
                ctr = 1
            }
            
            setNeedsDisplay()
        }
    }
    
    override func touchesEnded(_ touches: Set <UITouch>, with event: UIEvent?) {
        if ctr == 0 {
            let touchPoint = pts[0]
            path.move(to: CGPoint(x: touchPoint.x-1.0,y: touchPoint.y))
            path.addLine(to: CGPoint(x: touchPoint.x+1.0,y: touchPoint.y))
            setNeedsDisplay()
        } else {
            ctr = 0
        }
    }
    
    // MARK: - Methods for interacting with Signature View
    
    // Clear the Signature View
    func clearSignature() {
        path.removeAllPoints()
        setNeedsDisplay()
    }
    
    func finishSignature() {
        delegate?.completedSignatureDrawing(self)
    }
    
    // Save the Signature as an UIImage
    func getSignature(scale: CGFloat = 1) -> UIImage? {
        if !containsSignature {
            return nil
        }
        var bounds = self.bounds.size
        bounds.height = bounds.height - 44.0
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, scale)
        path.stroke()
        let signature = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return signature
    }
    
    func getSignatureCropped(scale: CGFloat = 1) -> UIImage? {
        guard let fullRender = getSignature(scale:scale) else {
            return nil
        }
        let bounds = scaleRect(path.bounds.insetBy(dx: -strokeWidth/2, dy: -strokeWidth/2), byFactor: scale)
        guard let imageRef = fullRender.cgImage?.cropping(to: bounds) else {
            return nil
        }
        return UIImage(cgImage: imageRef)
    }
    
    func scaleRect(_ rect: CGRect, byFactor factor: CGFloat) -> CGRect {
        var scaledRect = rect
        scaledRect.origin.x *= factor
        scaledRect.origin.y *= factor
        scaledRect.size.width *= factor
        scaledRect.size.height *= factor
        return scaledRect
    }
}
