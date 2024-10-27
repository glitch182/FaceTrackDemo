//
//  VisionKitViewController.swift
//  FaceTrackDemo
//
//  Created by Vishal Chandran on 26/10/24.
//

import UIKit
import AVFoundation
import Vision

class VisionKitViewController: BaseViewController {

    // MARK: - IBOutlets

    @IBOutlet weak var previewView: UIView!

    // MARK: - Properties

    private var captureSession: AVCaptureSession!

    // MARK: - View Life Cycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }

    deinit {
        captureSession.stopRunning()
        captureSession = nil
    }

    // MARK: - Private Methods

    private func setupCamera() {
        captureSession = AVCaptureSession()
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front)

        if let device = deviceDiscoverySession.devices.first {
            if let deviceInput = try? AVCaptureDeviceInput(device: device) {
                if captureSession.canAddInput(deviceInput) {
                    captureSession.addInput(deviceInput)
                }
            }
        }

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "com.vishalchandran.FaceTrackDemo.queue.videoOutput"))

        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }

        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }

        let rotationAngle: CGFloat = 270 // Portrait orientation
        guard let connection = videoOutput.connection(with: .video),
              connection.isVideoRotationAngleSupported(rotationAngle) else { return }
        connection.videoRotationAngle = rotationAngle
    }

    private func detectFaceLandmarks(from sampleBuffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let request = VNDetectFaceLandmarksRequest { (request, error) in
            if let results = request.results as? [VNFaceObservation] {
                self.drawFaceLandmarks(results)
            }
        }

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Error performing request: \(error)")
        }
    }

    private func drawFaceLandmarks(_ faceObservations: [VNFaceObservation]) {
        DispatchQueue.main.async {
            self.previewView.layer.sublayers?.removeAll()

            for face in faceObservations {
                if let landmarks = face.landmarks {
                    self.drawLandmarks(landmarks, for: face)
                }
            }
        }
    }

    private func drawLandmarks(_ landmarks: VNFaceLandmarks2D, for face: VNFaceObservation) {
        let faceBounds = face.boundingBox
        let width = self.previewView.bounds.width
        let height = self.previewView.bounds.height

        let scaleX = width
        let scaleY = height

        let landmarksToDraw = [landmarks.faceContour,
                               landmarks.leftEyebrow,
                               landmarks.rightEyebrow,
                               landmarks.leftEye,
                               landmarks.rightEye,
                               landmarks.noseCrest,
                               landmarks.nose,
                               landmarks.outerLips,
                               landmarks.innerLips]

        for landmark in landmarksToDraw {
            guard let landmark else { return }
            let path = CGMutablePath()
            let drawPoints = landmark.normalizedPoints.map({ drawPoint in
                CGPoint(x: faceBounds.origin.x * scaleX + drawPoint.x * faceBounds.size.width * scaleX,
                        y: faceBounds.origin.y * scaleY + drawPoint.y * faceBounds.size.height * scaleY)
            })
            path.addLines(between: drawPoints)
            path.closeSubpath()

            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.strokeColor = UIColor.red.cgColor

            self.previewView.layer.addSublayer(shapeLayer)
        }
    }
}

extension VisionKitViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        detectFaceLandmarks(from: sampleBuffer)
    }
}
