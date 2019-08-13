project 'hiChat.xcodeproj'

platform :ios, '8.0'
inhibit_all_warnings!
use_frameworks!

def pods
  pod 'AFNetworking'
  pod 'RongCloudIM/IMKit'#, '2.9.15'
  pod 'Masonry'
  pod 'MJRefresh'
#  pod 'STPopup',                    :git => 'https://github.com/kevin0571/STPopup.git'
  pod 'AliyunOSSiOS'
  pod 'WechatOpenSDK'
  pod 'ZXingObjC'
  pod 'LBXScan/LBXZBar'
  pod 'SDWebImage'
  pod 'MBProgressHUD'
  pod 'NYXImagesKit'

#  pod 'WebViewJavascriptBridge',    :git => 'git@github.com:golverine/WebViewJavascriptBridge.git'
#  pod 'VICoreDataSource',           :git => 'git@github.com:golverine/VICoreDataSource.git'
#  pod 'VIPhotoBrowser',             :git => 'git@github.com:golverine/VIPhotoBrowser.git'
#  pod 'VICocoaTools',               :git => 'git@github.com:golverine/VICocoaTools.git'
#  pod 'NYXImagesKit',               :git => 'git@github.com:golverine/NYXImagesKit.git'
#  pod 'GFPopover',                  :git => 'git@github.com:golverine/GFPopover.git'

#  pod 'WebViewJavascriptBridge',    :path => '../github/WebViewJavascriptBridge'
#  pod 'VICoreDataSource',           :path => '../../../../github/VICoreDataSource'
#  pod 'VIPhotoBrowser',             :path => '../github/VIPhotoBrowser'
#  pod 'VICocoaTools',               :path => '../../../../github/VICocoaTools'
#  pod 'NYXImagesKit',               :path => '../github/NYXImagesKit'

end

target 'hiChat_enterprise_dev' do
  pods
end

target 'hiChat_enterprise_pub' do
  pods
end

target 'hiChat_app_dev' do
  pods
end

target 'hiChat_app_store' do
  pods
end

# 关闭所有 taget 的 bitcode 开关
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODE'] = 'NO'
        end
    end
end
