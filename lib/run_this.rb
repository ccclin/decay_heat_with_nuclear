require './text_to_array.rb'
require './run_ans_1979.rb'
require './run_ans_1973.rb'
require './run_asb_9_2.rb'

# 執行此程式需要一個hash
# 裡面必須含有ts (sec)、t0 (sec)、power (MW)
#
# hash =  {ts: array,
#          t0: array,
#          power: array}
#
# 抑或可以利用TextToArray.new(相對路徑)讀取文字檔
# 文字檔格式如下，其中(TAB)表示輸入Tab鍵、(ENTER)表示輸入Enter鍵
#
# ts(TAB)t0(TAB)power(ENTER)
#
# ks_ts_t0_power.txt為範例檔

output = TextToArray.new('./ks_ts_t0_power.txt')
hash1 = output.output

# ts = []
# times = 1
# t_index = 0
# while t_index <= 1 * 365 * 86400
#   index = 1
#   while index < 10
#     t_index = index * times
#     ts << t_index
#     index = index + 1
#   end
#   times = times * 10
# end
# ts << 365 * 86400
ts = Array.new(20) { |i| i = (i + 1) * 365 * 24 * 3600 }
hash2 = { ts: ts,
          t0: Array.new(ts.size) { |i| i = 63 * 30 * 24 * 3600 },
          power: Array.new(ts.size) { |i|  i = 2943 }}

# 執行RunAns1979.new(hash, case)來配置前置檔案
# hash即為上面說明的hash
# case為輸出的類型
#
# case = 0
#  ts(year)     t(sec)           P/P0
#     1        31536000      0.000281683414
#
# case = 1
#       ts             P/P0
# ts =    1 years P/P0= 0.000281683414
#
# case = 2
#         ts                     t0                 un                P/P0 without un/K            P/P0 with un/K           power
# ts = 31536000.0 sec, t0 = 141912000.0 sec, un = 0.06000000, P/P0(without un) = 0.00028168, P/P0(with un) = 0.00029858, power = 0.90471 MW
# P/P0 with un = (P/P0 without un) * (1 + un)
#
# P.S RunASB9_2的K值比較特殊，without K 的意思是指當 ts > 10^7 時將 K = 0
#
# 或是可以編輯'run_ans_1979.rb'第37行，增加自訂的輸出方式

test2 = RunASB9_2.new(hash2, 3, 'ASB9-2_1to20years.txt')
test2.run

test3 = RunAns1973.new(hash2, 3, 'Ans1973_1to20years.txt')
test3.run

test1 = RunAns1979.new(hash2, 3, 'Ans1979_1to20years.txt')
test1.run
