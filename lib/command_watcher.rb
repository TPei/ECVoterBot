require './lib/querier'

class CommandWatcher

  def initialize(message)
    @message = message
    @args = message.text.split(' ')
  end

  def self.handle(message)
    self.new(message).handle
  end

  def handle
    if command_is? '/vote'
      put_vote
    elsif command_is? '/info'
      get_info
    elsif command_is? '/create'
      put_poll
    elsif command_is? '/start'
      'You got it!'
    else
      "Sorry, I don't know that command."
    end
  end

  private

  attr_reader :message, :args

  def command_is?(other)
    args[0].downcase.include?(other)
  end

  def get_info
    args = message.text.split(' ')
    poll_name = args[1]
    if poll_name.nil?
      'You need to provide a pollId :)'
    else
      response = Querier.get(poll_name: args[1])
      response['message']
    end
  end

  def put_vote
    poll_name = args[1]
    choice_name = args[2]
    if choice_name.nil? || poll_name.nil?
      'Vote expects a poll name and choice name :)'
    else
      response = Querier.post_vote(
        poll_name: poll_name,
        choice_name: choice_name,
        sender: message.from.id
      )
      response['message']
    end
  end

  def put_poll
    args = message.text.split(' ')
    poll_name = args[1]
    option_names = args[2..-1]

    if poll_name.nil? || option_names.nil? || option_names.empty?
      "You need to provide a poll name and poll option names!"
    else
      response = Querier.post(poll_name: poll_name, choices: option_names)
      response['message']
    end
  end
end
