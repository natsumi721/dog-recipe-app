require 'rails_helper'

RSpec.describe ImageProcessor do
  describe '.process' do
    let(:file) do
      fixture_file_upload(Rails.root.join('spec/fixtures/files/test_image.png'), 'image/png')
    end

    it 'webp形式に変換される' do
      processed = described_class.process(file)

      expect(processed).to be_present
      expect(File.extname(processed.path)).to eq('.webp')
    end

    it 'リサイズされる（最大1200px以内）' do
      processed = described_class.process(file)

      image = MiniMagick::Image.open(processed.path)
      width, height = image.dimensions

      expect(width).to be <= 1200
      expect(height).to be <= 1200
    end
  end
end
