project 'hiChat.xcodeproj'

platform :ios, '8.0'
inhibit_all_warnings!

def pods
  pod 'AFNetworking'
  pod 'SDWebImage'
  pod 'Masonry'
  pod 'MJRefresh'
  pod 'WechatOpenSDK'
  pod 'WebViewJavascriptBridge'
  pod 'RongCloudIM/IMKit'
  pod 'AliyunOSSiOS'
  
  pod 'LYCoreDataSource'
  pod 'LYPopupTools'
  
  pod 'NYXImagesKit'
  pod 'ZXingObjC'
  pod 'LBXScan/LBXZBar'
  pod 'STPopup'
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
