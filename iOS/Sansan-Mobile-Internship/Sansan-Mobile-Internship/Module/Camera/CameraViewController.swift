//
//  CameraViewController.swift
//  Sansan-Mobile-Internship
//
//  Created by Tomoki Hirayama on 2023/07/24.
//  Copyright © 2023 Sansan. All rights reserved.
//

import AVFoundation
import RxCocoa
import RxSwift
import SVProgressHUD
import UIKit

final class CameraViewController: UIViewController {
    @IBOutlet private weak var cameraPreview: UIView!
    @IBOutlet private weak var captureFrameView: UIView!
    @IBOutlet private weak var shutterButton: UIButton!
    @IBOutlet private weak var closeButton: UIButton!

    private var captureSession: AVCaptureSession!
    private var captureDevice: AVCaptureDevice!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var photoOutput: AVCapturePhotoOutput!

    private let disposeBag = DisposeBag()

    var viewModel: CameraViewModelInterface!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setupCaptureSession()
        binding()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        viewModel.input.viewWillAppear.accept(())
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.input.viewWillDisappear.accept(())
    }
}

private extension CameraViewController {
    func configureView() {
        captureFrameView.layer.borderColor = AppConstants.Color.sansanBlue.cgColor
        captureFrameView.layer.borderWidth = 5
    }

    func binding() {
        shutterButton.rx
            .tap
            .subscribe(with: self) { owner, _ in
                owner.viewModel.input.shutterButtonTapped.accept(())
            }
            .disposed(by: disposeBag)

        closeButton.rx
            .tap
            .subscribe(with: self) { owner, _ in
                owner.viewModel.input.closeButtonTapped.accept(())
            }
            .disposed(by: disposeBag)

        viewModel.output
            .shootCamera
            .asDriver(onErrorDriveWith: .empty())
            .drive(with: self) { owner, _ in
                owner.shutter()
            }
            .disposed(by: disposeBag)

        viewModel.output
            .startCaptureSession
            .asDriver(onErrorDriveWith: .empty())
            .drive(with: self) { owner, _ in
                owner.startCaptureSession()
            }
            .disposed(by: disposeBag)

        viewModel.output
            .stopCaptureSession
            .asDriver(onErrorDriveWith: .empty())
            .drive(with: self) { owner, _ in
                owner.stopCaptureSession()
            }
            .disposed(by: disposeBag)
    }

    func setupCaptureSession() {
        SVProgressHUD.show()
        captureSession = AVCaptureSession()
        // MEMO: 端末によっては使うカメラを変える
        guard let backCamera = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) else {
            fatalError("Unable to access the back camera.")
        }
        captureDevice = backCamera

        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            captureSession.addInput(input)

            photoOutput = AVCapturePhotoOutput()
            if captureSession.canAddOutput(photoOutput) {
                captureSession.sessionPreset = .hd1920x1080
                captureSession.addOutput(photoOutput)

                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.connection?.videoOrientation = .portrait
                cameraPreview.layer.addSublayer(previewLayer)
                previewLayer.frame = cameraPreview.bounds
            }
        } catch {
            fatalError("Error setting up capture session: \(error.localizedDescription)")
        }
        SVProgressHUD.dismiss()
    }

    func startCaptureSession() {
        guard !captureSession.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
            let input = self?.captureDevice
            do {
                input?.focusMode = .continuousAutoFocus
                input?.isSmoothAutoFocusEnabled = true
                input?.autoFocusRangeRestriction = .near
                try input?.setTorchModeOn(level: 1.0)
                input?.torchMode = .on
            } catch {
                self?.stopCaptureSession()
            }
        }
    }

    func stopCaptureSession() {
        guard captureSession.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.stopRunning()
        }
    }

    func shutter() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        settings.isHighResolutionPhotoEnabled = false
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if error != nil { return }
        guard let imageData = photo.fileDataRepresentation() else { return }
        // 撮影した写真をPreviewの青枠に沿って切り取る
        if let capturedImage = UIImage(data: imageData) {
            let width = cameraPreview.frame.width
            let height = cameraPreview.frame.height
            guard let image = cropAndFixImage(capturedImage, toRect: captureFrameView.frame, viewWidth: width, viewHeight: height) else { return }
            viewModel.input.captured.accept(image)
        }
    }

    // 撮影時のPreviewの大きさを画像の大きさとして比率を出し､その比率を元に青枠の大きさを画像にあわせて切り取りを行う
    private func cropAndFixImage(_ inputImage: UIImage, toRect cropRect: CGRect, viewWidth: CGFloat, viewHeight: CGFloat) -> UIImage? {
        let imageViewScale = min(inputImage.size.width / viewWidth,
                                 inputImage.size.height / viewHeight)

        // CGImageは向き情報を持たないため､90度回転した座標に変換する
        // 状態としては UIImage(縦向き) top, CGImage(横向き) となっている
        let cropZone = CGRect(x: cropRect.origin.y * imageViewScale,
                              y: cropRect.origin.x * imageViewScale + 100, // 位置合わせ (超絶ハードコーディング)
                              width: cropRect.size.height * imageViewScale,
                              height: cropRect.size.width * imageViewScale)

        // Perform cropping in Core Graphics
        guard let cutImageRef: CGImage = inputImage.cgImage?.cropping(to: cropZone)
        else {
            return nil
        }

        // 作成したUIImageには再度向き情報が付与されるが､CGImage(横向き)がtopとして保存される
        // 状態としては UIImage(横向き) top, CGImage(横向き) となる
        let croppedImage = UIImage(cgImage: cutImageRef)
        return croppedImage
    }
}
