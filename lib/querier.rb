require 'dotenv'
Dotenv.load
require 'unirest'

class Querier
  def initialize
    Unirest.timeout(60) # initial function startup takes looong
    @log = Logger.new(STDOUT)
  end

  def self.post_poll(poll_name:, choices:)
    self.new.post_poll(poll_name: poll_name, choices: choices)
  end

  def self.post_vote(poll_name:, choice_name:, sender:)
    self.new.post_vote(poll_name: poll_name, choice_name: choice_name, sender: sender)
  end

  def self.get(poll_name:)
    self.new.get(poll_name: poll_name)
  end

  def post_poll(poll_name:, choices:)
    url = ENV['POST_POLL_URL']

    url += "&pollname=#{poll_name}"
    choices.each_with_index do |choice, index|
      url += "&option#{index+1}=#{choice}"
    end

    begin
      response = Unirest.get(url)
      log.info response.inspect
      if response.code == 200
        msg = response.body.split(">")[1].split("<")[0]
        respond(code: 200, message: msg)
      else
        respond(code: 500, 'Something went wrong')
      end
    rescue => e
      log.fatal "failed #{e}"
      respond(code: 500, 'Something went wrong')
    end
  end

  def post_vote(poll_name:, choice_name:, sender:)
    body = { 'Body': "#{poll_name}+#{choice_name}", 'From': sender }

    url = ENV['POST_URL']

    begin
      response = Unirest.post(url, headers: headers, parameters: body)

      log.info response.inspect
      respond(code: reponse.code, message: 'Vote submitted')
    rescue => e
      log.fatal "failed #{e}"
      respond(code: 500, message: 'Something went wrong')
    end
  end

  def get(poll_name:)
    url = ENV['GET_URL']
    response = Unirest.get("#{url}&pollID=#{poll_name}")
    log.info response.inspect
    if response.body['pollName']
      response_string = "Poll: #{response.body['pollName']} (id: #{response.body['pollID']})"
      response['options'].each do |option|
        response_string += "\n#{option['name']} (##{option['order']}): \n"
        option['voteCount'].times { response_string += "\u{25FC}" }
        response_string += "(#{option['voteCount']}) \n"
      end
      respond(code: 200, message: response_string)
    else
      respond(code: 404, message: 'A poll with this id does not exist.'
    end
  rescue => e
    log.fatal "failed #{e}"
    respond(code: 500, message: 'Something went wrong.'
  end

  private

  attr_reader :log

  def headers
    {
      'Accept' => 'application/json',
      'x-twilio-signature' => 'totally'
    }
  end

  def respond(code:, message:)
    { code: code, message: message }
  end
end
