require 'celluloid'
require_relative 'master'
require_relative 'worker'

workers = 10.times.map do |number|
  Worker.new("worker-#{number}")
end
master = Master.new(workers)

200.times do |number|
  master.enqueue("hack the mainframe #{number} times")
  sleep 0.01
end

sleep 10
