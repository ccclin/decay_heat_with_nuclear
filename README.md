# decay_heat_with_nuclear

It's a easy way to get nuclear fuel decay heat when it remove from reactor core.
Using 3 method `ASB9-2`, `ANS-1973` and `ANS-1979` to calculate it.

## Install this gem and require it

```
gem install decay_heat_with_nuclear

require 'decay_heat_with_nuclear'
```


## You need a HASH

The hash will like this:

```
hash = {
          ts: array,
          t0: array
       }
```

where
ts is `Time after remove (sec)`,
t0 is `Cumulative reactor operating time (sec)`


## Calculate from this gem

```
DecayHeatWithNuclear.run(hash)
```

and you will get the hash data like:

```
output_hash = {
                ans1979: { ts: array, P/P0: array },
                ans1973: { ts: array, P/P0: array },
                asb9_2:  { ts: array, P/P0: array, P/P0_without_k: array }
              }

```

It's interesting about `ASB9-2`, in this [paper](http://pbadupws.nrc.gov/docs/ML0523/ML052350549.pdf):
```
In calculating the fission produce decay energy, a 20% uncertainty
factor (K) should be added for any cooling time less than 10e3 seconds,
and a factor of 10% should be added for cooling times greater than 10e3
but less than 10e7 seconds.
```
How about `ts` is greater than 10e7 sec? Therefore, using two answer.
Ths answer `P/P0` a factor of 10% should be added, and `P/P0_without_k` without 10% when `ts` is greater than 10e7 sec.
