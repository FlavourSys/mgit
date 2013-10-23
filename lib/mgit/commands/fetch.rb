module MGit
  class FetchCommand < Command
    def execute(args)
      raise TooManyArgumentsError.new(self) if args.size != 0

      Repository.chdir_each do |name, path|
        `git remote`.split.each do |remote|
          puts "Fetching #{remote} in repository #{name}..."
          `git fetch #{remote}`
        end
      end
    end

    def usage
      'fetch'
    end

    register_command :fetch
  end
end