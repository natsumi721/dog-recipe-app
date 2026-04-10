class ImageProcessor
  def self.process(image_file)
    return nil unless image_file

    # 一時ファイルとして保存
    temp_file = Tempfile.new(["processed", ".webp"], binmode: true)

    begin
      # MiniMagickで画像を処理
      image = MiniMagick::Image.open(image_file.tempfile.path)
      Rails.logger.info "ImageProcessor: Image opened successfully"
      
      # リサイズ（最大1200px、アスペクト比維持）
      image.resize "1200x1200>"

      # 品質を80%に圧縮
      image.quality "80"

      # Webp形式に変換
      image.format "webp"

      # 一時ファイルに書き込み
      image.write(temp_file.path)
      
      # ✅ ファイルポインタを先頭に戻す
      temp_file.rewind

      Rails.logger.info "ImageProcessor: Image processed successfully"

      # ActionDispatch::Http::UploadedFile として返す
      ActionDispatch::Http::UploadedFile.new(
        tempfile: processed_file,
        io: File.open(temp_file.path),
        filename: "xxx.webp",
        content_type: "image/webp"
      )
    rescue => e
      Rails.logger.error "画像処理エラー: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")  # ✅ スタックトレースも出力
      
      # ✅ エラー時は一時ファイルをクリーンアップ
      temp_file.close
      temp_file.unlink
      nil
    end
  end
end