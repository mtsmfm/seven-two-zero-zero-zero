# Description:
#   Announce mahjong event
#
# Commands:
#   hubot 面子 <datetime> <place>

moment = require('moment')

class MahjongEvent
  constructor: (@host, @room, heldAt, @place) ->
    @heldAt = moment(heldAt, 'M/D H:m')
    throw "Invalid format of date : #{heldAt}" unless @heldAt.isValid()
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

  @messageNotification: (event) ->
    mentions = event.attendees.map((user) -> "@#{user}").join(' ')
    "#{mentions} #{event.toString()} の麻雀がそろそろ始まりますよ"

  @messageInvalidFormat: ->
    '面子募集のフォーマットがおかしいです (面子 月/日 時間- 場所)'

cron = require('cron').CronJob

module.exports = (robot) ->
  new cron '*/1 * * * *', =>
    console.log '---------------------------------------------------------'
    console.log robot
    console.log event
    return unless event
    return unless event.isFull()

    console.log 'hi'
    console.log event.heldAt.diff(moment(), 'hours', true)
    if event.heldAt.diff(moment(), 'hours', true) <= 1
      robot.send {room: event.room}, Nodoka.messageNotification(event)
      event = null
  , null, true

  event = null

  robot.respond /面子 (.*)- (.*)$/i, (msg) ->
    try
      event = new MahjongEvent(msg.message.user.name, msg.message.room, msg.match[1], msg.match[2])

      msg.send Nodoka.messageOnCreated(event)
    catch
      msg.send Nodoka.messageInvalidFormat()

  robot.respond /true$/i, (msg) ->
    # TODO ないときのメッセージ
    return unless event
    return msg.send Nodoka.messageWhenFull(event) if event.isFull()

    event.attend(msg.message.user.name)

    if event.attendees.length < 4
      msg.send Nodoka.messageOnAttended(event)
    else
      msg.send Nodoka.messageOnFilled(event)
