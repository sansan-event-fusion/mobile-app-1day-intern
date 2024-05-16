//
//  BizCardCaptureViewController.swift
//  SansanOneDay
//
//  Created by Tomoki Hirayama on 2024/05/02.
//

import AVFoundation
import UIKit

// TODO: 名刺の矩形認識による自動クロップを実装する
// TODO: アルバムから画像を選択できるようにする。(矩形認識ができた場合は、アルバムからの選択時にも自動でクロップされたい)
final class BizCardCaptureViewController: UIViewController {
    @IBOutlet private weak var capturePreviewView: UIView!
    @IBOutlet private weak var captureFrameView: UIView! {
        didSet {
            captureFrameView.layer.borderWidth = 4
            captureFrameView.layer.borderColor = R.color.brand.productBlue()!.cgColor
        }
    }

    @IBOutlet private weak var captureShutterButton: UIButton! {
        didSet {
            captureShutterButton.addAction(.init(handler: { [weak self] _ in
                self?.shutter()
            }), for: .touchUpInside)
        }
    }

    @IBOutlet private weak var closeButton: UIButton! {
        didSet {
            closeButton.addAction(.init(handler: { [weak self] _ in
                self?.viewModel.input.tappedClose.send(())
            }), for: .touchUpInside)
        }
    }

    private var captureSession: AVCaptureSession!
    private var captureDevice: AVCaptureDevice!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var photoOutput: AVCapturePhotoOutput!

    var viewModel: BizCardCaptureViewModelInterface!

    init() {
        super.init(nibName: R.nib.bizCardCaptureViewController.name, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCaptureSession()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        viewModel.input.viewAppear.send(())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startCaptureSession()
    }

    override func viewDidDisappear(_ animated: Bool) {
        stopCaptureSession()
    }
}

extension BizCardCaptureViewController {
    private func configureCaptureSession() {
        captureSession = AVCaptureSession()
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        self.captureDevice = captureDevice
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
        } catch {
            return
        }
        photoOutput = AVCapturePhotoOutput()
        captureSession.addOutput(photoOutput)
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspect
        previewLayer.frame = capturePreviewView.bounds
        capturePreviewView.layer.addSublayer(previewLayer)
    }

    private func startCaptureSession() {
        guard !captureSession.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            captureSession.startRunning()
            do {
                try captureDevice.lockForConfiguration()
                captureDevice.focusMode = .continuousAutoFocus
                captureDevice.autoFocusRangeRestriction = .near
                captureDevice.torchMode = .auto
                captureDevice.unlockForConfiguration()
            } catch {
                return
            }
        }
    }

    private func stopCaptureSession() {
        guard captureSession.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            self.captureSession.stopRunning()
        }
    }

    private func shutter() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

extension BizCardCaptureViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        guard let image = UIImage(data: imageData) else { return }
        guard let croppedImage = cropToPreviewLayer(from: image, toSizeOf: captureFrameView.frame) else { return }
        viewModel.input.captureShot.send(croppedImage)
    }

    /// 画面に表示されているPreviewを基準に指定されたクロップ領域で切り抜く、出力されるImageは撮影時の右辺が上になるように-90度回転される
    private func cropToPreviewLayer(from originalImage: UIImage, toSizeOf rect: CGRect) -> UIImage? {
        guard let cgImage = originalImage.cgImage else { return nil }

        // This previewLayer is the AVCaptureVideoPreviewLayer which the resizeAspectFill and videoOrientation portrait has been set.
        let outputRect = previewLayer.metadataOutputRectConverted(fromLayerRect: rect)
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        let cropRect = CGRect(x: outputRect.origin.x * width, y: outputRect.origin.y * height, width: outputRect.size.width * width, height: outputRect.size.height * height)

        if let croppedCGImage = cgImage.cropping(to: cropRect) {
            return UIImage(cgImage: croppedCGImage, scale: 1.0, orientation: .up)
        }

        return nil
    }
}
