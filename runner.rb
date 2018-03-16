#! /usr/bin/env ruby

require_relative './gpu_configurer'
require_relative './miner_wrapper'
require_relative './claymore_wrapper'

# Configure GPUs

puts "Starting GPU configuration"

# GeForce GTX 1070 - Fully functional for overclocking
GPUConfigurer.new(
  gpu_position: 0, 
  graphics_clock_offset: -50,
  memory_offset: 700,
  fan_power: 55,
  stock_setting: false
).configure!

# GeForce GTX 1060 - Fully functional for overclocking
GPUConfigurer.new(
  gpu_position: 1, 
  graphics_clock_offset: -50,
  memory_offset: 700,
  fan_power: 55,
  stock_setting: false
).configure!

# GeForce GTX 1070 - Not functional for overclocking
GPUConfigurer.new(
  gpu_position: 2, 
  graphics_clock_offset: 0,
  memory_offset: 0,
  fan_power: 55,
  stock_setting: true
).configure!

# GeForce GTX 1060 - Fully functional for overclocking 
GPUConfigurer.new(
  gpu_position: 3, 
  graphics_clock_offset: -50,
  memory_offset: 700,
  fan_power: 55,
  stock_setting: false
).configure!

# GeForce GTX 1070 Mini - Not functional for overclocking
 GPUConfigurer.new(
  gpu_position: 4,
  graphics_clock_offset: 0,
  memory_offset: 0,
  fan_power: 65,
  stock_setting: true
).configure!


# Run miner
ClaymoreWrapper.new.run!(monitor: true, slowdown_threshold: 65, shutdown_threshold: 70)
