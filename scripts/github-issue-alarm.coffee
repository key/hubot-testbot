# Description:
#   Remind issues to slack user at every 8:00AM
#
# Dependencies:
#   "githubot": "0.4.x"
#   "hubot-github-identity": ">= 0.9.1"
#
# Configuration:
#   HUBOT_GITHUB_API
#   HUBOT_GITHUB_USER
#   HUBOT_GITHUB_REPO
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

  fetchCollaborators = (msg, owner, repo) ->
    col = {}
    base_url = process.env.HUBOT_GITHUB_API || 'https://api.github.com'

    github.get "#{base_url}/repos/#{owner}/#{repo}/collaborators", (collaborators) ->
      for collaborator in collaborators
        col[collaborator.login] = []
      console.log(col)

      github.get "#{base_url}/repos/#{owner}/#{repo}/issues", (issues) ->
        for issue in issues
          if issue.assignee
            username = issue.assignee.login
            number   = issue.number
            title    = issue.title
            url      = issue.html_url

            task = "##{number} #{title} #{url}"

            if username not in col
              col[username] = []

            col[username].push(task)
        console.log(col)

        for key in Object.keys(col)
          msg.send "#{key} の今日のタスクを送るね。\n" + col[key].join("\n")

#          login = issue.assignee.login
#          if login in col
#            msg = "#{issue.title} #{issue.html_url}"
#            console.log(msg)
#          else
#            console.log("#{login} doesn't exists")

  robot.respond /todo/i, (msg) ->

    owner = process.env.HUBOT_GITHUB_USER
    repo = process.env.HUBOT_GITHUB_REPO

    # initialize collaborators
    fetchCollaborators(msg, owner, repo)

