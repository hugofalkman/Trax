//
//  EditWaypointViewController.swift
//  Trax
//
//  Created by H Hugo Falkman on 2015-05-10.
//  Copyright (c) 2015 H Hugo Fakman. All rights reserved.
//

import UIKit
import MobileCoreServices

class EditWaypointViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Public API
    
    var waypointToEdit: EditableWaypoint? { didSet { updateUI() } }
    
    // MARK: - Private Implementation
    
    private func updateUI() {
        nameTextField?.text = waypointToEdit?.name
        infoTextField?.text = waypointToEdit?.info
        updateImage()
    }
    
    @IBAction private func done(sender: UIBarButtonItem) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.becomeFirstResponder()
        updateUI()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        startObservingTextFields()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        stopObservingTextFields()
    }
    
    // MARK: - Image
    
    var imageView = UIImageView()
    
    @IBOutlet weak var imageViewContainer: UIView! {
        didSet {
            imageViewContainer.addSubview(imageView)
        }
    }
    
    @IBAction func takePhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            let picker = UIImagePickerController()
            picker.sourceType = .Camera
            // if video, check media types
            picker.mediaTypes = [kUTTypeImage]
            picker.delegate = self
            picker.allowsEditing = true
            presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        imageView.image = image
        makeRoomForImage()
        saveImageInWaypoint()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveImageInWaypoint() {
        if let image = imageView.image {
            if let imageData = UIImageJPEGRepresentation(image, 1.0) {
                let fileManager = NSFileManager()
                if let docsDir = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as? NSURL {
                    let unique = NSDate.timeIntervalSinceReferenceDate()
                    let url = docsDir.URLByAppendingPathComponent("\(unique).jpg")
                    if let path = url.absoluteString {
                        if imageData.writeToURL(url, atomically: true) {
                            waypointToEdit?.links = [GPX.Link(href: path)]
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Text Fields
    
    @IBOutlet weak var nameTextField: UITextField! { didSet { nameTextField.delegate = self } }
    @IBOutlet weak var infoTextField: UITextField! { didSet { infoTextField.delegate = self } }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    var ntfObserver: NSObjectProtocol?
    var itfObserver: NSObjectProtocol?
    
    private func startObservingTextFields() {
        let center = NSNotificationCenter.defaultCenter()
        let queue = NSOperationQueue.mainQueue()
        ntfObserver = center.addObserverForName(UITextFieldTextDidChangeNotification,
            object: nameTextField, queue: queue) { notification in
                if let waypoint = self.waypointToEdit {
                    waypoint.name = self.nameTextField.text
                }
        }
        itfObserver = center.addObserverForName(UITextFieldTextDidChangeNotification,
            object: infoTextField, queue: queue) { notification in
                if let waypoint = self.waypointToEdit {
                    waypoint.info = self.infoTextField.text
                }
        }
    }

    private func stopObservingTextFields() {
        if let observer = ntfObserver {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
        if let observer = itfObserver {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
    }
}

extension EditWaypointViewController
{
    func updateImage() {
        if let url = waypointToEdit?.imageURL {
            let qos = Int(QOS_CLASS_USER_INITIATED.value)
            dispatch_async(dispatch_get_global_queue(qos, 0)) { [weak self] in
                if let imageData = NSData(contentsOfURL: url) {
                    if url == self?.waypointToEdit?.imageURL {
                        if let image = UIImage(data: imageData) {
                            dispatch_async(dispatch_get_main_queue()) {
                                self?.imageView.image = image
                                self?.makeRoomForImage()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func makeRoomForImage() {
        var extraHeight: CGFloat = 0
        if imageView.image?.aspectRatio > 0 {
            if let width = imageView.superview?.frame.size.width {
                let height = width / imageView.image!.aspectRatio
                extraHeight = height - imageView.frame.height
                imageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
            }
        } else {
            extraHeight = -imageView.frame.height
            imageView.frame = CGRectZero
        }
        preferredContentSize = CGSize(width: preferredContentSize.width, height: preferredContentSize.height + extraHeight)
    }
}

extension UIImage {
    var aspectRatio: CGFloat {
        return size.height != 0 ? size.width / size.height : 0
    }
}
