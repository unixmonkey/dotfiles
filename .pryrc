if defined?(Pry)
  # Hit enter key to repeat last command
  Pry::Commands.command(/^$/, 'repeat last command') do
    last_command = Pry.history.to_a.last
    unless ['c', 'continue', 'q', 'exit-program', 'quit'].include? last_command
      pry_instance.run_command last_command
    end
  end

  # Single letter aliases for pry commands
  Pry.commands.alias_command 'w', 'whereami'
  Pry.commands.alias_command 'c', 'continue'
  Pry.commands.alias_command 's', 'step'
  Pry.commands.alias_command 'n', 'next'
  Pry.commands.alias_command 'q', 'exit-program'
  Pry.commands.alias_command 'quit', 'exit-program'

  # Turn off the automatic pager
  Pry.config.pager = false
end


if defined?(Rails) && Rails.env && !Rails.env.production?
  class MyStuff
    # http://seaneshbaugh.com/posts/finding-all-activerecord-callbacks
    def self.show_callbacks(klass)
      _callback_methods = klass.methods.select do |method|
        method.to_s =~ /^_{1}[^_].+_callbacks$/
      end
      _callback_methods.each_with_object({}) do |method, memo|
        memo[method] = klass.send(method).group_by(&:kind).each do |_, callbacks|
          callbacks.map! do |callback|
            res = callback.raw_filter
            if res.is_a?(Proc)
              { proc: res, source: res.source.strip, args: res.parameters.inspect }
            else
              res
            end
          end
        end
      end
    end
  end
end

