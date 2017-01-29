require 'dotenv'
Dotenv.load
require 'unirest'

class Querier
  def self.post(poll_name:, choices: nil, choice_name: nil, sender: nil)
    if choices
      post_poll(poll_name, choices)
    elsif choice_name
      post_vote(poll_name, choice_name, sender)
    end
  end

  def self.post_poll(poll_name, choices)
    url = ENV['POST_POLL_URL']


    Unirest.timeout(60)
    url += "&pollname=#{poll_name}"
    choices.each_with_index do |choice, index|
      url += "&option#{index+1}=#{choice}"
    end

    begin
      response = Unirest.get(url)
      puts response.inspect
      if response.code == 200
        msg = response.body.split(">")[1].split("<")[0]
        msg
      else
        'Something went wrong'
      end
    rescue => e
      'Something went wrong'
    end
  end

  def self.post_vote(poll_name, choice_name, sender)
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

      puts response.inspect
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
