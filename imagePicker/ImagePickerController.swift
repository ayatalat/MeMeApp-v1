
import UIKit

class ImagePickerController: UIViewController,UIImagePickerControllerDelegate,
UINavigationControllerDelegate,  UITextFieldDelegate{
    @IBOutlet weak var cambtn: UIBarButtonItem!
    @IBOutlet weak var toptxt: UITextField!
    
    @IBOutlet weak var shareBtn: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    
    @IBOutlet weak var navBar: UIToolbar!
    @IBOutlet weak var bottemtxt: UITextField!
    @IBOutlet weak var imagePicker: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareTextField(textField: toptxt, text: "TOP")
        prepareTextField(textField: bottemtxt, text: "BOTTOM")
        cambtn.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        subscribeToKeyboardNotifications()
    }
    
    func prepareTextField(textField: UITextField, text: String) {
        textField.delegate = self
        textField.textAlignment = .center
        let memeTextAttributes = [
            NSAttributedStringKey.foregroundColor: UIColor.white,
            NSAttributedStringKey.strokeWidth: -2.0,
            NSAttributedStringKey.strokeColor : UIColor.white,
            NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18)] as [NSAttributedStringKey : Any]
        
        textField.attributedText = NSAttributedString(string: text, attributes: memeTextAttributes) // styles not applied to the text field !!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (imagePicker.image == nil) {
            shareBtn.isEnabled = false
        }// if i remove the condition the share btn always disabled even if there is image and i don't know the reason
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if(bottemtxt.isEditing) {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        self.view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    func save() {
        let memedImage = generateMemedImage()
        let meme = Meme(topText: toptxt.text!, bottomText: bottemtxt.text!, image: imagePicker.image!, memedImage: memedImage)
    }
    
    func generateMemedImage() -> UIImage {
        hideToolbars(true)
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        hideToolbars(false)
        return memedImage
    }
    
    func hideToolbars(_ hide: Bool) {
        navBar.isHidden = hide
        toolBar.isHidden = hide
    }
    
   
    @IBAction func shareImage(_ sender: Any) {
        let memedImage = generateMemedImage()
        let activityController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        activityController.completionWithItemsHandler = { activity, success, items, error in
            if(success){
                self.save()
            }
            self.dismiss(animated : true, completion: nil)
        }
        
        
        present (activityController, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text  = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    @IBAction func pickFromCam(_ sender: Any) {
        pickImage(.camera)
    }
    
    
    func pickImage(_ type: UIImagePickerControllerSourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = type
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func pick(_ sender: Any) {
        pickImage(.photoLibrary)
    }
    
    internal func imagePickerController(_ picker: UIImagePickerController,  didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePicker.image = image
            shareBtn.isEnabled = true
        }
        
        picker.dismiss(animated: true)
    }
    
    @IBAction func cancel(_ sender: Any) {
        imagePicker.image = nil
        toptxt.text = "TOP"
        bottemtxt.text = "BOTTOM"
    }
    
}

