require 'open3'

# for more info, check out: /usr/local/claymoreEth/Readme\!\!\!.txt
class ClaymoreWrapper
  attr_reader :eth_address, :worker_name, :mining_pool, :port

  def initialize(eth_address: '0xbe7c8aC3E1153323217da4ea5F22Aa7e3d9Cbd07',
                 worker_name: 'daviriel',
                 mining_pool: 'eth-us-east1.nanopool.org',
                 port: '9999')
    @eth_address = eth_address
    @worker_name = worker_name
    @mining_pool = mining_pool
    @port = port
  end

  def run!(monitor: true, slowdown_threshold: nil, shutdown_threshold: nil)
    command = command_constructor(monitor, slowdown_threshold, shutdown_threshold)
    puts "executing #{command}"
    while true
      unless miner_running?
        Open3.popen3("#{command}") do |stdout, stderr, status, thread|
          while line=stderr.gets do 
            puts(line) 
          end
        end 
      end
    end
  end

  private

  def command_constructor(monitor, slowdown_threshold, shutdown_threshold)
    command_list = []
    claymore_executable = '/usr/local/claymoreEth/ethdcrminer64'
    command_list.push(
      claymore_executable,
      eth_wallet,
      eth_pool,
      eth_only_mode,
      pool_password,
      failover_threshold,
      debug_mode,
      log
    )
    command_list.push(monitor_flag) if monitor
    command_list.push(miner_slowdown_temp(slowdown_threshold)) unless slowdown_threshold.nil?
    command_list.push(miner_shutdown_temp(shutdown_threshold)) unless shutdown_threshold.nil?
    command_list.join(' ')
  end

  def miner_running?
    ethminer_processes = (`ps aux | grep [c]laymore`).split(/\n/)
    ethminer_processes.length >= 1
  end

  def log
    "-logfile ~/Desktop/mining_logs/claymore_log.txt"
  end

  # -ewal YOUR_WALLET/YOUR_WORKER/YOUR_EMAIL
  def eth_wallet
    "-ewal #{eth_address}/#{worker_name}"
  end

  def eth_pool
    # -epool  Ethereum pool address. Only Stratum protocol is supported for pools.
    # Miner supports all pools that are compatible with Dwarfpool proxy and accept 
    # Ethereum wallet address directly.
    "-epool #{mining_pool}:#{port}"
  end

  def eth_only_mode
    # current developer fee is 1% for Ethereum-only mining mode (-mode 1) and 2% 
    # for dual mining mode (-mode 0)
    '-mode 1'
  end

  # -epsw   Password for Ethereum pool, use "x" as password.
  def pool_password
    '-epsw x'
  end

  # -dbg    debug log and messages. "-dbg 0" - (default) create log file but don't show debug messages.
  # "-dbg 1" - create log file and show debug messages. "-dbg -1" - no log file and no debug messages.
  def debug_mode
    '-dbg 1'
  end

  #  -ttli   reduce entire mining intensity (for all coins) automatically if GPU
  # temperature is above specified value. For example, "-ttli 80" reduces mining
  # intensity if GPU temperature is above 80C.
  #   You can see if intensity was reduced in detailed statistics ("s" key).
  #   You can also specify values for every card, for example "-ttli 80,85,80". 
  def miner_slowdown_temp(slowdown_threshold)
    "-ttli #{slowdown_threshold}"
  end

  # -tstop  set stop GPU temperature, miner will stop mining if GPU reaches 
  # specified temperature. For example, "-tstop 95" means 95C temperature. 
  # You can also specify values for every card, for example "-tstop 95,85,90".
  def miner_shutdown_temp(shutdown_threshold)
    "-tstop #{shutdown_threshold}"
  end

  # -mport  remote monitoring/management port. Default value is -3333 (read-only mode), 
  # specify "-mport 0" to disable remote monitoring/management feature.
  #   Specify negative value to enable monitoring (get statistics) but disable management 
  #   (restart, uploading files), for example, "-mport -3333" enables port 3333 for remote 
  #   monitoring, but remote management will be blocked.
  #   You can also use your web browser to see current miner state, for example,
  #   type "localhost:3333" in web browser.
  #   Warning: use negative option value or disable remote management entirely if you think
  #   that you can be attacked via this port!
  #   By default, miner will accept connections on specified port on all network 
  #   adapters, but you can select desired network interface directly, for example, 
  #   "-mport 127.0.0.1:3333" opens port on localhost only.  
  def monitor_flag
    '-mport -3334'
  end

  def failover_threshold
    # Use "epools.txt" and "dpools.txt" files to specify additional pools. These files have text format, one pool per line. 
    # Every pool has 3 connection attempts.
    # Miner disconnects automatically if pool does not send new jobs for a long time or if pool rejects too many shares.
    # If the first character of a line is ";" or "#", this line will be ignored.
    # Do not change spacing, spaces between parameters and values are required for parsing.
    # If you need to specify "," character in parameter value, use two commas - ,, will be treated as one comma.
    # You can reload "epools.txt" and "dpools.txt" files in runtime by pressing "r" key.
    # Pool specified in the command line is "main" pool, miner will try to return to it every 30 minutes if it has 
    # to use some different pool from the list.
    # If no pool was specified in the command line then first pool in the failover pools list is main pool.
    # You can change 30 minutes time period to some different value with "-ftime" option, or use "-ftime 0" 
    # to disable switching to main pool.
    # You can also use environment variables in "epools.txt", "dpools.txt" 
    # and "config.txt" files. For example, define "WORKER" environment variable and
    # use it as "%WORKER%" in config.txt or in epools.txt.
    # You can also select current pool in runtime by pressing "e" or "d" key.
    '-ftime 10'
  end
end
