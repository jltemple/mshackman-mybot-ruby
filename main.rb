#!/usr/bin/env ruby

STDOUT.sync = true

require_relative 'game'

game = Game.new("bixiette")

game.run()