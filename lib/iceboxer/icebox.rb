require 'octokit'
require 'active_support/all'

module Iceboxer
  class Icebox

    def initialize(repo)
      @repo = repo
    end

    def perform
      closers.each do |closer|
        issues = Octokit.search_issues(closer[:search])
        puts "Found #{issues.items.count} issues to close:"
        issues.items.each do |issue|
          unless already_iceboxed?(issue.number)
            puts "Closing #{issue.number}: #{issue.title}"
            icebox(issue.number, closer)
          end
        end
      end
    end

    def closers
      [
        {
          :search => "repo:#{@repo} is:open created:<#{12.months.ago.to_date.to_s} updated:<#{2.months.ago.to_date.to_s}",
          :message => "This is older than a year and has not been touched in 2 months."
        },
        {
          :search => "repo:#{@repo} is:open updated:<#{6.months.ago.to_date.to_s}",
          :message => "This has not been touched in 6 months."
        }
      ]
    end

    def already_iceboxed?(issue)
      comments = Octokit.issue_comments(@repo, issue)
      comments.any? { |c| c.body =~ /Icebox/ }
    end

    def icebox(issue, reason)
      Octokit.add_labels_to_an_issue(@repo, issue, ["Icebox"])
      Octokit.add_comment(@repo, issue, message(reason))
      Octokit.close_issue(@repo, issue)

      puts "Iceboxed #{issue}!"
    end

    def message(reason)
      <<-MSG.strip_heredoc
      ![picture of the iceboxer](https://cloud.githubusercontent.com/assets/699550/5107249/0585a470-6fce-11e4-8190-4413c730e8d8.png)

      I am closing this because: #{reason[:message]}

      I have applied the tag 'Icebox' so you can still see it by querying closed issues.

      You may reopen if you and the team lead agree it is high priority and will be addressed in the next month.

      See https://vault.shopify.com/Product-@-Platform for more.
      MSG
    end
  end
end

