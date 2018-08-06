require File.expand_path("../spec_helper", __FILE__)

module Danger
  describe Danger::DangerJira do
    it "should be a plugin" do
      expect(Danger::DangerJira.new(nil)).to be_a Danger::Plugin
    end

    #
    # You should test your custom attributes and methods here
    #
    describe "with Dangerfile" do
      before do
        @jira = testing_dangerfile.jira
        DangerJira.send(:public, *DangerJira.private_instance_methods)
        github = Danger::RequestSources::GitHub.new({}, testing_env)
      end

      it "can find jira issues via title" do
        allow(@jira).to receive_message_chain("github.pr_title").and_return("Ticket [WEB-123] and WEB-124")
        issues = @jira.find_jira_issues(key: "WEB")
        expect((issues <=> ["WEB-123", "WEB-124"]) == 0)
      end

      it "can find jira issues in commits" do
        single_commit = Object.new
        def single_commit.message
          "WIP [WEB-125]"
        end
        commits = [single_commit]
        allow(@jira).to receive_message_chain("git.commits").and_return(commits)
        issues = @jira.find_jira_issues(
          key: "WEB",
          search_title: false,
          search_commits: true
        )
        expect((issues <=> ["WEB-125"]) == 0)
      end

      it "can find jira issues in pr body" do
        allow(@jira).to receive_message_chain("github.pr_body").and_return("[WEB-126]")
        issues = @jira.find_jira_issues(
          key: "WEB",
          search_title: false,
          search_commits: false
        )
        expect((issues <=> ["WEB-126"]) == 0)
      end

      it "can remove duplicates" do
        allow(@jira).to receive_message_chain("github.pr_title").and_return("Ticket [WEB-123] and WEB-123")
        issues = @jira.find_jira_issues(key: "WEB")
        expect((issues <=> ["WEB-123"]) == 0)
      end
    end
  end
end
