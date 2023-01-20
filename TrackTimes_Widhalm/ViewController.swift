//
//  ViewController.swift
//  TrackTimes_Widhalm
//
//  Created by MAX WIDHALM on 1/17/23.
//

import UIKit
import FirebaseCore
import FirebaseDatabase

class Time {
    var ref = Database.database().reference()
    
    var name : String
    var time : Double
    var key = ""
    
    init(name: String, event: String, time: Double) {
        self.name = name
        self.time = time
    }
    
    init(dict: [String: Any]) {
        if let n = dict["name"] as? String {
            name = n
        } else {
            name = "James"
        }
        if let t = dict["time"] as? Double {
            time = t
        } else {
            time = 52.86
        }
        
    }
    
    func saveToFirebase() {
        var dict = ["name" : name, "time" : time] as [String: Any]
        key = ref.child("times").childByAutoId().key ?? "0"
        ref.child("times").child(key).setValue(dict)
        
    }
    
    func deleteFromFirebase() {
        ref.child("times").child(key).removeValue()
    }
    
    func updateFirebase() {
        let dict = ["name" : name, "time" : time] as [String : Any]
        ref.child("times").child(key).updateChildValues(dict)
    }
    
    func equals(time: Time)->Bool {
        if time.name == name && time.time == self.time {
            return true
        }
        return false
    }
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    var ref: DatabaseReference!
    var times = [Time]()
    var lastTime = Time(dict: ["name": "", "time": 0.0])
    
    
    
    @IBOutlet weak var nameOutlet: UITextField!
    @IBOutlet weak var timeOutlet: UITextField!
    @IBOutlet weak var tableViewOutlet: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewOutlet.dataSource = self
        tableViewOutlet.delegate = self
        
        ref = Database.database().reference()
        ref.child("times").observe(.childAdded) { snapshot in
            var dict = snapshot.value as! [String : Any]
            var time = Time(dict: dict)
            time.key = snapshot.key
            if !(self.lastTime.equals(time: time)) {
                self.times.append(time)
                self.tableViewOutlet.reloadData()

            }
        }
        
        ref.child("times").observe(.childRemoved) { snapshot in
            for i in 0..<self.times.count {
                if self.times[i].key == snapshot.key {
                    self.times.remove(at: i)
                    self.tableViewOutlet.reloadData()
                    break
                }
            }
        }
    }
        
        @IBAction func addAction(_ sender: UIButton) {
            print("YOOOO")
            let name = nameOutlet.text!
            let time = Double(timeOutlet.text!)!
            var timmy = Time(dict: ["name":name, "time":time])
            timmy.saveToFirebase()
            tableViewOutlet.reloadData()
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return times.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableViewOutlet.dequeueReusableCell(withIdentifier: "myCell")!
            cell.textLabel?.text = times[indexPath.row].name
            cell.detailTextLabel?.text = String(times[indexPath.row].time)
            return cell
        }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            times[indexPath.row].deleteFromFirebase()
            times.remove(at: indexPath.row)
            tableViewOutlet.reloadData()
        }
    }
    
}
