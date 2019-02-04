
import UIKit

class ViewController: UIViewController,UIImagePickerControllerDelegate,
UINavigationControllerDelegate,  UITextFieldDelegate{
    @IBOutlet weak var cambtn: UIBarButtonItem!
    @IBOutlet weak var toptxt: UITextField!
    @IBOutlet weak var shareBtn: UIBarButtonItem!
    
  
    @IBOutlet weak var bottemtxt: UITextField!
    @IBOutlet weak var imagePicker: UIImageView!
   let memeTextAttributes = [
       .strokeColor : UIColor.black,
       .foregroundColor : UIColor.white,
        .strokeWidth : -2.0,
        .font : UIFont.boldSystemFont(ofSize: 18)
        ] as [NSAttributedStringKey : Any]

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toptxt.delegate = self
        bottemtxt.delegate = self
        toptxt.textAlignment = .center
        bottemtxt.textAlignment = .center
       // toptxt.defaultTextAttributes = memeTextAttributes
      //  bottemtxt.defaultTextAttributes = strokeTextAttributes
        // commented as if i put them i have this error Cannot assign value of type '[NSAttributedStringKey : Any]' to type '[String : Any]'
    }
    


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         subscribeToKeyboardNotifications()
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
        view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
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
            self.save()
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
          let cam = UIImagePickerController()
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
        {
            cam.sourceType = UIImagePickerControllerSourceType.camera
            present(cam, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        
    }
    
  
    @IBAction func pick(_ sender: Any) {
        let pickerController = UIImagePickerController()
         pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
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

