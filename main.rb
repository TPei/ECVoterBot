require 'telegram/bot'
require 'dotenv'
Dotenv.load
require './lib/command_watcher'

token = ENV['BOT_TOKEN']

while(true)
  begin
    Telegram::Bot::Client.run(token) do |bot|
      bot.listen do |message|
        if message.text
          begin
            response_message = CommandWatcher.handle(message)
            bot.api.send_message(chat_id: message.chat.id, text: response_message)
          rescue => e
            puts "failed #{e}"
          end
        end
      end
    end
  rescue => e
    puts "global error: #{e}"
  end
end
