//
//  ProfileDetailsViewModel.swift
//  prfls
//
//  Created by Branko Popovic on 9/28/19.
//  Copyright © 2019 Branko Popovic. All rights reserved.
//

import Foundation
import UIKit

class ProfileDetailsViewModel: NSObject {
    
    var profile: Profile?
   
    // MARK: Profile details values
    
    var firstName: String {
        if let name = profile?.name?.first {
            return name
        }
        return "N/A"
    }
    
    var lastName: String {
        if let name = profile?.name?.last {
            return name
        }
        return "N/A"
    }
    
    var nat: String {
        if let nat = profile?.nat {
            return nat
        }
        return "N/A"
    }
    
    var natFlag: String {
        let country = self.nat
        let base : UInt32 = 127397
        var s = ""
        for v in country.unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return String(s)
    }
    
    var age: String {
        if let age = profile?.dob?.age {
            return String(age)
        }
        return "N/A"
    }
    
    var email: String? {
        if let email = profile?.email {
            return email
        }
        return nil
    }
    
    var mediumImageURL: URL? {
        if let medImg = profile?.picture?.medium {
            return URL(string: medImg)
        }
        return nil
    }
    
    var largeImageURL: URL? {
        if let lrgImg = profile?.picture?.large {
            return URL(string: lrgImg)
        }
        return nil
    }
    
    init(withProfileIndex index: Int) {
        profile = ProfileFetcher.shared.fetchProfile(atIndex: index)
        super.init()
    }
    
    // MARK: Fetching image
   
    func loadLargeImage(completion: @escaping (Data?)->Void) {
        guard let url = largeImageURL else {
            completion(nil)
            return
        }
        
        if let cachedImage = self.profile?.picture?.largeData  {
            completion(cachedImage)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) {[weak self] (data, _ , error) in
            if let error = error {
                print("Image download error \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
            else if let data = data {
                self?.profile?.picture?.largeData = data
                DispatchQueue.main.async {
                    completion(data)
                }
            }
            else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        task.resume()
    }
    
    // MARK: Other actions
    
    func selectedDetails(withType type: DetailsViewType) {
        switch type {
        case .email:
            if let email = email {
                openEmail(address: email)
            }
        default:
            return
        }
    }
    
    func openEmail(address: String) {
        if let url = URL(string: "mailto:\(address)") {
            UIApplication.shared.open(url)
        }
    }
}


