module SpecHelpers
  def json_headers
    { 'Accept' => 'application/json' }
  end

  def json_response
    JSON.parse(response.body)
  end

  def get_cookie(cookies, name)
    cookies.send(:hash_for, nil).fetch(name, nil)
  end

  def sign_in(email, password)
    post sign_in_path, params: { email: email, password: password }, headers: json_headers
  end
end
