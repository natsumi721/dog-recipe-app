require 'rails_helper'

RSpec.describe "Oauths", type: :request do
  describe "GET /oauth/:provider" do
    it "returns http redirect" do
      get "/oauth/google"
      expect(response).to have_http_status(:redirect)
    end
  end

  describe "GET /oauth/callback" do
    # OAuth認証のコールバックは実際のGoogle APIを使うため、テストではスキップ
    xit "returns http redirect" do
      get "/oauth/callback", params: { provider: 'google' }
      expect(response).to have_http_status(:redirect)
    end
  end
end
