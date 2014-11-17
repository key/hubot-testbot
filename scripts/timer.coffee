cronJob = require('cron').CronJob

module.exports = (robot) ->
  cronjob = new cronJob('0 0 12 * * 1-5', () =>
    envelope =
      room: "#general"
    robot.send envelope, "お昼です。"
  )

  cronjob.start()

  t = new cronJob('0 */5 * * * 1-5', () =>
    envelope =
      room: "#hubot-test"
    robot.send envelope, "cronのテスト"
  )

  t.start()
