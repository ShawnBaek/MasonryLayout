//
//  UIImageView+Extension.swift
//  MasonryLayoutSample
//
//  Created by Sungwook Baek on 11/13/23.
//

import Foundation
import UIKit

extension UIImageView {
    public func loadImage(url: URL?) async {
        guard image == nil else {
            return
        }
        let cache = URLCache.shared
        guard let imageUrl = url else {
            return
        }
        let urlRequest = URLRequest(url: imageUrl)
        if let data = cache.cachedResponse(for: urlRequest)?.data,
            let image = Self.fromData(data)
        {
            await MainActor.run { [weak self] in
                self?.image = image
            }
        } else if let (data, response, _) = try? await dataTask(for: urlRequest),
            let data = data,
            let response = response
        {
            Task.detached(priority: .background) {
                let cachedData = CachedURLResponse(response: response, data: data)
                cache.storeCachedResponse(cachedData, for: urlRequest)
            }
            let image = Self.fromData(data)
            await MainActor.run { [weak self] in
                self?.image = image
            }
        }
    }

    private func dataTask(for urlRequest: URLRequest) async throws
        -> (Data?, URLResponse?, Error?)
    {
        await withCheckedContinuation { continuation in
            URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                return continuation.resume(returning: (data, response, error))
            }.resume()
        }
    }

    private static func fromData(_ data: Data) -> UIImage? {
        UIImage(data: data)
    }
}
