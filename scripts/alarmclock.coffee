# Description:
#   Tweet clock periodically
#
# Dependencies:
#   "cron"
#   "time"
#
# Configuration:
#   TZ
#

cronJob = require('cron').CronJob

module.exports = (robot) ->

  # TODO 日の出の時間につぶやく
  # TODO 天気をつぶやく

  # 始業
  beginning = new cronJob('0 0 8 * * 1-5', () =>
    envelope =
      room: "#general"
    robot.send envelope, "@channel 朝だよ。"
  )

  beginning.start()

  # ランチ
  lunch = new cronJob('0 0 12 * * 1-5', () =>
    envelope =
      room: "#general"
    robot.send envelope, "@channel お昼だよ。"
  )

  lunch.start()

  # 終業
  ending = new cronJob('0 0 18 * * 1-5', () =>
    envelope =
      room: "#general"
    robot.send envelope, "@channel 夜だよ。"
  )

  ending.start()
