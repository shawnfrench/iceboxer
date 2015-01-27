require 'octokit'
require 'active_support/all'

module Iceboxer
  class Deprecate

    def initialize(repo)
      @repo = repo
    end

    def perform
      issues = Octokit.search_issues("repo:#{@repo} is:open label:Deprecation")
      issues.items.each do |issue|
        begin
          date = issue.title.to_date
          if date < Date.today
            Octokit.add_comment(@repo, issue.number, deprecate(issue.user.login, (Date.today - date).to_i))
          end
        rescue ArgumentError
          Octokit.add_comment(@repo, issue.number, add_date_message(issue.user.login))
        end
      end
    end

    def add_date_message(user)
      <<-MSG
@#{user},

Issues with the 'Deprecation' label need to have a deprecation date 
in the issue title, in format YYYY-MM-DD.

I could not find a date in the title for this issue.

Please add a date to the title, or remove the 'Deprecation' label.
      MSG
    end

    def deprecate(user, days)
      message = <<-MSG
Ping @#{user}

This deprecation notice expired #{days} #{"day".pluralize(days)} ago.

Please resolve it immediately.
      
      MSG

      if days > 10 && ENV["GITHUB_BOSS"]
        message += "ping #{ENV["GITHUB_BOSS"]}"
      end

      message
    end
  end
end

