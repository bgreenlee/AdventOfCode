//
//  Font.swift
//  AdventOfCode
//
//  Created by Brad Greenlee on 12/8/24.
//
import SwiftUI

// MARK: - Font Names
enum CustomFontFamily {
    static let light = "SourceCodeProRoman-Light"
    static let regular = "SourceCodeProRoman-Regular"
    static let medium = "SourceCodeProRoman-Medium"
    static let bold = "SourceCodeProRoman-Bold"
}

// MARK: - Font Extension
extension Font {
    // Design system text styles
    struct Design {
        // Custom weight enum to avoid conflict with Font.Weight
        enum CustomWeight {
            case light
            case regular
            case medium
            case bold

            var fontName: String {
                switch self {
                case .light:
                    return CustomFontFamily.light
                case .regular:
                    return CustomFontFamily.regular
                case .medium:
                    return CustomFontFamily.medium
                case .bold:
                    return CustomFontFamily.bold
                }
            }
        }

        // Heading
        static func heading1(weight: CustomWeight = .medium) -> Font {
            custom(weight.fontName, size: 24)
        }

        static func heading2(weight: CustomWeight = .medium) -> Font {
            custom(weight.fontName, size: 20)
        }

        // Body
        static func bodyLarge(weight: CustomWeight = .regular) -> Font {
            custom(weight.fontName, size: 17)
        }

        static func body(weight: CustomWeight = .regular) -> Font {
            custom(weight.fontName, size: 15)
        }

        static func bodySmall(weight: CustomWeight = .regular) -> Font {
            custom(weight.fontName, size: 13)
        }

        static func bodyXSmall(weight: CustomWeight = .regular) -> Font {
            custom(weight.fontName, size: 10)
        }

        static func bodyXXSmall(weight: CustomWeight = .regular) -> Font {
            custom(weight.fontName, size: 8)
        }
    }
}
