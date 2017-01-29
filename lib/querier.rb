require 'dotenv'
Dotenv.load
require 'unirest'

class Querier
  def self.post(poll_name:, choice_name:, sender:)
    body = { 'Body': "#{poll_name}+#{choice_name}", 'From': sender }

    url = ENV['POST_URL']

    begin
      Unirest.timeout(60) # for initial function starting
      response = Unirest.post(
        url,
        headers: {
          'Accept' => 'application/json',
          'x-twilio-signature' => 'totally'
        },
        parameters: body
      )

      puts response
      return response.code
    rescue => e
      puts "failed #{e}"
      return 500
    end
  end

  def self.get(poll_name:)
    url = ENV['GET_URL']
    response = Unirest.get("#{url}&pollID=#{poll_name}")
    puts response.inspect
    response.body
  rescue => e
    puts "failed #{e}"
    'error'
  end
end
