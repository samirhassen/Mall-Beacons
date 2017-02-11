//
//  ViewController.swift
//

import UIKit
import CoreLocation
import CoreBluetooth
import AVKit
import AVFoundation
import AudioToolbox
import KontaktSDK
//import UserNotifications

class ViewController: UIViewController,CBPeripheralManagerDelegate {

    @IBOutlet weak var myImg: UIImageView!
    var beaconManager: KTKBeaconManager!
    var player: AVAudioPlayer?

//    var isGrantedNotificationAccess:Bool = false


    //Playes the video until users clicks DONE
    @IBAction func playVideo() {
        guard let path = NSBundle.mainBundle().URLForResource("nature1", withExtension: "mp4") else {
            debugPrint("video not found")
            return
        }
        let player = AVPlayer(URL: path)
        let playerController = AVPlayerViewController()
        playerController.player = player
        presentViewController(playerController, animated: true) {
            player.play()
        }
    }

    @IBAction func playSound() {
        let url = NSBundle.mainBundle().URLForResource("tin", withExtension: "mp3")!
        
        do {
            player = try AVAudioPlayer(contentsOfURL: url)
            guard let player = player else { return }
            
            player.prepareToPlay()
            player.play()
        } catch let error as NSError {
            print(error.description)
        }
    }

    
    override func viewDidLoad() {
/*      UNUserNotificationCenter.currentNotificationCenter().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.currentNotificationCenter().requestAuthorizationWithOptions([.Alert, .Sound]) { (granted,error) in
                self.isGrantedNotificationAccess = granted
            }
*/
        super.viewDidLoad()
        myImg.autoresizingMask = [.FlexibleWidth, .FlexibleHeight, .FlexibleBottomMargin, .FlexibleRightMargin, .FlexibleLeftMargin, .FlexibleTopMargin]
        myImg.contentMode = .ScaleAspectFit // OR .scaleAspectFill
        myImg.clipsToBounds = true
        
        // Initiate Beacon Manager
        beaconManager = KTKBeaconManager(delegate: self)
        beaconManager.requestLocationAlwaysAuthorization()
        
        // Region
        let proximityUUID = NSUUID(UUIDString: "f7826da6-4fa2-4e98-8024-bc5b71e0893e")
        let region = KTKBeaconRegion(proximityUUID: proximityUUID!, identifier: "region-identifier")
        
        //let region = KTKBeaconRegion(proximityUUID: proximityUUID!, major: 101, identifier: "region-identifier-M")
        //let region = KTKBeaconRegion(proximityUUID: proximityUUID!, major: 31775, minor: 58421, identifier: "region-identifier-M-m")
        
        //let secureProximityUUID = NSUUID(UUIDString: "f7826da6-4fa2-4e98-8024-bc5b71e0893e")
        //let secureRegion = KTKSecureBeaconRegion(secureProximityUUID: secureProximityUUID!, identifier: "region-identifier")
        
        // Region Properties
        region.notifyEntryStateOnDisplay = true
        
        //beaconManager.stopMonitoringForAllRegions()
        
        // Start Ranging
        beaconManager.startRangingBeaconsInRegion(region)
        beaconManager.startMonitoringForRegion(region)
        beaconManager.requestStateForRegion(region)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        
        if peripheral.state == .PoweredOff {
            simpleAlert("Beacon", message: "Turn On Your Device Bluetooh")
        }
    }
    
    func simpleAlert(title:String,message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
 
        let defaultAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
}

extension ViewController: KTKBeaconManagerDelegate {
    
    func beaconManager(manager: KTKBeaconManager, didDetermineState state: CLRegionState, forRegion region: KTKBeaconRegion) {
        print("Did determine state \"\(state.rawValue)\" for region: \(region)")
    }
    
    func beaconManager(manager: KTKBeaconManager, didChangeLocationAuthorizationStatus status: CLAuthorizationStatus) {
        print("Did change location authorization status to: \(status.rawValue)")
    }
    
    func beaconManager(manager: KTKBeaconManager, monitoringDidFailForRegion region: KTKBeaconRegion?, withError error: NSError?) {
        print("Monitoring did fail for region: \(region)")
        print("Error: \(error)")
    }
    
    func beaconManager(manager: KTKBeaconManager, didStartMonitoringForRegion region: KTKBeaconRegion) {
        print("Did start monitoring for region: \(region)")
        
        // Request State
        manager.requestStateForRegion(region)
    }
    
    func beaconManager(manager: KTKBeaconManager, didEnterRegion region: KTKBeaconRegion) {
        print("Did enter region: \(region)")
        
        manager.startRangingBeaconsInRegion(region)
    }
    
    func beaconManager(manager: KTKBeaconManager, didExitRegion region: KTKBeaconRegion) {
        print("Did exit region \(region)")
        
        self.myImg.image = nil
    }
    
    
    func beaconManager(manager: KTKBeaconManager, didRangeBeacons beacons: [CLBeacon], inRegion region: KTKBeaconRegion) {
        print("Did ranged \"\(beacons.count)\" beacons inside region: \(region)")
        
        if let closestBeacon = beacons.sort({ $0.0.accuracy < $0.1.accuracy }).first where closestBeacon.accuracy < 1 {
            print("Closest Beacon is M: \(closestBeacon.major), m: \(closestBeacon.minor) ~ \(closestBeacon.accuracy) meters away")
            
            switch closestBeacon.major {
            case 23932: //DgrG
                self.myImg.image = UIImage(named: "pic1")
                self.view.backgroundColor = UIColor.blueColor()
            case 44308: // Ar8L
                self.myImg.image = UIImage(named: "pic2")
                self.view.backgroundColor = UIColor.brownColor()
                //playSound()
            case 31775: // k77n
                self.myImg.image = UIImage(named: "pic3")!
                self.view.backgroundColor = UIColor.greenColor()
                playSound()
            case 7022: // CTSx
                self.myImg.image = UIImage(named: "pic4")!
                self.view.backgroundColor = UIColor.greenColor()
            case 64719: // 458g
                self.myImg.image = UIImage(named: "pic5")!
            default:
                self.myImg.image = UIImage(named: "pic6")!
                self.view.backgroundColor = UIColor.darkGrayColor()
            }
        }
    }
    
}
