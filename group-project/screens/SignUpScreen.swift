/*
Author: Tran Thanh Ngan Vu
Group Name: Byte_Buddies
Group Members:
- Tran Thanh Ngan Vu 991663076
- Chahat Jain 991668960
- Fizza Imran 991670304
- Chakshita Gupta 991653663
Description: This class handles the sign-up process for users, including hashing passwords and storing user information in a Firestore database.
*/

import UIKit
import CryptoKit

// These Imports are used for Firebase - Firestore Database
import FirebaseFirestore

class SignUpScreen: UIViewController, UITextFieldDelegate {
    
    let mainDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet var tbName : UITextField!
    @IBOutlet var tbPass : UITextField!
    
    @IBAction func addPerson(sender : Any)
    {
        let person : MyData = MyData.init()
        person.initWithData(theRow: 0, theName: tbName.text!, thePass: tbPass.text!)
            
        let returnCode : Bool = AppDelegate.shared.insertIntoDatabase(person: person)
        
        var returnMSG : String = "Person Added"
        
        if returnCode == false
        {
            returnMSG = "Person Add Failed"
        }
        
        let alertController = UIAlertController(title: "SQLite Add", message: returnMSG, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        password.isSecureTextEntry = true
        // Do any additional setup after loading the view.
    }
    
    // This function is used to make the keyboard disappear when we tap the "return" key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    // This function is used to fetch all documents from any table
    func fetchDocuments(tableName: String) async throws -> [String: Any] {
        let collection = Firestore.firestore().collection(tableName)
        let querySnapshot = try await collection.getDocuments()
        var data = [String: Any]()
        for document in querySnapshot.documents {
            data[document.documentID] = document.data()
        }
        return data
    }
    
    // Variables for username and password
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    
    // Fuction that adds user to database for the first time
    @IBAction func signUp(sender: Any) {
        // Ensure both text fields are not empty
        guard let usernameText = username.text, !usernameText.isEmpty,
              let passwordText = password.text, !passwordText.isEmpty else {
            let alert = UIAlertController(title: "Error", message: "Please enter both username and password", preferredStyle: .alert)
            let closeAlertAction = UIAlertAction(title: "Close", style: .cancel)
            alert.addAction(closeAlertAction)
            self.present(alert, animated: true)
            print("Username and password cannot be empty")
            return
        }
        
        // Author : Fizza Imran - hash Fuctionality
        // Hash the password using SHA-256 algorithm
        let hashedPassword = hashPassword(passwordText)
        
        Task {
            do {
                let documents = try await fetchDocuments(tableName: "Profiles")
                print(documents)
                
                // Check if the username already exists
                if documents.values.contains(where: { ($0 as? [String: Any])?["Username"] as? String == usernameText }) {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Error", message: "Username already exists", preferredStyle: .alert)
                        let closeAlertAction = UIAlertAction(title: "Close", style: .cancel)
                        alert.addAction(closeAlertAction)
                        self.present(alert, animated: true)
                    }
                } else {
                    let collection = Firestore.firestore().collection("Profiles")
                    
                    collection.addDocument(
                        data: ["Username": usernameText,
                               "password": hashedPassword,
                               "AvailableCampuses": nil,
                               "HomeCampus": nil,
                               "HomeCampusCoordinates": nil]
                    ) { error in
                        if let error = error {
                            print("Error adding document: \(error)")
                        } else {
                            let alert = UIAlertController(title: "Successful", message: "Please log in!", preferredStyle: .alert)
                            let closeAlertAction = UIAlertAction(title: "Close", style: .cancel)
                            alert.addAction(closeAlertAction)
                            self.present(alert, animated: true)
                            print("Document added successfully!")
                        }
                    }
                }
            } catch {
                print("Error fetching documents: \(error)")
            }
        }
    }
    
    // Author : Fizza Imran - hash Fuctionality
    // Function to hash the password using SHA-256 algorithm
    func hashPassword(_ password: String) -> String {
        let inputData = Data(password.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashedString = hashedData.compactMap { String(format: "%02x", $0) }.joined()
        return hashedString
    }
}

