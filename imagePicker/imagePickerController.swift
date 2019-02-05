
import UIKit

class imagePickerController: UIViewController,UIImagePickerControllerDelegate,
UINavigationControllerDelegate,  UITextFieldDelegate{
    @IBOutlet weak var cambtn: UIBarButtonItem!
    @IBOutlet weak var toptxt: UITextField!
    @IBOutlet weak var shareBtn: UIBarButtonItem!
    
  
    @IBOutlet weak var bottemtxt: UITextField!
    @IBOutlet weak var imagePicker: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareTextField(textField: toptxt, text: "TOP")
        prepareTextField(textField: bottemtxt, text: "BOTTEM")

        if(!UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            cambtn.isEnabled = false
        }
        subscribeToKeyboardNotifications()
    }
    
    func prepareTextField(textField: UITextField, text: String) {
        let memeTextAttributes = [
            NSAttributedStringKey.foregroundColor: UIColor.white,
            NSAttributedStringKey.strokeWidth: -2.0,
            NSAttributedStringKey.strokeColor : UIColor.black,
            NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18)] as [NSAttributedStringKey : Any]
        
        textField.attributedText = NSAttributedString(string: text, attributes: memeTextAttributes)
        textField.delegate = self
        textField.textAlignment = .center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if imagePicker.image == nil {
            shareBtn.isEnabled = false
        } else {
            shareBtn.isEnabled = true
        }
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
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                self.view.frame.origin.y += keyboardSize.height
        }
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
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return memedImage
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
          pickImage(source: "camera")
     }
    

    func pickImage(source: String) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        if(source == "camera") {
            pickerController.sourceType = .camera
        }else {
            pickerController.sourceType = .photoLibrary
        }
        
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func pick(_ sender: Any) {
        pickImage(source: "photo")
    }
    
    internal func imagePickerController(_ picker: UIImagePickerController,  didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
           
          imagePicker.image = image
        }
        
        picker.dismiss(animated: true)
    }
    
    @IBAction func cancelBtn(_ sender: Any) {
        imagePicker.image = nil
        toptxt.text = "TOP"
        bottemtxt.text = "BOTTEM"
    }
    
}

