//
//  URLResponse+Extensions.swift
//  Convos
//
//  Created by Nitsan Asraf on 24/08/2022.
//

import Foundation

extension URLResponse {

    func getStatusCode() -> Int? {
        if let httpResponse = self as? HTTPURLResponse {
            return httpResponse.statusCode
        }
        return nil
    }
}
