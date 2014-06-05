Helper = require('hubot-test-helper')
helper = new Helper('../../scripts')

_      = require('underscore')
assert = require('power-assert')

describe 'mahjong-events', ->
  shouldHaveConversation = (conversation) ->
    room = helper.createRoom()

    _.each conversation, (0: user, 1: message) ->
      if user != 'hubot'
        room.user.say user, message

    assert.deepEqual _.flatten(room.messages), _.flatten(conversation)

  it '参加者を登録できること', ->
    shouldHaveConversation([
      ['mtsmfm', '@hubot 面子 5/22 19:00- ブル']
      ['hubot',  '@all 5/22 19:00- ブル で麻雀をやるそうですよ']
      ['flada',  '@hubot true']
      ['hubot',  '@mtsmfm 5/22 19:00- ブル での麻雀に @flada が参加されます']
      ['tanaka', '@hubot true']
      ['hubot',  '@mtsmfm @flada 5/22 19:00- ブル での麻雀に @tanaka が参加されます']
      ['maguchi','@hubot true']
      ['hubot',  '@all 5/22 19:00- ブル での麻雀の面子が揃いました! @mtsmfm @flada @tanaka @maguchi です']
    ])
