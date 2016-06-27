def get_data (url)
  @response = HTTParty.get(url)
  @data = JSON.parse(@response.body)
  return @data
end

def math(num1, num2)
  return num1 + num2
end

