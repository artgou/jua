should = require('should')
_ = require('underscore')
jua = require('../jua')

describe 'lua script #1', ->
  it 'should translate correctly', ->
    cs = ->
      akey = ARGV[1]
      min = Number(ARGV[2])
      max = Number(ARGV[3])
      offset = Number(ARGV[4])
      count = Number(ARGV[5])
      username = 'anonymous'

      if akey != ''
        username = HGET("akeys:#{akey}", 'username')
        if !username || (username == '')
          return {err: 'InvalidAccessKey'}

      if offset && count
        return ZRANGEBYSCORE("users:#{username}:notifications", min, max, 'limit', offset, count)
      else
        return ZRANGEBYSCORE("users:#{username}:notifications", min, max)

    jua.translate(cs).should.eql '''
local akey
local count
local max
local min
local offset
local username
akey = ARGV[1]
min = tonumber(ARGV[2])
max = tonumber(ARGV[3])
offset = tonumber(ARGV[4])
count = tonumber(ARGV[5])
username = 'anonymous'
if akey ~= '' then
  username = HGET('akeys:' .. akey, 'username')
  if (not(username)) or (username == '') then
    return {err = 'InvalidAccessKey'}
  end
end
if (offset) and (count) then
  return ZRANGEBYSCORE('users:' .. username .. ':notifications', min, max, 'limit', offset, count)
else
  return ZRANGEBYSCORE('users:' .. username .. ':notifications', min, max)
end'''
