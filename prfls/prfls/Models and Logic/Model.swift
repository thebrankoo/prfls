//
//  Model.swift
//  prfls
//
//  Created by Branko Popovic on 9/28/19.
//  Copyright © 2019 Branko Popovic. All rights reserved.
//

import Foundation

enum Sections {
    case profile // main section for showing profiles
    case loader // section for loader
}

/**
 Decodable model that is made from api json response
 */
struct Profiles: Decodable {
    var results: [Profile]!
    var info: Info?
}

struct Info: Decodable {
    var page: Int?
    var results: Int?
    var seed: String?
    var version: String?
}

struct Profile: Decodable, Hashable {
    let identifier: UUID = UUID()
    var gender: String?
    var name: Name?
    var location: Location?
    var email: String?
    var login: Login?
    var dob: Dob?
    var registered: Registered?
    var phone: String?
    var cell: String?
    var id: Id?
    var picture: Picture?
    var nat: String?
    
    func hash(into hasher: inout Hasher) {
        return hasher.combine(identifier)
    }
    static func == (lhs: Profile, rhs: Profile) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

struct Name: Decodable {
    var title: String?
    var first: String?
    var last: String?
}

struct Location: Decodable {
    var street: String?
    var city: String?
    var state: String?
    var postcode: Any
    var coordinates: Coordinates?
    var timezone: Timezone?
    
    enum CodingKeys: String, CodingKey {
        case postcode
    }
    
    init(from decoder: Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let stringProperty = try? container.decode(String.self, forKey: .postcode) {
                postcode = stringProperty
            } else if let intProperty = try? container.decode(Int.self, forKey: .postcode) {
                postcode = intProperty
            } else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: "Not a JSON"))
            }
        }
    }
}

struct Timezone: Decodable {
    var offset: String?
    var description: String?
}

struct Coordinates: Decodable {
    var latitude: String?
    var longitude: String?
}

struct Login: Decodable {
    var uuid: String?
    var username: String?
    var password: String?
    var salt: String?
    var md5: String?
    var sha1: String?
    var sha256: String?
}

struct  Dob: Decodable {
    var date: String?
    var age: Int?
}

struct Registered: Decodable {
    var date: String?
    var age: Int?
}

struct Id: Decodable {
    var name: String?
    var value: String?
}

struct Picture: Decodable {
    var large: String?
    var medium: String?
    var thumbnail: String?
    var thumbnailData: Data?
    var mediumData: Data?
    var largeData: Data?
}
