# Description:
#   Create issue on Github.
#
# Dependencies:
#   "githubot": "0.4.x"
#
# Configuration:
#   HUBOT_GITHUB_TOKEN
#   HUBOT_GITHUB_USER
#   HUBOT_GITHUB_REPO
#   HUBOT_GITHUB_USER_(.*)
#   HUBOT_GITHUB_API
#
# Commands:
#   hubot issue create <title> - Returns a issue link
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

# TODO
このタスクはどのような作業をするのか。（ざっくりと箇条書き。あとでサブタスクに分ける）
* EC2のタグを元にIPアドレスの一覧を取得するコマンド作成
* サーバのIPアドレス、ロール、環境名を引数に取る、インスタンス生成用コマンドの作成

# Blocker / Related issues
ブロッカーや関連するIssueを箇条書する。
"""

module.exports = (robot) ->
  github = require("githubot")(robot)

  robot.respond /issue create (.*)/i, (msg) ->
    title = msg.match[1]
    data = {
      "title": "[Draft] " + title,
      "body": issue_body
    }
    base_url = process.env.HUBOT_GITHUB_API || 'https://api.github.com'
    owner = process.env.HUBOT_GITHUB_USER
    repo = process.env.HUBOT_GITHUB_REPO
    github.post "#{base_url}/repos/#{owner}/#{repo}/issues", data, (issue) ->
      title = issue["title"]
      url = issue["html_url"]
      number = issue["number"]
      msg.send "issue ##{number} #{title} を作ったよ。 #{url}"

  robot.respond /task create (.*)/i, (msg) ->

    title = msg.match[1]
    data = {
      "title": "[Draft] " + title,
      "body": task_body
    }
    base_url = process.env.HUBOT_GITHUB_API || 'https://api.github.com'
    owner = process.env.HUBOT_GITHUB_USER
    repo = process.env.HUBOT_GITHUB_REPO
    github.post "#{base_url}/repos/#{owner}/#{repo}/issues", data, (issue) ->
      title = issue["title"]
      url = issue["html_url"]
      number = issue["number"]
      msg.send "issue ##{number} #{title} を作ったよ。 #{url}"
