# frozen_string_literal: true

module APIHelper
  def authorized_get(uri, options = {})
    authorized_request(uri, :get, options)
  end

  def authorized_post(uri, options = {})
    authorized_request(uri, :post, options)
  end

  def authorized_request(uri, method, options = {})
    headers = options[:headers] || {}
    data = options[:data]
    parse_json = options[:parse_json]
    parse_json = true unless options.key? :parse_json
    options = options.clone
    options.delete :headers
    options.delete :data
    options.delete :parse_json

    potential_tokens = GithubToken.where('expires > ?', Time.now + 1.minute)
    if potential_tokens.present?
      access_token = potential_tokens.last.token
    else
      private_pem = File.read("#{Rails.root}#{AppConfig['github']['integration_pem_file']}")
      private_key = OpenSSL::PKey::RSA.new(private_pem)
      payload = {
        iat: Time.now.to_i,
        exp: 1.minute.from_now.to_i,
        iss: AppConfig['github']['integration_id']
      }
      jwt = JWT.encode(payload, private_key, 'RS256')

      token_resp = HTTParty.post("https://api.github.com/installations/#{AppConfig['github']['installation_id']}/access_tokens", headers: {
                                   'Accept' => 'application/vnd.github.machine-man-preview+json',
                                   'User-Agent' => 'metasmoke-ci/1.0',
                                   'Authorization' => "Bearer #{jwt}"
                                 })
      token_resp = JSON.parse(token_resp.body)
      GithubToken.create!(token: token_resp['token'], expires: token_resp['expires_at'])
      access_token = token_resp['token']
    end

    resp = HTTParty.send(method, uri, {
      body: data.to_json, headers: {
        'Accept' => 'application/vnd.github.machine-man-preview+json',
        'Authorization' => "token #{access_token}",
        'Content-Type' => 'application/json',
        'User-Agent' => 'metasmoke-ci/1.0'
      }.merge(headers)
    }.merge(options))
    if parse_json
      JSON.parse resp.body, symbolize_names: true
    else
      resp.body
    end
  end
end
