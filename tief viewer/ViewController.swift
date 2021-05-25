//
//  ViewController.swift
//  tief viewer
//
//  Created by Алексей Петров on 24.05.2021.
//

import Cocoa
import Combine
import Quartz
import AppKit

class ViewController: NSViewController {
    
    @IBOutlet weak var imageView: IKImageView!
    @IBOutlet weak var infoLabel: NSTextField!
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var valueLabel: NSTextField!
    @IBOutlet weak var sizeLabel: NSTextField!
    
    var cancelBag = CancelBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ActionProvider
            .shared
            .subscribeTo(.openFile)
            .sink { [weak self] _ in
                self?.openFilePanel()
            }
            .store(in: cancelBag)
    
    }
    
    func windowDidResize (notification: NSNotification?) {
        imageView.zoomImageToFit(self)
    }
    
    private func openFilePanel() {
        let dialog = NSOpenPanel();

        dialog.title = "Choose a image"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.allowsMultipleSelection = false
        dialog.canChooseDirectories = false

        if dialog.runModal() ==  NSApplication.ModalResponse.OK {
            let result = dialog.url
            
            guard let result = result else {
                self.errorAlert(with: "cant open file")
                return
            }
            proccessImage(url: result)
        } else {
            return
        }
    }
    
    @IBAction func clickOnImage(_ sender: NSClickGestureRecognizer) {
        
        let imageFrame = imageView.imageSize()
        let imagePoint = imageView.convertPoint(toImagePoint: sender.location(in: self.imageView))
        let trueImagePoint = NSPoint(
            x: imagePoint.x,
            y: imageFrame.height - imagePoint.y
        )
        debugPrint("clic: \(trueImagePoint) in image frame: \(imageView.imageSize())")
        valueLabel.stringValue = "\(trueImagePoint.x) \(trueImagePoint.y)"
    }
    
    private func proccessImage(url: URL) {
        
        infoLabel.stringValue = url.path
        loadImageData(from: url) { [weak self] data in
            guard let data = data,  let image = NSImage(data: data) else {
                self?.errorAlert(with: "cant load image")
                return
            }
           
            let cgImage = image.CGImage
            let sourse = CGImageSourceCreateWithData(image.tiffRepresentation! as CFData, nil)
            let props = CGImageSourceCopyPropertiesAtIndex(sourse!, 0, nil)
            self?.imageView.setImage(cgImage, imageProperties: (props as! [AnyHashable : Any]))
            self?.imageView.zoomImageToFit(self)
            let imageFrame = self?.imageView.imageSize() ?? NSSize()
            self?.sizeLabel.stringValue = "\(imageFrame.width) \(imageFrame.height)"
        }
    }
    
    private func errorAlert(with message: String) {
        let alert = NSAlert()
        alert.messageText = "ERROR 😱"
        alert.informativeText = message
        alert.alertStyle = .critical
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    override var representedObject: Any? {
        didSet {
            _ = 0
        // Update the view, if already loaded.
        }
    }
    
    
    
    private func loadImageData(from url: URL, with completion: @escaping (Data?) -> Void) {
        
        let quele = OperationQueue()
        var imageData = Data()
        
        let operation = BlockOperation { [weak self] in
            
            do {
                imageData = try Data(contentsOf: url)
            } catch {
                self?.errorAlert(with: "Not able to load image")
            }
        }
        
        operation.completionBlock = {
            if imageData.isEmpty == false {
                DispatchQueue.main.async {
                    completion(imageData)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        quele.addOperation(operation)
    }
}

extension NSImage {
    var CGImage: CGImage {
        get {
            let imageData = self.tiffRepresentation!
            let source = CGImageSourceCreateWithData(imageData as CFData, nil).unsafelyUnwrapped
            let maskRef = CGImageSourceCreateImageAtIndex(source, Int(0), nil)
            return maskRef.unsafelyUnwrapped
        }
    }
}
