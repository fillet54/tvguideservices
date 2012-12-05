chai = require 'chai'
chai.should()

{TimeARU} = require '../src/TimeARU'

describe 'TimeARU', ->
   timeAru = new TimeARU()
   it 'should add two times', ->
      timeAru.add_minutes(180, 60).should.equal 240
