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

cronJob = require('cron').CronJob

issues_body = """おはよう。今日のタスクを送るね。
"""

prs_body = """作業待ちのPull Requestを探すよ。
"""

module.exports = (robot) ->
  github = require("githubot")(robot)

  owner = process.env.HUBOT_GITHUB_USER
  repo = process.env.HUBOT_GITHUB_REPO

  sendAssignedIssues = (envelope, owner, repo) ->

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
          if col[username].length
            robot.send envelope, "#{username} のタスクを送るね。\n" + col[username].join("\n")
          else
            robot.send envelope, "#{username} のタスクはないよ。"

      # Pull Requestの取得
      github.get "repos/#{owner}/#{repo}/pulls", (pulls) ->
        for pr in pulls
          if pr.assignee
            username = pr.assignee.login
            number   = pr.number
            title    = pr.title
            url      = pr.html_url

            task = "##{number} #{title} #{url}"

            col[username].push(task)

        for username in Object.keys(col)
          if col[username].length
            robot.send envelope, "#{username} の担当Pull Requestを送るね。\n" + col[username].join("\n")
          else
            robot.send envelope, "#{username} の担当Pull Requestはないよ。"

  reminder = new cronJob('5 0 8 * * 1-5', () =>
    envelope =
      room: "#general"
    sendAssignedIssues(envelope, owner, repo)
  )
  reminder.start()

  robot.respond /todo/i, (msg) ->
    sendAssignedIssues(msg.envelope, owner, repo)
