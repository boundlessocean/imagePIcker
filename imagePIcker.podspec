Pod::Spec.new do |s|
s.name = 'BLImagePickerController'
s.version = '1.0.0'
s.license = { :type => "MIT", :file => "LICENSE"}
s.summary = 'A BLImagePickerController.h on iOS.'
s.homepage = 'https://github.com/boundlessocean/imagePIcker'
s.authors = { 'ocean' => 'boundlessocean@icloud.com' }
s.source = { :git => 'https://github.com/boundlessocean/imagePIcker.git',  :tag => s.version.to_s }
s.ios.deployment_target = '8.0'
s.source_files = '*.{h,m}'
end
