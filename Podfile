# Uncomment the next line to define a global platform for your project
# platform :ios, '10.0'

target 'IoTBadSmellMonitoring' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'Alamofire', '~> 5.4.3'
  pod 'PromisedFuture'
  pod 'ExytePopupView'

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '10.0'
      end
    end
  end

  # Pods for IoTBadSmellMonitoring

end
