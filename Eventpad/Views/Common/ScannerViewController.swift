//
//  ScannerViewController.swift
//  Eventpad
//
//  Created by Oleg Samoylov on 09.05.2020.
//  Copyright © 2020 Oleg Samoylov. All rights reserved.
//

import AVFoundation
import UIKit

final class ScannerViewController: UIViewController {
    
    private let requestSender = RequestSender()
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Валидация билета"
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            failed()
            return
        }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            failed()
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }

    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        } else {
            dismiss(animated: true)
        }
    }

    func found(code: String) {
        if code.starts(with: "eventpad://ticket?id=") {
            let id = code.split(separator: "=")[1]
            let config = RequestFactory.ticket(ticketID: String(id))
            requestSender.send(config: config) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let ticket):
                    let string = """
                    Данный билет успешно проверен на подлинность, участник имеет право на посещение конференции
                    Выпущен: \(ticket.released)
                    ID участника: \(ticket.buyerID)
                    ID тарифа: \(ticket.tariffID)
                    """
                    let alert = AlertService().alert(string, title: .info)
                    self.present(alert, animated: true)
                    
                case .failure:
                    return
                }
            }
        } else {
            let alert = AlertService().alert("Участник мог оказаться жертвой мошенничества: его копия билета не является подлинной", title: .attention)
            self.present(alert, animated: true)
        }
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}


// MARK: - AVCaptureMetadataOutputObjectsDelegate

extension ScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    
}
