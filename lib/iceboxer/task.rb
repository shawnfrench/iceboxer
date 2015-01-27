require 'octokit'
require 'active_support/all'

module Iceboxer

  @@operations = [
    Iceboxer::Icebox, 
    Iceboxer::Deprecate
  ]

  def self.run
    unless ENV['GITHUB_API_TOKEN'].present?
      raise "Set GITHUB_API_TOKEN with a token with repo access"
    end

    unless ENV['ICEBOXER_REPO'].present?
      raise "Set ICEBOXER_REPO to repo like 'org/reponame'"
    end

    Octokit.access_token = ENV['GITHUB_API_TOKEN']
    repository = ENV["ICEBOXER_REPO"]

    @@operations.each do |op|
      op.new(repository).perform
    end
  end
end
