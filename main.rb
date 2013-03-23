require 'celluloid'

class Master
  include Celluloid

  def initialize(workers)
    @idle_workers = workers
    @active_workers = []
  end

  def enqueue(job)
    @idle_workers.sort_by! { rand }
    if worker = @idle_workers.pop
      Celluloid.logger.warn "found a worker: #{worker.name}"
      @active_workers << worker
      debug_it
      worker.async.perform(current_actor, job)
    else
      raise "no workers"
    end
  end

  def done(worker)
    debug_it
    @idle_workers << @active_workers.delete(worker)
    debug_it
  end

  def debug_it
    io = StringIO.new
    @active_workers.size.times do
      io << "+"
    end
    @idle_workers.size.times do
      io << "-"
    end
    Celluloid.logger.warn io.string
  end
end

class Worker
  include Celluloid

  def initialize(name)
    @name = name
  end
  attr_reader :name

  def perform(master, job)
    Celluloid.logger.warn "running #{job.inspect} on #{@name.inspect}"
    sleep 0.1
    Celluloid.logger.warn "finished with #{job.inspect}"
    master.done(current_actor)
  end
end

workers = 10.times.map do |number|
  Worker.new("worker-#{number}")
end
master = Master.new(workers)

200.times do |number|
  master.enqueue("hack the mainframe #{number} times")
  sleep 0.01
end

sleep 10
