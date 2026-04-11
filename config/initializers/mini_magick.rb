MiniMagick.configure do |config|
  config.cli = :imagemagick  # ImageMagick 6を使用
  config.timeout = 5
end
