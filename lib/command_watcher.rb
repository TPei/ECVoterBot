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
    elsif args[0].include?('/info')
      poll_name = args[1]
      if poll_name.nil?
        'You need to provide a pollId :)'
      else
        response = Querier.get(poll_name: args[1])
        response_string = "Poll: #{response['pollName']} (id: #{response['pollID']})"
        response['options'].each do |option|
          response_string += "\n#{option['name']}: #{option['voteCount']}"
        end
        response_string
      end
    elsif args[0].include?('/create')
      poll_name = args[1]
      option_names = args[2..-1]

      if poll_name.nil? || option_names.nil? || option_names.empty?
        "You need to provide a poll name and poll option names!"
      else
        Querier.post(poll_name: poll_name, choices: option_names)
      end
    elsif args[0].include?('/start')
      'You got it!'
    else
      "Sorry, I don't know that command."
    end
  end
end
