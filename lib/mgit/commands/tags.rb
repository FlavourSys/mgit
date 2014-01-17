require 'open3'

module MGit
  class TagsCommand < Command
    def execute(args)
      t = []
      Registry.each { |repo| t << print_latest_tag(repo) }
      ptable t, :columns => [24, nil, nil]
    end

    def arity
      [0, 0]
    end

    def usage
      'tags'
    end

    def description
      'display the latest tag in repository (master branch)'
    end

    register_command :tags

  private

    def latest_tag(path)
      sout, serr, st = Open3.capture3('git describe --tags --abbrev=0 master', :chdir => path)
      (/fatal:/ =~ serr) ? 'none' : sout.strip
    end

    def latest_tag_time(path, tag)
      sout, st = Open3.capture3("git log -n 1 --format='%at' #{tag}", :chdir => path)
      Time.at(sout.strip.to_i).strftime('%Y-%m-%d')
    end

    def print_latest_tag(repo)
      tag = latest_tag(repo.path)
      commit = (tag == 'none') ? 'n/a' : latest_tag_time(repo.path, tag)
      [repo.name, tag, commit]
    end
  end
end
