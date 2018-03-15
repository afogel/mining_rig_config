class GPUConfigurer
  attr_reader :gpu_position, 
              :graphics_clock_offset, 
              :memory_offset, 
              :fan_power, 
              :stock_setting

  def initialize(gpu_position:, 
                 graphics_clock_offset: -50, 
                 memory_offset: 700, 
                 fan_power: 55, 
                 stock_setting: false)
    @gpu_position = gpu_position
    @graphics_clock_offset = graphics_clock_offset
    @memory_offset = memory_offset
    @fan_power = fan_power
  end

  def configure!
    set_universal_configurations!
    message_helper("GPU config unaltered - remaining at stock settings") if stock_setting
    return if stock_setting
    set_overclock_configurations!
  end

  private
  # *****************
  # Class helpers
  # *****************

  def set_universal_configurations!
    message_helper("Configuring GPU #{gpu_position}")
    set_persistence_mode!
    run_fan!
  end

  def set_overclock_configurations!
    set_maximum_performance_mode!
    set_graphics_clock_offset!
    set_memory_offset!
  end

  def message_helper(message)
    puts "*********************************************************************"
    puts message
    puts "*********************************************************************"
    puts 
  end

  # ***********************************
  # NVIDIA COMMAND WRAPPERS
  # ***********************************

  def ssh_prefix
    'sudo DISPLAY=:0 XAUTHORITY=/var/run/lightdm/root/:0 nvidia-settings'
  end
  
  def run_fan!
    message_helper("Starting fans at #{fan_power}%")
    `#{ssh_prefix} nvidia-settings -a [gpu:#{gpu_position}]/GPUFanControlState=1`
    `#{ssh_prefix} nvidia-settings -a [gpu:#{gpu_position}]/GPUTargetFanSpeed=#{fan_power}`
  end

  def set_persistence_mode!
    message_helper("Enabling persistence mode")
    `sudo nvidia-smi -pm 1`
  end

  def set_graphics_clock_offset!
    message_helper("Setting GPU Graphics Clock Offset to #{fan_power}%")
    `#{ssh_prefix} nvidia-settings -a \ 
      [gpu:#{gpu_position}]/GPUGraphicsClockOffset[3]=#{graphics_clock_offset}`
  end

  def set_memory_offset!
    message_helper("Setting GPU Memory Transfer Rate Offset to #{memory_offset}")
    `#{ssh_prefix} nvidia-settings -a  \
      [gpu:#{gpu_position}]/GPUMemoryTransferRateOffset[3]=#{memory_offset}`
  end
  
  # Force Powermizer to a certain level at all times
  # level 0x1=highest
  # level 0x2=med
  # level 0x3=lowest
  def set_maximum_performance_mode!
    message_helper('Setting GPU to Prefer Maximum Performance mode')
    `#{ssh_prefix} nvidia-settings -a [gpu:#{gpu_position}]/GpuPowerMizerMode=1`
  end

  # TODO: expose API for control over power threshold
  def lower_power_limits!(percent_threshold: .8)
    # percent_threshold value should be between 0 and 1
    power_limit = current_power_limit
    new_power_limit = (power_limit * percent_threshold).to_i
    message_helper(
      "Setting power limits from #{power_limit} to #{new_power_limit}"
    )
    `sudo nvidia-smi -i #{i} -pl #{new_power_limits}`
  end

  # **********************************
  # NVIDIA CONFIG HELPERS
  # **********************************

  def current_power_limit
    `sudo nvidia-smi -i #{gpu_position} \
       --format=csv,noheader,nounits --query-gpu=power.limit`.to_i
  end
end
