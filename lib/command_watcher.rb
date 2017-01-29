require './lib/querier'

class CommandWatcher
  def self.handle(message)
    args = message.text.split(' ')
    if args[0].include?('/vote')
      poll_name = args[1]
      choice_name = args[2]
      if choice_name.nil? || poll_name.nil?
        'Vote expects a poll name and choice name :)'
      else
        response = Querier.post(
          poll_name: poll_name,
          choice_name: choice_name,
          sender: message.from.id
        )
        if response == 200
          'I submitted your vote.'
        else
          'Sorry, something went wrong.'
        end
      end
    elsif args[0].include?('/start')
      'You got it!'
    else
      "Sorry, I don't know that command."
    end
  end
end