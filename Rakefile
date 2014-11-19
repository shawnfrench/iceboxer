require 'octokit'
require 'active_support/all'

unless ENV['GITHUB_API_TOKEN'].present?
  raise "Set GITHUB_API_TOKEN with a token with repo access"
end

unless ENV['ICEBOXER_REPO'].present?
  raise "Set ICEBOXER_REPO to repo like 'org/reponame'"
end

REPO=ENV["ICEBOXER_REPO"]

CLOSERS=[
  {
    :search => "repo:#{REPO} is:open created:<#{12.months.ago.to_date.to_s} updated:<#{2.months.ago.to_date.to_s}",
    :message => "This is older than a year and has not been touched in 2 months."
  },
  {
    :search => "repo:#{REPO} is:open updated:<#{6.months.ago.to_date.to_s}",
    :message => "This has not been touched in 6 months."
  }
]

Octokit.access_token = ENV['GITHUB_API_TOKEN']

def close_issues
  CLOSERS.each do |closer|
    issues = Octokit.search_issues(closer[:search])
    puts "Found #{issues.items.count} issues to close:"
    issues.items.each do |issue|
      unless already_iceboxed?(issue.number)
        puts "Closing #{issue.number}: #{issue.title}"
        icebox(issue.number, closer)
        exit
      end
    end
  end
end

def already_iceboxed?(issue)
  comments = Octokit.issue_comments(REPO, issue)
  comments.any? { |c| c.body =~ /Icebox/ }
end

def icebox(issue, reason)
  Octokit.add_labels_to_an_issue(REPO, issue, ["Icebox"])
  Octokit.add_comment(REPO, issue, message(reason))
  Octokit.close_issue(REPO, issue)

  puts "Iceboxed #{issue}!"
end

def message(reason)
<<-MSG
#{reason[:message]}

I am closing this as it is stale.

I have applied the tag 'Icebox' so you can still see it by querying closed issues.

Developers: Feel free to reopen if you and your team lead agree it is high priority and will be addressed in the next month.

MSG
end

task :icebox do
  close_issues
end