# -*- ruby -*-

require 'rubygems'
require 'hoe'
require './lib/measurement.rb'

Hoe.new('measurement', Measurement::VERSION) do |p|
  p.rubyforge_name = 'measurement'
  p.author = 'Daniel Morrison'
  p.email = 'daniel@collectiveidea.com'
  p.summary = 'A library for dealing with all kinds of measurements'
  p.description = p.paragraphs_of('README.txt', 2..5).join("\n\n")
  p.url = p.paragraphs_of('README.txt', 0).first.split(/\n/)[1..-1]
  p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
end

# vim: syntax=Ruby
