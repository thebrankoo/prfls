//
//  prflsTests.swift
//  prflsTests
//
//  Created by Branko Popovic on 9/30/19.
//  Copyright © 2019 Branko Popovic. All rights reserved.
//

import XCTest
import UIKit

class prflsTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    func testFetchingSingleProfilePage() {
        let exp = expectation(description: "Fetch next page callback")
        var fetchedProfile: [Profile]? = [Profile]()
        
        ProfileFetcher.shared.fetchNextProfilePage { (profile) in
            fetchedProfile = profile
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 2) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
        
        if let fetched = fetchedProfile {
            XCTAssert(fetched.count == 20, "Number of fetched profiles should be 20 but is \(fetched.count)")
        }
        else {
            XCTFail("Profile fetching error or slow network")
        }
        
        ProfileFetcher.shared.clearCache()
    }
    
    func testFetchingMultipleProfilePages() {
        let exp = expectation(description: "Multiple Fetch next page callback")
        
        var fetchedProfile: [Profile]? = [Profile]()
        let numOfPages = 5
        
        ProfileFetcher.shared.fetchNextProfilePage { (_) in
            ProfileFetcher.shared.fetchNextProfilePage { (_) in
                ProfileFetcher.shared.fetchNextProfilePage { (_) in
                    ProfileFetcher.shared.fetchNextProfilePage { (_) in
                        ProfileFetcher.shared.fetchNextProfilePage { (profile) in
                            fetchedProfile = profile
                            exp.fulfill()
                        }
                    }
                }
            }
        }
        
        waitForExpectations(timeout: TimeInterval(numOfPages * 2)) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
        if let fetched = fetchedProfile {
            XCTAssert(fetched.count == numOfPages * 20, "Number of fetched profiles should be \(numOfPages * 20) but is \(fetched.count)")
        }
        else {
            XCTAssert(false, "Profile fetching error or slow network")
        }
        
        ProfileFetcher.shared.clearCache()
    }
    
    func testProfilesViewModel() {
        let profilesVM = ProfilesViewModel()
        let profileFetcher = ProfileFetcher.shared
        let exp = expectation(description: "Test Profiles View Model profile fetch")
        
        profilesVM.loadNextProfileBatch {
            exp.fulfill()
        }
        
        waitForExpectations(timeout: TimeInterval(2)) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
        
        if let profiles = profilesVM.profiles {
            XCTAssertTrue(profilesVM.profileCount() == profileFetcher.profileCache.count, "Profiles View Model should have the same number of profiles fetched in Profile Fetcher")
            
            for i in 0..<profiles.count {
                if profiles[i] != profileFetcher.profileCache[i] {
                    XCTFail("Passed profiles are not the same")
                }
            }
            
        }
        else {
            XCTFail("If one nil the other profile array should be nil")
        }
    }
    
    func testProfileDetailsViewModel() {
        var profileDetVM: ProfileDetailsViewModel?
        let profileFetcher = ProfileFetcher.shared
        let exp = expectation(description: "Test Profiles View Model profile fetch")
        
        profileFetcher.fetchNextProfilePage { (profile) in
            if let profiles = profile, let profile = profiles.first {
                profileDetVM = ProfileDetailsViewModel(withProfileIndex: 0)
                if let first = profileDetVM?.profile {
                    XCTAssertTrue(first == profile, "View model profile is not the same as the one in the cache")
                }
                else {
                    XCTFail("View model profile is nil")
                }
            }
            else {
                profileDetVM = ProfileDetailsViewModel(withProfileIndex: 0)
                if let _ = profileDetVM?.profile {
                    XCTFail("View mode profile should be nil")
                }
            }
            exp.fulfill()
        }
        
        waitForExpectations(timeout: TimeInterval(2)) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
}
