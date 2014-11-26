# Description:
#   Create issue on Github.
#
# Dependencies:
#   "githubot": "0.4.x"
#   "hubot-github-identity": "0.9.x"
#
# Configuration:
#   HUBOT_GITHUB_IDENTITY
#   HUBOT_GITHUB_TOKEN
#   HUBOT_GITHUB_USER
#   HUBOT_GITHUB_REPO
#   HUBOT_GITHUB_USER_(.*)
#   HUBOT_GITHUB_API
#
# Commands:
#   hubot issue create <title> - Returns a issue link
#
# TODO:
#   Using wiki page for creating issue / task body message.
#

issue_body = """
# Environment
再現する環境。
* 動作機種
* OSバージョン
* ビルドバージョン

# User impact / importance
ユーザの影響、重要度について記載。
* iOSアプリの全ユーザ
* ユーザシナリオはブロックされないが、画面更新が行われないためUXが阻害される

# Repro steps
問題を再現するためのステップを箇条書きする。
* アプリを起動する
* イベントボタンをタップする
* 画面を下にドラッグする

# Actual result
実際の動作結果（バグと思しき動作結果）を完結に書く。
* 画面の更新が行われない。

# Expected result
期待する動作を完結に書く。
* ドラッグ後に読込中のインジケータが表示されて、その後、表示内容が更新される。

# Screen shots
スクリーンショットのURL
添付があれば「添付参照」と記載。

# Stacktrace
エラー時のスタックトレースがあれば記載。
```
stacktrace
```

# Notes
その他備考をまとめる。
* OSのバグと思われる、とか。
"""

task_body = """
# Objective
このタスクの目的。
* EC2インスタンスの起動を簡略化して、作業時間、人為ミスを減らす。

# Goal (Exit criteria)
このタスクはどうなったら完了か（タスクの達成条件）。
* コマンドを1つ実行するだけで各環境用のEC2インスタンスが起動できる

# Estimated time
作業時間の見積もり。

# Blocker / Related issues
ブロッカーや関連するIssueを箇条書する。
"""

module.exports = (robot) ->

  # github identity error handler
  handleTokenError = (res, err) ->
    switch err.type
      when 'redis'
        res.reply "Oops: #{err}"
      when 'github user'
        res.reply "Sorry, you haven't told me your GitHub username."

  openIssue = (msg, github, title, body) ->
    data = {
      "title": "[Draft] " + title,
      "body": body
    }

    base_url = process.env.HUBOT_GITHUB_API || 'https://api.github.com'
    owner = process.env.HUBOT_GITHUB_USER
    repo = process.env.HUBOT_GITHUB_REPO

    github.post "#{base_url}/repos/#{owner}/#{repo}/issues", data, (issue) ->
      title = issue["title"]
      url = issue["html_url"]
      number = issue["number"]
      msg.reply "issue ##{number} #{title} を作ったよ。 #{url}"

#   assignIssue = (msg, github, issue_number, slack_username) ->

  # main
  github = require("githubot")

  # issue
  robot.respond /issue create (.*)/i, (msg) ->
    title = msg.match[1]
    user = msg.envelope.user.name

    robot.identity.findToken user, (err, token) ->
      if err
        handleTokenError(msg, err)
      else
        openIssue(msg, github(robot, token: token), title, issue_body)

  # task
  robot.respond /task create (.*)/i, (msg) ->
    title = msg.match[1]
    user = msg.envelope.user.name

    robot.identity.findToken user, (err, token) ->
      if err
        handleTokenError(msg, err)
      else
        openIssue(msg, github(robot, token: token), title, task_body)

  # create comment
  robot.respond /issue comment ([0-9]+) (.*)$/i, (msg) ->
    id   = msg.match[1]
    body = msg.match[2]
    url  = "repos/#{owner}/#{repo}/issues/#{id}/comments"
    user = msg.envelope.user.name

    postComment = (github) ->
      github.post url, {body: body}, (comment) ->
        msg.reply "コメントを投稿したよ。 #{comment.html_url}"

    robot.identity.findToken user, (err, token) ->
      if err
        handleTokenError(msg, err)
      else
        postComment(githubot(robot, token: token))
