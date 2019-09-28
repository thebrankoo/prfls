//
//  ProfilesViewModel.swift
//  prfls
//
//  Created by Branko Popovic on 9/28/19.
//  Copyright © 2019 Branko Popovic. All rights reserved.
//

import Foundation

protocol ProfilesViewModelDelegate: class {
    func didFetchProfiles(profileViewModel profileVM: ProfilesViewModel?, withSuccess success: Bool)
}
/**
 View model for ProfilesTableViewController
 */
class ProfilesViewModel: NSObject {
    var profiles: [Profile]? = [Profile]()
    private let profileFetcher: ProfileFetcher
    
    weak var delegate: ProfilesViewModelDelegate?
    
    override init() {
        self.profileFetcher = ProfileFetcher.shared
        super.init()
    }
    
    func loadNextProfileBatch(completion:(()->Void)? = nil) {
        profileFetcher.fetchNextProfilePage {[weak self] (profiles) in
            guard let _ = self?.profiles, let profiles = profiles else {
                self?.delegate?.didFetchProfiles(profileViewModel: self!, withSuccess: false)
                completion?()
                return
            }
            
            self?.profiles = profiles
            
            if let wself = self {
                self?.delegate?.didFetchProfiles(profileViewModel: wself, withSuccess: true)
            }
            else {
                self?.delegate?.didFetchProfiles(profileViewModel: self, withSuccess: false)
            }
            completion?()
        }
    }
    
    func profileCount()->Int {
        guard let profiles = profiles else {
            return 0
        }
        return profiles.count
    }
    
    func firstNameAtRow(row: Int) -> String {
        if let name = profiles?[row].name?.first {
            return name
        }
        return "N/A"
    }
    
    func lastNameAtRow(row: Int) -> String {
        if let name = profiles?[row].name?.last {
            return name
        }
        return "N/A"
    }
    
    func ageAtRow(row: Int) -> String {
        if let age = profiles?[row].dob?.age {
            return String(age)
        }
        return "N/A"
    }
    
    func natAtRow(row: Int) -> String {
        if let nat = profiles?[row].nat {
            return nat
        }
        return "N/A"
    }
    
    func natFlagAtRow(row: Int) -> String {
        let country = natAtRow(row: row)
        let base : UInt32 = 127397
        var s = ""
        for v in country.unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return String(s)
    }
    
    func thumbnailUrlAtRow(row: Int) -> URL? {
        if let thumbnailString = profiles?[row].picture?.thumbnail {
            return URL(string: thumbnailString)
        }
        return nil
    }
    
    func loadThumbnailAtRow(row: Int, completion: @escaping (Data?)->Void) {
        guard let url = thumbnailUrlAtRow(row: row) else {
            completion(nil)
            return
        }
        
        if let cachedImage = self.profiles?[row].picture?.thumbnailData  {
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
                self?.profiles?[row].picture?.thumbnailData = data
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
}
