platform :ios, '9.0'
inhibit_all_warnings!
workspace 'EmailValidator.xcworkspace'

# Comment the next line if you're not using Swift and don't want to use dynamic frameworks
use_frameworks!

target 'EmailValidatorSwift' do
    project 'EmailValidatorSwift/EmailValidatorSwift.xcodeproj'

    # Pods for EmailValidatorSwift
#    pod 'Log4swift', '~> 1.0.2'

    target 'EmailValidatorSwiftTests' do
        inherit! :search_paths
        # Pods for testing
    end

    target 'EmailValidatorSwiftUITests' do
        inherit! :search_paths
        # Pods for testing
    end

end

target 'EmailValidatorObjC' do
    project 'EmailValidatorObjC/EmailValidatorObjC.xcodeproj'
    # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
    #    use_frameworks!

    # Pods for EmailValidatorObjc

    target 'EmailValidatorObjCTests' do
        inherit! :search_paths
        # Pods for testing
    end

    target 'EmailValidatorObjCUITests' do
        inherit! :search_paths
        # Pods for testing
    end

end

target 'EmailValidatorRxSwift' do
project 'EmailValidatorRxSwift/EmailValidatorRxSwift.xcodeproj'
    pod 'RxSwift', '~> 4.1.2'

    # Pods for EmailValidatorRxSwift

    target 'EmailValidatorRxSwiftTests' do
        inherit! :search_paths
        # Pods for testing
    end

    target 'EmailValidatorRxSwiftUITests' do
        inherit! :search_paths
        # Pods for testing
    end

end


target 'EmailValidatorReactNative' do
    project 'EmailValidatorReactNative/EmailValidatorReactNative.xcodeproj'
    # Pods for EmailValidatorReactNative

    pod 'React', :path => './EmailValidatorReactNative/node_modules/react-native', :subspecs => [
    'Core',
    'CxxBridge',
    'DevSupport',
    'RCTText',
    'RCTNetwork',
    'RCTWebSocket',
    ]
    pod 'yoga', :path => './EmailValidatorReactNative/node_modules/react-native/ReactCommon/yoga'
    pod 'DoubleConversion', :podspec => './EmailValidatorReactNative/node_modules/react-native/third-party-podspecs/DoubleConversion.podspec'
    pod 'glog', :podspec => './EmailValidatorReactNative/node_modules/react-native/third-party-podspecs/GLog.podspec'
    pod 'Folly', :podspec => './EmailValidatorReactNative/node_modules/react-native/third-party-podspecs/Folly.podspec'


    target 'EmailValidatorReactNativeTests' do
        inherit! :search_paths
        # Pods for testing
    end

    target 'EmailValidatorReactNativeUITests' do
        inherit! :search_paths
        # Pods for testing
    end

end
