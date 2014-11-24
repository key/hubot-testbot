# Description:
#   Remind issues to slack user at every 8:00AM
#
# Dependencies:
#   "githubot": "0.4.x"
#   "hubot-github-identity": ">= 0.9.1"
#
# Configuration:
#   HUBOT_GITHUB_USER
#   HUBOT_GITHUB_TOKEN
#   HUBOT_HOSTNAME
#
# Commands:
#   None
#

issues_body = """おはよう。今日のタスクを送るね。
"""

prs_body = """作業待ちのPull Requestを探すよ。
"""

module.exports = (robot) ->
  github = require("githubot")(robot)

  fetchCollaborators = (owner, repo, cb) ->
    base_url = process.env.HUBOT_GITHUB_API || 'https://api.github.com'
    github.get "#{base_url}/repos/#{owner}/#{repo}/collaborators", (collaborators) ->
      cb(collaborators)

  fetchIssues =->
    console.log("check issues")
    owner = process.env.HUBOT_GITHUB_USER
    repo = process.env.HUBOT_GITHUB_REPO
    github.get "#{base_url}/repos/#{owner}/#{repo}/issues", (issues) ->
      console.log(issues)

  robot.respond /todo/i, (msg) ->
    col = {}

    owner = process.env.HUBOT_GITHUB_USER
    repo = process.env.HUBOT_GITHUB_REPO

    # initialize collaborators
    fetchCollaborators(owner, repo, ((collaborators) ->
      console.log(collaborators)
      for collaborator in collaborators
        col[collaborator["login"]] = []
      console.log(col)
      ))

