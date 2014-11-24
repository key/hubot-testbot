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
    # コラボレータの取得
    github.get "repos/#{owner}/#{repo}/collaborators", (collaborators) ->
      col = {}
      for collaborator in collaborators
        username = collaborator.login
        if username == 'mikacat'
          continue
        col[username] = []

      # イシューの取得
      github.get "repos/#{owner}/#{repo}/issues", (issues) ->
        for issue in issues
          if issue.assignee
            username = issue.assignee.login
            number   = issue.number
            title    = issue.title
            url      = issue.html_url

            task = "##{number} #{title} #{url}"

            col[username].push(task)

        for username in Object.keys(col)
          robot.identity.findUser username, (err, chatUser) ->
            msg.send "Couldn't retrieve chat username by #{username}" if err

            if col[username].length
              msg.send "@{chatUser}: アサイン済みタスクを送るね。\n" + col[username].join("\n")
            else
              msg.send "@{chatUser}: アサイン済みのタスクは…1つもないよ。"

  robot.respond /todo/i, (msg) ->

    owner = process.env.HUBOT_GITHUB_USER
    repo = process.env.HUBOT_GITHUB_REPO

    # initialize collaborators
    fetchCollaborators(msg, owner, repo)

