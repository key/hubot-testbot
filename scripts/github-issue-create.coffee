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

owner = "key"
repo = "PhotoShare"
endpoint = "/repos/" + owner + "/" +repo + "/issues"
endpoint = "/repos/key/PhotoShare/issues"

module.exports = (robot) ->
  
  robot.respond /issue create (.*)/i, (msg) ->
    github = require("githubot")(robot)

    title = msg.match[0]
    data = {
      "title": title,
      "body": """
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
    }
    base_url = process.env.HUBOT_GITHUB_API || 'https://api.github.com'
    github.post "#{base_url}/repos/#{owner}/#{repo}/issues", data, (issue) ->
      console.log issue

   # msg.http("https://api.github.com" + endpoint)
   #   .header("Accept", "application/vnd.github.v3+json")
   #   .header("User-Agent", "hubot")
   #   .post(data) (err, res, body) ->
   #     msg.send(body)
    