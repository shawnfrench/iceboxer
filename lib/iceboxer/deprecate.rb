require 'octokit'
require 'active_support/all'

module Iceboxer
  class Deprecate

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

    def icebox(issue, reason)
      Octokit.add_labels_to_an_issue(@repo, issue, ["Icebox"])
      Octokit.add_comment(@repo, issue, message(reason))
      Octokit.close_issue(@repo, issue)

      puts "Iceboxed #{issue}!"
    end
  end
end

