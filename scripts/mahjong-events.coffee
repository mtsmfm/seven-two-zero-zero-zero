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

  isFull: ->
    @attendees.length == 4

class Nodoka
  @messageOnCreated: (event) ->
    "@all #{event.toString()} で麻雀をやるそうですよ"

  @messageWhenFull: (event) ->
    '面子が揃っちゃいました ><'

  @messageOnAttended: (event) ->
    [attendees..., newAttendee] = event.attendees
    mentions = attendees.map((user) -> "@#{user}").join(' ')
    "#{mentions} #{event.toString()} での麻雀に @#{newAttendee} が参加されます"

  @messageOnFilled: (event) ->
    mentions = event.attendees.map((user) -> "@#{user}").join(' ')
    "@all #{event.toString()} での麻雀の面子が揃いました! #{mentions} です"

module.exports = (robot) ->
  event = null

  robot.respond /面子 (.*)- (.*)$/i, (msg) ->
    try
      event = new MahjongEvent(msg.message.user.name, msg.match[1], msg.match[2])

      msg.send Nodoka.messageOnCreated(event)
    catch
      # TODO invalid だった場合の処理

  robot.respond /true$/i, (msg) ->
    # TODO ないときのメッセージ
    return unless event
    return msg.send Nodoka.messageWhenFull(event) if event.isFull()

    event.attend(msg.message.user.name)

    if event.attendees.length < 4
      msg.send Nodoka.messageOnAttended(event)
    else
      msg.send Nodoka.messageOnFilled(event)
