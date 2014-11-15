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
#   hubot pr create <title> <head> - Returns a PR link
#

pr_body = """
# レビュワー
* レビュワーとは別にマージして欲しい担当のアカウントを指定
* iOS/Androidの共通仕様はレビュワーに相手側も入れる

# 関連URL
* Issue Number

# 概要
* なぜこの変更をするのか、
* 課題は何か、
* これによってどう解決されるのか、
* など、この変更に対する概要を記載 

# 影響範囲・ターゲットユーザ
* 確認する箇所や対象者
* ログインしているかどうかなど

# 技術的変更点概要
* 変更の方針等

# UIに対する変更
* 変更前のスクリーンショット
* 変更後のスクリーンショット

# マイグレーション
* 変更箇所、マイグレーション対象ファイル
"""

module.exports = (robot) ->
  github = require("githubot")(robot)

  robot.respond /pr create (.*) (.*)/i, (msg) ->
    base_url = process.env.HUBOT_GITHUB_API || 'https://api.github.com'
    owner = process.env.HUBOT_GITHUB_USER
    repo = process.env.HUBOT_GITHUB_REPO

    title = msg.match[1]
    head_branch = "#{owner}:" + msg.match[2]
    base_branch = "develop"
    data = {
      "title": title,
      "body": pr_body,
      "head": head_branch,
      "base": base_branch
    }
    github.post "#{base_url}/repos/#{owner}/#{repo}/pulls", data, (issue) ->
      title = issue["title"]
      url = issue["html_url"]
      number = issue["number"]
      msg.send "Pull Request ##{number} #{title} を作ったよ。 #{url}"

    github.handleErrors (response) ->
      body = JSON.parse(response.body)
      errors = body["errors"]
      error = errors[0]
      error_msg = error["message"]

      if response.statusCode == 422
        msg.send "エラーが発生しました。詳細は次の通り。\n#{error_msg}"
