module MGit
  class CheckoutCommand < Command
    def execute(args)
      @git_args = args.shift if args.length == 2
      @commit = args.shift

      if repos.empty?
        perror "Couldn't find commit #{@commit} in any repository."
      else
        checkout_all
      end
    end

    def arity
      [1, 2]
    end

    def usage
      'checkout [additional git args] <commit-sha/obj>'
    end

    def description
      'checkout commit object in all repositories that have it'
    end

    register_command :checkout
    register_alias :co

    private

    def repos
      @rs ||= Registry.select { |r| r.has_commit?(@commit) }
    end

    def checkout_all
      repos.each do |repo|
        begin
          if repo.dirty?
            pwarn "Skipping repository #{repo.name} as it is dirty."
            next
          end

          repo.in_repo { System.git("checkout -q #{@git_args || ''} #{@commit}") }
          pinfo "Switched to #{@commit} in repository #{repo.name}."
        rescue GitError
          perror "Failed to checkout #{@commit} in repository #{repo.name}."
        end
      end
    end
  end
end
