#!/usr/bin/env ruby

STDOUT.sync = true

require_relative 'lib/game'

game = Game.new("bixiette")

game.run()