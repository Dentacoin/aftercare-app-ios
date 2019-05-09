//
//  ImageRequest.swift
//  ThrowingFruit
//
//  Created by Dimitar Grudev on 5/12/17.
//  Copyright © 2017 Joshua Scorca. All rights reserved.
//

import UIKit
import Alamofire

class ImageRequest {
    
    var decodeOperation: Operation?
    var request: DataRequest
    
    init(request: DataRequest) {
        self.request = request
    }
    
    func cancel() {
        decodeOperation?.cancel()
        request.cancel()
    }
    
}
