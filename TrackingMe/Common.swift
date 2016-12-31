//
//  Common.swift
//  TrackingMe
//
//  Created by chaoyee on 2016/12/7.
//  Copyright © 2016年 charleshsu.co. All rights reserved.
//

import Foundation
import FirebaseDatabase

var ref: FIRDatabaseReference! = FIRDatabase.database().reference()

var userID   : String = ""
var username : String = ""
var lati     : NSNumber =  25.013515
var long     : NSNumber = 121.536841 


struct Location {
    let userID:   String
    let username: String
    let lati:     Double
    let long:     Double
}

extension Double {
    /// Rounds the double to decimal places value
    func roundTo(_ places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        let temp = self * divisor
        // return (self * divisor).rounded() / divisor
        return (temp.rounded() / divisor)
    }
}
