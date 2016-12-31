//
//  ViewController.swift
//  TrackingMe
//
//  Created by chaoyee on 2016/12/6.
//  Copyright © 2016年 charleshsu.co. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import CoreLocation
import MapKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var signinBtn: UIButton!
    @IBOutlet weak var signoutBtn: UIButton!
    @IBOutlet weak var createUserBtn: UIButton!
    @IBOutlet weak var startBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordField.delegate   = self
        
        // Change the buttons state
        signoutBtn.isEnabled     = false
        startBtn.isEnabled       = false
        startBtn.backgroundColor = UIColor.red
    }
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func SigninBtn(_ sender: Any) {
        signin()
    }

    @IBAction func signoutBtn(_ sender: Any) {
        if (FIRAuth.auth() != nil) {
            deleteData()
            
            // Change the buttons state
            signinBtn.isEnabled      = true
            signoutBtn.isEnabled     = false
            createUserBtn.isEnabled  = true
            startBtn.isEnabled       = false
            startBtn.backgroundColor = UIColor.red

            signout()
            
            statusLabel.textColor = UIColor.red
            statusLabel.text = "Signout"
        }
    }
    
    @IBAction func createUserBtn(_ sender: Any) {
        createUser()
    }
    
    @IBAction func startBtn(_ sender: Any) {
        let mvc = self.storyboard?.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        self.navigationController?.pushViewController(mvc, animated: true)
    }
    
    
    // Close the virtual keyboard while finishing typing at any textField
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Close the virtual keyboard while one or more fingers touch down in a view or window
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        self.passwordField.resignFirstResponder()
        super.touchesBegan(touches, with:event)
    }
    
    // Sign in the Firebase
    func signin(){
        let email    = self.emailField.text
        let password = self.passwordField.text
        if  (!(email?.isEmpty)!) && (!(password?.isEmpty)!) {
            showSpinner({
            // [START headless_email_auth]
            FIRAuth.auth()?.signIn(withEmail: email!, password: password!) { (user, error) in
                // [START_EXCLUDE]
                self.hideSpinner({
                if let error = error {
                    self.showMessagePrompt(error.localizedDescription)
                    print(error.localizedDescription)
                    return
                }
                self.navigationController!.popViewController(animated: true)
                print( (user?.email)! + " uid:" + (user?.uid)!  + " Signin successfully!")
                userID = (user?.uid)!
                username = (user?.email)!
                    
                self.signinBtn.isEnabled     = false
                self.signoutBtn.isEnabled    = true
                self.createUserBtn.isEnabled = false
                self.startBtn.isEnabled      = true
                self.startBtn.backgroundColor = UIColor.blue
                    
                self.statusLabel.textColor = UIColor.blue
                self.statusLabel.text = "Signin"
                })
                // [END_EXCLUDE]
                
                
            }
            // [END headless_email_auth]
            })
        } else {
            self.showMessagePrompt("email/password can't be empty")
            print("email/password can't be empty")
        }
    }
    
    // Sign out the Firebase
    func signout(){
        // [START signout]
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            print("Signout successfully!")
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        // [END signout]
    }
    
    
    // Create a new user in the Firebase
    func createUser(){
        if let email = self.emailField.text, let password = self.passwordField.text {
            showSpinner({
            // [START headless_email_auth]
            FIRAuth.auth()?.createUser(withEmail: email, password: password) { (user, error) in
                // [START_EXCLUDE]
                self.hideSpinner({
                if let error = error {
                    self.showMessagePrompt(error.localizedDescription)
                    print(error.localizedDescription)
                    return
                }
                self.navigationController!.popViewController(animated: true)
                print( (user?.email)! + " uid:" + (user?.uid)!  + " has been created successfully!")
                userID = (user?.uid)!
                username = (user?.email)!
                })
                // [END_EXCLUDE]
            }
            // [END headless_email_auth]
            })
        } else {
            self.showMessagePrompt("email/password can't be empty")
            print("email/password can't be empty")
        }
    }
    
    
    // Write data to the Firebase
    func writeData(){
        if (FIRAuth.auth() != nil) {
            let refData = ref.child((userID))
            refData.child("username").setValue(username)
            refData.child("long").setValue(long)
            refData.child("lati").setValue(lati)
            print("write OK!")
        } else {
            print("Write Data Error!")
        }
    }
    
    
    // Delete data in the Firebase
    func deleteData(){
        if (FIRAuth.auth() != nil) {
            let refData = ref.child((userID))
            refData.removeValue()
            print("Delete OK!")
        } else {
            print("Delete Data Error!")
        }
    }
}

