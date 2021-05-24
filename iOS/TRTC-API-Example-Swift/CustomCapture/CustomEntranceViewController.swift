//
//  RTCEntranceViewController.swift
//  TRTCSimpleDemo
//
//  Copyright © 2020 Tencent. All rights reserved.
//

import UIKit

class CustomEntranceViewController: UIViewController, QBImagePickerControllerDelegate {
    
    @IBOutlet weak var roomIdTextField: UITextField!
    @IBOutlet weak var userIdTextField: UITextField!
    public var localVideoAsset: AVAsset?

    override func viewDidLoad() {
        super.viewDidLoad()
        roomIdTextField.text = "1256732"
        userIdTextField.text = "\(UInt32(CACurrentMediaTime() * 1000))"
        
        let sel = #selector(CustomEntranceViewController.onTapGestureAction(_:))
        let tapGesture = UITapGestureRecognizer.init(target: self, action: sel)
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction func onEnterRoom(_ sender: UIButton) {
        let imagePicker = QBImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsMultipleSelection = false
        imagePicker.showsNumberOfSelectedAssets = true
        imagePicker.minimumNumberOfSelection = 1
        imagePicker.maximumNumberOfSelection = 1
        imagePicker.mediaType = .video
        imagePicker.title = "请选择视频"
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.pushViewController(imagePicker, animated: true)
    }
    
    @objc func enterCustomCaptureRoom(_ localVideoAsset:AVAsset? = nil) {
        let storyboard = UIStoryboard.init(name: "CustomCapture", bundle: nil);
        guard let ccVC = storyboard.instantiateViewController(withIdentifier: "CustomCaptureViewController") as? CustomCaptureViewController else {
            return
        }
        ccVC.roomId = UInt32(roomIdTextField.text ?? "1256732")
        ccVC.userId = userIdTextField.text ?? "\(UInt32(CACurrentMediaTime() * 1000))"
        ccVC.localVideoAsset = localVideoAsset
        self.navigationController?.pushViewController(ccVC, animated: true)
    }
    
    /// 隐藏键盘
    @objc func onTapGestureAction(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    //delegate QBImagePickerControllerDelegate
    @objc func qb_imagePickerController(_ imagePickerController: QBImagePickerController!, didFinishPickingAssets assets: [Any]!) {
        self.navigationController?.popViewController(animated: false)
        
        let options = PHVideoRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        PHImageManager.default().requestAVAsset(forVideo: assets.first as! PHAsset, options: options) { [weak self](asset, audiomix, info) in
            DispatchQueue.main.async {
                self?.enterCustomCaptureRoom(asset)
            }
        }
    }
    
    @objc func qb_imagePickerControllerDidCancel(_ imagePickerController: QBImagePickerController!) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.popViewController(animated: true);
    }
}
