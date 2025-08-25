//
//  PermissionsViewModel.swift
//  LiftAI
//
//  Created by Rodney Gainous Jr on 8/25/25.
//

import Foundation
import Photos
import AVFoundation
import CoreLocation
import Combine

@MainActor
final class PermissionsViewModel: NSObject, ObservableObject {

    enum Status { case unknown, granted, denied }

    @Published var locationStatus: Status = .unknown
    @Published var photosStatus: Status = .unknown
    @Published var cameraStatus: Status = .unknown
    @Published var manualConfirmInGym: Bool = false

    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        refreshStatuses()
    }

    func refreshStatuses() {
        // Location
        switch locationManager.authorizationStatus {
        case .notDetermined: locationStatus = .unknown
        case .authorizedWhenInUse, .authorizedAlways: locationStatus = .granted
        case .denied, .restricted: locationStatus = .denied
        @unknown default: locationStatus = .unknown
        }
        // Photos
        let ph = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch ph {
        case .notDetermined: photosStatus = .unknown
        case .authorized, .limited: photosStatus = .granted
        case .denied, .restricted: photosStatus = .denied
        @unknown default: photosStatus = .unknown
        }
        // Camera
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined: cameraStatus = .unknown
        case .authorized: cameraStatus = .granted
        case .denied, .restricted: cameraStatus = .denied
        @unknown default: cameraStatus = .unknown
        }
    }

    func requestLocation() { locationManager.requestWhenInUseAuthorization() }
    func requestPhotos() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] _ in
            Task { @MainActor in self?.refreshStatuses() }
        }
    }
    func requestCamera() {
        AVCaptureDevice.requestAccess(for: .video) { _ in
            Task { @MainActor in self.refreshStatuses() }
        }
    }

    var canContinue: Bool {
        let photosOK = photosStatus == .granted || cameraStatus == .granted
        let locationOK = locationStatus == .granted || manualConfirmInGym
        return photosOK && locationOK
    }
}

extension PermissionsViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        refreshStatuses()
    }
}
