//
//  CollectionViewCell.swift
//  MasonryLayoutSample
//
//  Created by Sungwook Baek on 11/13/23.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var photoImageView: UIImageView!
    @IBOutlet private var stackView: UIStackView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        descriptionLabel.text = nil
        photoImageView.image = nil
    }
    
    func apply(data: ViewController.Item) {
        titleLabel.text = data.title
        descriptionLabel.text = data.description
        Task.detached(priority: .background) { [weak self] in
            await self?.photoImageView.loadImage(url: data.photoUrl)
        }
    }
}
