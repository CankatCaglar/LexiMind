import UIKit
import SnapKit

extension UIView {
    func addSubviewWithConstraints(_ view: UIView, insets: UIEdgeInsets = .zero) {
        addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(insets)
        }
    }
    
    func centerInSuperview(size: CGSize? = nil) {
        guard let superview = superview else { return }
        
        snp.makeConstraints { make in
            make.center.equalToSuperview()
            if let size = size {
                make.size.equalTo(size)
            }
        }
    }
    
    func fillSuperview(padding: UIEdgeInsets = .zero) {
        guard let superview = superview else { return }
        
        snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(padding)
        }
    }
    
    func anchorToTop(padding: UIEdgeInsets = .zero) {
        guard let superview = superview else { return }
        
        snp.makeConstraints { make in
            make.top.equalToSuperview().offset(padding.top)
            make.left.equalToSuperview().offset(padding.left)
            make.right.equalToSuperview().offset(-padding.right)
        }
    }
    
    func anchorToBottom(padding: UIEdgeInsets = .zero) {
        guard let superview = superview else { return }
        
        snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-padding.bottom)
            make.left.equalToSuperview().offset(padding.left)
            make.right.equalToSuperview().offset(-padding.right)
        }
    }
    
    func setSize(_ size: CGSize) {
        snp.makeConstraints { make in
            make.size.equalTo(size)
        }
    }
    
    func setHeight(_ height: CGFloat) {
        snp.makeConstraints { make in
            make.height.equalTo(height)
        }
    }
    
    func setWidth(_ width: CGFloat) {
        snp.makeConstraints { make in
            make.width.equalTo(width)
        }
    }
} 