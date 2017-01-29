require 'telegram/bot'
require 'dotenv'
Dotenv.load
require './lib/command_watcher'

token = ENV['BOT_TOKEN']

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    if message.text
      response_message  = CommandWatcher.handle(message)
      bot.api.send_message(chat_id: message.chat.id, text: response_message)
    end
  end
end
