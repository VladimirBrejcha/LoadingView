//
//  NibLoadable.swift
//  
//
//  Created by Владимир Королев on 21.03.2020.
//

import UIKit

protocol NibLoadable {
    static var nibName: String { get }
}

extension NibLoadable where Self: UIView {
    static var nibName: String {
        String(describing: Self.self)
    }

    static private var nib: UINib {
        UINib(nibName: Self.nibName, bundle: Bundle(for: Self.self))
    }

    func setupFromNib() {
        guard let view = Self.nib.instantiate(withOwner: self, options: nil).first as? Self
            else {
                fatalError("Error loading \(self) from nib")
        }
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        view.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
    }
}
