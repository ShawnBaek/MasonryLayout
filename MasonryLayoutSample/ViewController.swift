//
//  ViewController.swift
//  MasonryLayoutSample
//
//  Created by Sungwook Baek on 11/13/23.
//

import UIKit
import SwiftUI

class ViewController: UIViewController {
    @IBOutlet private weak var collectionView: UICollectionView!
    private lazy var dataSource = createDataSource()
    private var cachedSize = [Int: CGSize]()
    
    enum Section: CaseIterable {
        case item
    }
    
    struct Item: Hashable {
        let title: String
        let description: String
        let photoUrl: URL
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = masonryLayout(
            contentInset: .init(top: 0, leading: 10, bottom: 0, trailing: 10))
        collectionView.dataSource = dataSource
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        fetchData()
    }
    
    func fetchData() {
        applySnapShot()
    }
    
    private func applySnapShot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(Item.fakeData(count: 30), toSection: .item)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func masonryLayout(contentInset: NSDirectionalEdgeInsets) -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment in
            var items = [NSCollectionLayoutGroupCustomItem]()
            let snapshotItems = self?.dataSource.snapshot(for: .item).items
            let numberOfItems = snapshotItems?.count ?? 0
            let contentSize = layoutEnvironment.container.contentSize
            let itemProvider = MasonryLayoutProvider(
                columns: 2,
                interItemSpacing: 16,
                collectionWidth: contentSize.width,
                contentInsets: contentInset) { [weak self] row, cellWidth in
                    if let cachedHeight = self?.cachedSize[row]?.height {
                        return cachedHeight
                    }
                    let height = snapshotItems?[row].estimatedHeight(width: cellWidth) ?? 0
                    self?.cachedSize[row] = .init(width: cellWidth, height: height)
                    return height
                }
            for i in 0..<numberOfItems {
                let item = itemProvider.makeLayoutItem(for: i)
                items.append(item)
            }
            let groupLayoutSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(itemProvider.maxColumnHeight())
            )
            
            let group = NSCollectionLayoutGroup.custom(layoutSize: groupLayoutSize) { env in
                items
            }
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = contentInset
            section.boundarySupplementaryItems = [
                .init(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(10)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            ]
            return section
        }
        return layout
        
    }
    
    private func createDataSource() -> UICollectionViewDiffableDataSource<Section, Item> {
        let listingHeaderView = UICollectionView.SupplementaryRegistration<
            HeaderCollectionReusableView
        >(
            supplementaryNib: UINib(
                nibName: "HeaderCollectionReusableView",
                bundle: .main
            ),
            elementKind: UICollectionView.elementKindSectionHeader
        ) {
            supplementaryView, elementKind, indexPath in
        }
        
        let dataSource = UICollectionViewDiffableDataSource<Section, Item>(
            collectionView: collectionView
        ) { collectionView, indexPath, data in
            let section = Section.allCases[indexPath.section]
            switch section {
            case .item:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as? CollectionViewCell
                cell?.apply(data: data)
                return cell
            }
        }
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            let section = Section.allCases[indexPath.section]
            switch section {
            case .item:
                return collectionView.dequeueConfiguredReusableSupplementary(
                    using: listingHeaderView, for: indexPath)
                
            }
        }
        return dataSource
    }
}

extension ViewController.Item {
    typealias Item = ViewController.Item
    static func fakeData(count: Int) -> [Item] {
        var items = [Item]()
        let descriptions = [
            "Lorem ipsum is placeholder text commonly used in the graphic, print, and publishing industries for previewing layouts and visual mockups",
            "Generated 1 paragraph, 5 words, 27 bytes of Lorem Ipsum"
        ]
        for i in 0..<count {
            let isEvenIndex = i % 2 == 0
            items.append(Item(
                title: "Title: \(i)",
                description: isEvenIndex ? descriptions[0] : descriptions[1],
                photoUrl: isEvenIndex ? 
                URL(string: "https://picsum.photos/200/300?grayscale")! :
                    URL(string: "https://picsum.photos/200")!
            )
            )
        }
        return items
    }
    
    func height(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: UILabel.noIntrinsicMetric))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        return label.textHeight ?? 0
    }
    
    func estimatedHeight(width: CGFloat) -> CGFloat {
        let imageHeight = width * 0.75
        let titleHeight = height(text: title, font: .systemFont(ofSize: 17, weight: .heavy), width: width)
        let descriptionHeight = height(text: description, font: .systemFont(ofSize: 17), width: width)
        return imageHeight + titleHeight + descriptionHeight
    }
}

extension UILabel {
    var textHeight: CGFloat? {
        guard let labelText = text else {
            return nil
        }
        let attributes: [NSAttributedString.Key: UIFont] = [
            .font: font
        ]
        let labelTextSize = (labelText as NSString).boundingRect(
            with: CGSize(width: frame.size.width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: attributes,
            context: nil
        ).size
        return ceil(labelTextSize.height)
    }
}

#Preview {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateInitialViewController() as! ViewController
    vc.loadViewIfNeeded()
    return vc
}
