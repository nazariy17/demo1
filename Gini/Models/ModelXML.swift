//
//  ModelXML.swift
//  Gini
//
//  Created by Nazar on 15/07/2017.
//  Copyright © 2017 Nazariy Bohun. All rights reserved.
//

import Foundation
import EVReflection

class ResponseXML: EVObject
{
    var data: DataXML = DataXML()
}

class DataXML: EVObject
{
    var images: ImagesXML = ImagesXML()
}

class ImagesXML: EVObject
{
    var image: [ImageXML] = [ImageXML]()
}

class ImageXML: EVObject
{
    var url: String?
    var id: String?
    var source_url: String?
}
