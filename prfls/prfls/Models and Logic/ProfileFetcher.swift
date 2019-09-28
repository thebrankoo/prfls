//
//  ProfileFetcher.swift
//  prfls
//
//  Created by Branko Popovic on 9/28/19.
//  Copyright © 2019 Branko Popovic. All rights reserved.
//

import Foundation

/**
 Class for fetching and caching profiles
 */
class ProfileFetcher: NSObject {
    
    static let shared = ProfileFetcher()
    
    private let profileUrl: ProfileUrlCreator
    
    // caching fetched data
    var profileCache: [Profile] = [Profile]()
    
    private override init() {
        profileUrl = ProfileUrlCreator()
        super.init()
    }

    // url request for next page
    func fetchNextProfilePage(completion: @escaping ([Profile]?)->Void) {
        if let url = profileUrl.nextPageUrl {
            ProfileRequester.requestProfilePage(fromUrl: url) { [weak self] (profile) in
                if let profile = profile {
                    self?.profileCache += profile
                }
                DispatchQueue.main.async {
                    completion(self?.profileCache)
                }
            }
        }
    }
    
    // profile from cache
    func fetchProfile(atIndex index: Int) -> Profile {
        return profileCache[index]
    }
    
    func clearCache() {
        profileCache.removeAll()
    }
}

/**
 Util class for creating url for next page request
 */
fileprivate class ProfileUrlCreator: NSObject {
    // creating url for next page
    var nextPageUrl: URL? {
        page += 1
        return url
    }
    
    // creating url for current page
    private var url: URL? {
        let urlString = baseUrlString+"page="+String(page)+"&results=20"
        let url = URL(string: urlString)
        return url
    }
    private let baseUrlString = "https://randomuser.me/api?"
    private var page: Int
    
    override init() {
        self.page = 0
        super.init()
    }
}

/**
Util class for performing request from provided url
*/
fileprivate class ProfileRequester {
    
    // using url session for api request
    class func requestProfilePage(fromUrl url: URL, completion: @escaping ([Profile]?)->Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, response , error) in
            if let error = error {
                print("Fetch profile error \(error)")
                completion(nil)
            }
            else if let data = data {
                do {
                    let profiles = try JSONDecoder().decode(Profiles.self, from: data)
                    completion(profiles.results)
                }
                catch let err {
                    print("Profile decoding error \(err)")
                    completion(nil)
                }
            }
        }
        
        task.resume()
    }
}
