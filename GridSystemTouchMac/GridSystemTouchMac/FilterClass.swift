//
//  FilterClass.swift
//  GridSystemTouchMac
//
//  Created by Zeeta Andrade on 23/03/22.
//

import Foundation
import Cocoa

class FilterClass {
    
    static var shared = FilterClass()
    
    func sepiaFilter(_ input: CIImage, intensity: Double) -> CIImage?
    {
        let sepiaFilter = CIFilter(name:"CISepiaTone")
        sepiaFilter?.setValue(input, forKey: kCIInputImageKey)
//        sepiaFilter?.setValue(intensity, forKey: kCIInputIntensityKey)
        guard let sepia = sepiaFilter else {
            return CIImage()
        }
        return sepia.outputImage
    }
    
    func bloomFilter(_ input:CIImage, intensity: Double, radius: Double) -> CIImage?
    {
        let bloomFilter = CIFilter(name:"CIBloom")
        bloomFilter?.setValue(input, forKey: kCIInputImageKey)
        bloomFilter?.setValue(intensity, forKey: kCIInputIntensityKey)
        bloomFilter?.setValue(radius, forKey: kCIInputRadiusKey)
        return bloomFilter?.outputImage
    }
}
