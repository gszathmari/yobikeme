cluster = require 'cluster'
os = require 'os'
domain  = require 'domain'

logger = require './helpers/logger'
newrelic = require './helpers/newrelic'

startWorker = ->
  worker = cluster.fork()
  logger.info 'CLUSTER: Worker %d started', worker.id

if cluster.isMaster
  if process.env.WORKERS
    maxWorkers = (Number process.env.WORKERS) + 1
    startWorker() while maxWorkers -= 1
  else
    startWorker cpu for cpu in os.cpus()

  cluster.on 'disconnect', (worker) ->
    logger.warn "CLUSTER: Worker %d disconnected from cluster.", worker.id

  cluster.on 'exit', (worker, code, signal) ->
    logger.warn "CLUSTER: Worker %d died with exit code %d (%s)",
      worker.id, code, signal
    startWorker()

else
  d = domain.create()

  d.on 'error', (er) ->
    logger.error "DOMAIN: exception caught, exiting."
    logger.debug er.stack

    try
      killTimer = setTimeout ->
        logger.warn "DOMAIN: Failsafe shutdown"
        process.exit(1)
      , 1000 * 5
      killTimer.unref()

      unless cluster.worker.suicide
        cluster.worker.disconnect()
    catch er2
      logger.error "DOMAIN: Failsafe shutdown failed"
      logger.debug er2.stack

  d.run ->
    do -> require './server'
