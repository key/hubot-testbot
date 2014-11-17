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
  cronjob = new cronJob('0 0 12 * * 1-5', () =>
    envelope =
      room: "#general"
    robot.send envelope, "お昼です。"
  )

  cronjob.start()
