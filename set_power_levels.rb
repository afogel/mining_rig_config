
puts "Setting GPU 0 (GTX 1070) to max 100 W"
# GTX 1070
# sudo nvidia-smi -i 0 --format=csv,noheader,nounits --query-gpu=power.limit
# 200.0
# 200.0 * 0.50 = 100
`sudo nvidia-smi -i 0 -pl 100`

puts "Setting GPU 1 (GTX 1060) to max 75 W"
# GTX 1060
# sudo nvidia-smi -i 1 --format=csv,noheader,nounits --query-gpu=power.limit
# 120
# 120 * 0.64 = 75
`sudo nvidia-smi -i 1 -pl 75`

puts "Setting GPU 2 (GTX 1070) to max 95 W"
# GTX 1070
# sudo nvidia-smi -i 2 --format=csv,noheader,nounits --query-gpu=power.limit
# 151
# 151 * 0.64 = 95
`sudo nvidia-smi -i 2 -pl 95`

puts "Setting GPU 3 (GTX 1060) to max 75 W"
# GTX 1060
# sudo nvidia-smi -i 3 --format=csv,noheader,nounits --query-gpu=power.limit
# 120
# 120 * 0.64 = 75
`sudo nvidia-smi -i 3 -pl 75`

puts "Setting GPU 4 (GTX 1070) to max 95 W"
# GTX 1070
# sudo nvidia-smi -i 4 --format=csv,noheader,nounits --query-gpu=power.limit
# 151
# 151 * 0.64 = 95
`sudo nvidia-smi -i 4 -pl 95`
