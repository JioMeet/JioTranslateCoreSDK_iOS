//
//  Extension.swift
//  JioTranslateCoreSDKDemo
//
//  Created by Ramakrishna1 M on 20/05/24.
//

import UIKit
import Foundation

extension UIColor {
    
    public static let navBarColor = UIColor(hex: "3535F3", alpha: 1.0)
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var formattedHex = hex
        if hex.hasPrefix("#") {
            formattedHex = String(hex.dropFirst())
        }
        
        var rgb: UInt64 = 0
        Scanner(string: formattedHex).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    static func getRandomColor() -> UIColor {
        let randomRed = CGFloat.random(in: 0...1)
        let randomGreen = CGFloat.random(in: 0...1)
        let randomBlue = CGFloat.random(in: 0...1)
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat = 1.0) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha:alpha)
    }
}


public class FontManager {
    public static var regularFontName = ""
    public static var mediumFontName = ""
    public static var semiboldFontName = ""
    public static var boldFontName = ""
    public static var italicFontName = ""
    public static var heavyFontName = ""
    
    internal static func getRegularFont(size: CGFloat) -> UIFont {
        guard let normalFont = UIFont(name: FontManager.regularFontName, size: size) else {
            return UIFont.systemFont(ofSize: size, weight: .regular)
        }
        return normalFont
    }
    
    internal static func getMediumFont(size: CGFloat) -> UIFont {
        guard let normalFont = UIFont(name: FontManager.mediumFontName, size: size) else {
            return UIFont.systemFont(ofSize: size, weight: .medium)
        }
        return normalFont
    }
    
    internal static func getSemiboldFont(size: CGFloat) -> UIFont {
        guard let normalFont = UIFont(name: FontManager.semiboldFontName, size: size) else {
            return UIFont.systemFont(ofSize: size, weight: .semibold)
        }
        return normalFont
    }
    
    internal static func getBoldFont(size: CGFloat) -> UIFont {
        guard let normalFont = UIFont(name: FontManager.boldFontName, size: size) else {
            return UIFont.systemFont(ofSize: size, weight: .bold)
        }
        return normalFont
    }
    
    internal static func getItalicFont(size: CGFloat) -> UIFont {
        guard let normalFont = UIFont(name: FontManager.italicFontName, size: size) else {
            return UIFont.italicSystemFont(ofSize: size)
        }
        return normalFont
    }
    
    internal static func getHeavyFont(size: CGFloat) -> UIFont {
        guard let normalFont = UIFont(name: FontManager.heavyFontName, size: size) else {
            return UIFont.systemFont(ofSize: size, weight: .heavy)
        }
        return normalFont
    }
}


func getImage(_ name: String) -> UIImage? {
    let bundle = Bundle.init(for: ViewController.self)
    return UIImage(named: name, in: bundle, compatibleWith: nil)
}

extension UIImage {
    convenience init?(named name: String) {
        guard let image = UIImage(named: name, in: Bundle.init(for: ViewController.self), compatibleWith: nil) else {
            return nil // Return nil if the image couldn't be loaded
        }
        self.init(cgImage: image.cgImage!)

    }
    
    func roundedImage(radius: CGFloat, color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let rect = CGRect(origin: .zero, size: size)
        UIBezierPath(roundedRect: rect, cornerRadius: radius).addClip()
        color.setFill()
        UIRectFill(rect)
        draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func resized(to newSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { (context) in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
