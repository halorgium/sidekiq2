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
