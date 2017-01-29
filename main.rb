require 'telegram/bot'
require 'dotenv'
Dotenv.load
require 'unirest'

token = ENV['BOT_TOKEN']

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    if message.text
      text = message.text
      response_message = 'sorry, something went wrong'

      args = text.split(' ')
      if args[0].include?('/vote')
        poll_name = args[1]
        choice_name = args[2]
        if choice_name.nil? || poll_name.nil?
          response_message = 'Vote expects a poll name and choice name :)'
        else

          body = { 'Body': "#{poll_name}+#{choice_name}", 'From': message.from.id }

          url = ENV['FUNCTION_URL']

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
            response_message = 'I submitted your vote' if response.code == 200
          rescue => e
            puts "failed #{e}"
          end
        end
      elsif args[0].include?('/start')
        response_message = 'you got it'
      else
        response_message = 'unrecognized command'
      end

      bot.api.send_message(chat_id: message.chat.id, text: response_message)
    end
  end
end
