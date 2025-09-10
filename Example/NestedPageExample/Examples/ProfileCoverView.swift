//
//  ProfileCoverView.swift
//  NestedPageViewController
//
//  Created by 乐升平 on 2025/8/29.
//

import UIKit

// 自定义封面视图类
class ProfileCoverView: UIView {
    
    let avatarImageView = UIImageView()
    let nameLabel = UILabel()
    let bioLabel = UILabel()
    let bgImageView = UIImageView()
    
    var bgImageViewFrame: CGRect = .zero {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
                
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        backgroundColor = .systemBackground
        
        // 背景图片
        bgImageView.image = UIImage(named: "meigui")
        bgImageView.contentMode = .scaleAspectFill
        // 一定要设置裁剪，否则.scaleAspectFill模式会超出图片区域
        bgImageView.layer.masksToBounds = true
        addSubview(bgImageView)
        
        // 头像
        avatarImageView.backgroundColor = .white
        avatarImageView.layer.cornerRadius = 40
        avatarImageView.layer.masksToBounds = true
        avatarImageView.contentMode = .center
        let cameraImage = UIImage(systemName: "camera.fill")
        avatarImageView.image = cameraImage
        avatarImageView.tintColor = .systemGray
        avatarImageView.isUserInteractionEnabled = true
        addSubview(avatarImageView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(bgImageViewTapped))
        avatarImageView.addGestureRecognizer(tapGesture)
        
        // 用户名
        nameLabel.text = "用户名"
        nameLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        nameLabel.textColor = .white
        nameLabel.textAlignment = .center
        addSubview(nameLabel)
        
        // 简介
        bioLabel.text = "这是一个用户的个人简介"
        bioLabel.font = UIFont.systemFont(ofSize: 14)
        bioLabel.textColor = .white
        bioLabel.textAlignment = .center
        bioLabel.numberOfLines = 0
        addSubview(bioLabel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        if bgImageViewFrame != .zero {
            bgImageView.frame = bgImageViewFrame
        } else {
            bgImageView.frame = bounds
        }
        
        // 头像
        let avatarSize: CGFloat = 80
        avatarImageView.frame = CGRect(
            x: (bounds.width - avatarSize) / 2,
            y: 60,
            width: avatarSize,
            height: avatarSize
        )
        
        // 用户名
        let nameLabelHeight: CGFloat = 24
        nameLabel.frame = CGRect(
            x: 20,
            y: avatarImageView.frame.maxY + 16,
            width: bounds.width - 40,
            height: nameLabelHeight
        )
        
        // 简介
        let bioLabelHeight: CGFloat = 20
        bioLabel.frame = CGRect(
            x: 20,
            y: nameLabel.frame.maxY + 8,
            width: bounds.width - 40,
            height: bioLabelHeight
        )
    }
    
    // MARK: - 点击事件处理
    @objc private func bgImageViewTapped() {
        // 寻找当前视图的视图控制器
        if let viewController = findViewController() {
            let alertController = UIAlertController(
                title: "相机按钮被点中了",
                message: "",
                preferredStyle: .alert
            )
            
            let okAction = UIAlertAction(title: "好的", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            viewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    // 辅助方法：寻找当前视图的视图控制器
    private func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            responder = responder?.next
            if let viewController = responder as? UIViewController {
                return viewController
            }
        }
        return nil
    }

}
