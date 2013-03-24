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
