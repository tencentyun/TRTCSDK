//
//  TRTCMeetingMoreViewShareVC.swift
//  TRTCScenesDemo
//
//  Created by J J on 2020/5/15.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import UIKit

class TRTCMeetingMoreViewShareVC: UIViewController {
    // 生成QRCode
    class func qrCode(with string: String?, size outputSize: CGSize) -> UIImage? {
        let data = string?.data(using: .utf8)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("Q", forKey: "inputCorrectionLevel")
        let qrCodeImage = filter?.outputImage
        let imageSize = qrCodeImage?.extent.integral
        let ciImage = qrCodeImage?.transformed(by: CGAffineTransform(scaleX: outputSize.width / imageSize!.width, y: outputSize.height / imageSize!.height))
        if let ciImage = ciImage {
            return UIImage(ciImage: ciImage)
        }
        return nil
    }
    
    // 分享按钮
    lazy var shareButton: UIButton = {
        let button = UIButton(frame: CGRect(x: UIScreen.main.bounds.size.width / 5.0*2, y: UIScreen.main.bounds.size.height / 3.0*0.7, width: UIScreen.main.bounds.size.width / 5.0, height: 30))
        
        button.setTitle(.shareText, for: .normal)
        button.backgroundColor = .buttonBackColor
        button.titleLabel?.textColor = .black
        button.contentHorizontalAlignment = .center
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(shareQRCode), for: .touchUpInside)
        
        return button
    }()
    
    @objc func shareQRCode() {
        let str = TRTCMeeting.sharedInstance().getLiveBroadcastingURL()
        let string = [str]
        let ac = UIActivityViewController(activityItems: string as [Any], applicationActivities: nil)
        present(ac, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 二维码
        let image = TRTCMeetingMoreViewShareVC.qrCode(with: TRTCMeeting.sharedInstance().getLiveBroadcastingURL(), size: CGSize(width: 100, height: 100))
        let imageView = UIImageView()
        imageView.image = image
        imageView.frame = CGRect(x: UIScreen.main.bounds.size.width / 3.0, y: UIScreen.main.bounds.size.width / 667 * 15, width: UIScreen.main.bounds.size.width / 3.0, height: UIScreen.main.bounds.size.width / 3.0)
        self.view.addSubview(imageView)
        self.view.addSubview(shareButton)
        // Do any additional setup after loading the view.
    }

}

/// MARK: - internationalization string
fileprivate extension String {
    static let shareText = TRTCLocalize("Demo.TRTC.Meeting.share")
}
