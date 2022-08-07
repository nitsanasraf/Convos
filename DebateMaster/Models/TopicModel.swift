//
//  TopicModel.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 07/08/2022.
//

import Foundation

struct TopicModel:Codable {
    let id: UUID
    let topic: String
    let category: String
}
