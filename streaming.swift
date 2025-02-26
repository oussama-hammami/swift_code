import AVFoundation
import Vision
import CoreML
import SwiftUI
import MetalKit

class VideoUpscaler: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private let mlModel: VNCoreMLModel
    private let videoOutput = AVCaptureVideoDataOutput()
    private let session = AVCaptureSession()
    private let metalDevice = MTLCreateSystemDefaultDevice()
    private let metalCommandQueue: MTLCommandQueue?
    
    override init() {
        do {
            let modelConfig = MLModelConfiguration()
            modelConfig.computeUnits = .all // Optimized for GPU
            let model = try ESRGCNN_4x_ct_model(configuration: modelConfig) // Load CoreML model
            mlModel = try VNCoreMLModel(for: model.model)
        } catch {
            fatalError("Failed to load CoreML model: \(error)")
        }
        
        metalCommandQueue = metalDevice?.makeCommandQueue()
        
        super.init()
        setupVideoCapture()
    }
    
    private func setupVideoCapture() {
        session.sessionPreset = .high
        guard let videoDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            print("Error setting up video input")
            return
        }
        session.addInput(videoInput)
        
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        session.addOutput(videoOutput)
        session.startRunning()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let request = VNCoreMLRequest(model: mlModel) { request, error in
            guard let results = request.results as? [VNPixelBufferObservation],
                  let upscaledBuffer = results.first?.pixelBuffer else { return }
            
            DispatchQueue.main.async {
                // Process the upscaledBuffer (e.g., display it using Metal)
            }
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([request])
    }
}

struct ContentView: View {
    var body: some View {
        Text("Live Video Upscaling")
    }
}

@main
struct UpscaleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}