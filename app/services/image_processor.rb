class ImageProcessor
  def self.process(image_file)
    return nil unless image_file
    
    # 一時ファイルとして保存
    temp_file = Tempfile.new(['processed', '.webp'])
    
    begin
      # MiniMagickで画像を処理
      image = MiniMagick::Image.read(image_file.read)
      
      # リサイズ（最大1200px、アスペクト比維持）
      image.resize "1200x1200>"
      
      # 品質を80%に圧縮
      image.quality "80"
      
      # Webp形式に変換
      image.format "webp"
      
      # 一時ファイルに書き込み
      image.write(temp_file.path)
      
      # ActionDispatch::Http::UploadedFile として返す
      ActionDispatch::Http::UploadedFile.new(
        tempfile: temp_file,
        filename: "#{File.basename(image_file.original_filename, '.*')}.webp",
        type: 'image/webp'
      )
    rescue => e
      Rails.logger.error "画像処理エラー: #{e.message}"
      temp_file.close
      temp_file.unlink
      nil
    end
  end
end