//
//  ContentView.swift
//  BeaconDetectoriOS13
//
//  Created by Vlastimir on 6/15/19.
//  Copyright © 2019 Vlastimir. All rights reserved.
//

import Combine
import CoreLocation
import SwiftUI

class BeaconDetector: NSObject, ObservableObject, CLLocationManagerDelegate {
    var didChange = PassthroughSubject<Void, Never>()
    var locationManager: CLLocationManager?
    var lastDistance = CLProximity.unknown
    
    override init() {
        super.init()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }
    
    func startScanning() {
        let uuid = UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5")!
        let constraint = CLBeaconIdentityConstraint(uuid: uuid, major: 123, minor: 456)
        let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: "MyBeacon")
        
        locationManager?.startMonitoring(for: beaconRegion)
        locationManager?.startRangingBeacons(satisfying: constraint)
    }
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        guard let beacon = beacons.first else {
            update(distance: .unknown)
            return
        }
        update(distance: beacon.proximity)
    }
    
    func update(distance: CLProximity) {
        lastDistance = distance
        didChange.send(())
    }
}

struct BigText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(Font.system(size: 72, design: .rounded))
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
}

struct ContentView : View {
    @ObservedObject var detector = BeaconDetector()
    
    var body: some View {
        if detector.lastDistance == .immediate {
            return Text("RIGHT HERE")
                .modifier(BigText())
                .background(Color.red)
                .edgesIgnoringSafeArea(.all)
        } else if detector.lastDistance == .near {
            return Text("NEAR")
                .modifier(BigText())
                .background(Color.orange)
                .edgesIgnoringSafeArea(.all)
        } else if detector.lastDistance == .far {
            return Text("FAR")
                .modifier(BigText())
                .background(Color.blue)
                .edgesIgnoringSafeArea(.all)
        } else {
            return Text("UNKNOWN")
                .modifier(BigText())
                .background(Color.gray)
                .edgesIgnoringSafeArea(.all)
        }
        
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
