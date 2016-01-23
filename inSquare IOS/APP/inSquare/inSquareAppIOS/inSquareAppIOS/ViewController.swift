//
//  ViewController.swift
//  inSquareAppIOS
//
//  Created by Alessandro Steri on 21/01/16.
//  Copyright © 2016 Alessandro Steri. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

import Alamofire

class ViewController: UIViewController, FBSDKLoginButtonDelegate
{
    //Client Socket.io Swift    localhost: http://127.0.0.1:3000  umberto: http://insquare-bettorius.rhcloud.com/online: server: recapp-insquare.rhcloud.comsquares
    
    let socket = SocketIOClient(socketURL: "recapp-insquare.rhcloud.com", options: [.Log(true), .ForcePolling(true)])
   
    
    
    
    @IBAction func sendMessage(sender: AnyObject)
    {
        var testo = text.text
        //socket.emit("sendMessage", ["room":"SapienzaDiag", "user":"AlessndroSteri"])
        socket.emit("new message", ""+testo!)
        //socket.emit("chat message", ""+testo!)  //locale

        print("Sended")
        print(socket)
    }
    
    
  
    @IBAction func login(sender: AnyObject)
    {
        socket.emit("add user", "\(FBSDKAccessToken.currentAccessToken().userID)")
        self.returnUserData()
    }
    
    @IBOutlet var text: UITextField!

    //viewDidLoad
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //facebook login button
//        FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
//        loginButton.center = self.view.center;
//        [self.view addSubview:loginButton];
        
        if (FBSDKAccessToken.currentAccessToken() == nil)
        {
            print("Not logged in...")
        }
        else
        {
            print("Logged in...\(FBSDKAccessToken.currentAccessToken())")
            
        }
        
        var loginButton = FBSDKLoginButton()
        loginButton.readPermissions = ["public_profile", "email", "user_friends"]
        loginButton.center = self.view.center
        loginButton.delegate = self
        self.view.addSubview(loginButton)

        
        //end FB
        
        socket.on("connect") {data, ack in
            print("socket connected")
        }
        
        socket.on("currentAmount") {data, ack in
            if let cur = data[0] as? Double {
                self.socket.emitWithAck("canUpdate", cur)(timeoutAfter: 0) {data in
                    self.socket.emit("update", ["amount": cur + 2.50])
                }
                
                ack.with("Got your currentAmount", "dude")
            }
        }
        
        //prova
        self.addHandlers()
        
        socket.connect()
        
        
        
        //socket.on("new message", callback: <#T##NormalCallback##NormalCallback##([AnyObject], SocketAckEmitter) -> Void#>)
        
        
        
    }
    //END viewDidLoad
    
    
    
    //didRecieveMemoryWarning
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        
    }//ENDdidRecieveMemoryWarning

    
    // MARK: - Facebook Login
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!)
    {
        if error == nil
        {
            print("Login complete.\(FBSDKAccessToken.currentAccessToken())")
            self.performSegueWithIdentifier("showNew", sender: self)
            
            if result.grantedPermissions.contains("email")
            {
                // Do work
                print("MAILLLL")
            }
            
            
            //post su server access token FB
            
            request(.POST, "http://recapp-insquare.rhcloud.com/auth/facebook/token", parameters:["access_token": FBSDKAccessToken.currentAccessToken()])
            
            //END
        }
        else
        {
            print(error.localizedDescription)
        }
        
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!)
    {
        print("User logged out...")
    }

    //opzionale
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                print("fetched user: \(result)")
                let userName : NSString = result.valueForKey("name") as! NSString
                print("User Name is: \(userName)")
                let userEmail : NSString = result.valueForKey("email") as! NSString
                print("User Email is: \(userEmail)")
            }
        })
    }
    
    
    //end facebook
    
    
    
    
    
    
//    print("socket connected\(data)")

    
//        func onNewMessage()
//        {
//            print("NEWWWW MESSS")
//            
//        }
    
        func addHandlers()
        {
            self.socket.onAny {print("AAAAAAAAAAAAAAGot event: \($0.event), with items: \($0.items)")}
            
            //self.socket.on("new message"){print("AAAAAAAAAAAAAAGot event: \($0.event), with items: \($0.items)")}

    
//            self.socket.on("new message") {[weak self] data, ack in
//                self?.onNewMessage() }
            
            
            
        }
        

    
    
    

}//ViewController


