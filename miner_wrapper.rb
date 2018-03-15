class MinerWrapper
  attr_reader :eth_address, :worker_name, :mining_pool, :port
  def initialize(eth_address: '0xbe7c8aC3E1153323217da4ea5F22Aa7e3d9Cbd07',
                 worker_name: 'daviriel',
                 mining_pool: 'http://eth-us-east1.nanopool.org',
                 port: '8888')
    @eth_address = eth_address
    @worker_name = worker_name
    @mining_pool = mining_pool
    @port = port
  end

  def miner_running?
    ethminer_processes = (`ps aux | grep [e]thminer`).split(/\n/)
    ethminer_processes.length >= 1
  end

  def run_miner!
    while true
      start_miner! unless miner_running?
    end
  end

  private

  def start_miner!
    # Piping output to a logfile using tee: 
    # https://stackoverflow.com/questions/418896/how-to-redirect-output-to-a-file-and-stdout
    miner_start_command = "ethminer -U -G -F #{mining_pool}:#{port}/#{eth_address}@#{worker_name}"
    log_capture = 'tee -a ~/Desktop/mining_logs/latest_entries.txt'
    `#{miner_start_command} 2>&1 | #{log_capture}` 
  end
end
