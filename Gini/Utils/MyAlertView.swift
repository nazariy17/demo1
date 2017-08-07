//
//  MyAlertView.swift
//
//  Created by Nazar on 14/07/2017.
//  Copyright © 2017 Nazariy Bohun. All rights reserved.
//

import Foundation
import SCLAlertView

class MyAlertView {
    
    //Show alert with custom message and Cancel button
    class func showWarningAlertWithCancelOnly(message:String) {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false,
            shouldAutoDismiss: true
        )
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("Cancel", action: { () -> Void in })
        
        alert.showWarning("Warning", subTitle: message)
    }
    
    
    //Show alert which will auto dismiss in 1 sec. Has no buttons at all
    class func showInformationAlertWithoutButtons(message:String)
    {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alert = SCLAlertView(appearance: appearance)
        
        
        let alertViewResponder: SCLAlertViewResponder = alert.showInfo("", subTitle: message)
        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when){
            // your code with delay
            alertViewResponder.close()
        }
    }
    
    class func showInformationAlert(message:String)
    {
        SCLAlertView().showInfo("", subTitle: message)
    }
}
