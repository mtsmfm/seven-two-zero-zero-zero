# Description:
#   Announce mahjong event
#
# Commands:
#   hubot 面子 <datetime> <place>

moment = require('moment')

class MahjongEvent
  constructor: (@host, heldAt, @place) ->
    @heldAt = moment(heldAt, 'M/D H:m')
    @attendees = [@host]

  toString: ->
    "#{@heldAt.format('M/D HH:mm')}- #{@place}"

  attend: (user) ->
    @attendees.push user

module.exports = (robot) ->
  event = null

  robot.respond /面子 (.*)- (.*)$/i, (msg) ->
    try
      event = new MahjongEvent(msg.message.user.name, msg.match[1], msg.match[2])

      msg.send "@all #{event.toString()} で麻雀をやるそうですよ"
    catch
      # TODO invalid だった場合の処理

  robot.respond /true$/i, (msg) ->
    # TODO ないときのメッセージ
    return unless event

    event.attend(msg.message.user.name)

    if event.attendees.length < 4
      [attendees..., newAttendee] = event.attendees
      mentions = attendees.map((user) -> "@#{user}").join(' ')
      msg.send "#{mentions} #{event.toString()} での麻雀に @#{newAttendee} が参加されます"
    else
      mentions = event.attendees.map((user) -> "@#{user}").join(' ')
      msg.send "@all #{event.toString()} での麻雀の面子が揃いました! #{mentions} です"
