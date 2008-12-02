# -*- ruby -*-
require 'spec/rake/spectask'
require 'hoe'
require './lib/measurement.rb'

Hoe.new('measurement', Measurement::VERSION) do |p|
  p.rubyforge_name = 'measurement'
  p.author = 'Daniel Morrison'
  p.email = 'daniel@collectiveidea.com'
  p.summary = 'A library for dealing with all kinds of measurements'
  p.description = p.paragraphs_of('README.textile', 2..5).join("\n\n")
  p.url = p.paragraphs_of('README.textile', 0).first.split(/\n/)[1..-1]
  p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
  p.extra_deps << ['activesupport']
end

# vim: syntax=Ruby

desc 'Default: run specs.'
task :default => :spec

desc 'Test the acts_as_audited plugin'
Spec::Rake::SpecTask.new(:spec) do |t|
  t.libs << 'lib'
  t.pattern = 'spec/**/*_spec.rb'
  t.verbose = true
end