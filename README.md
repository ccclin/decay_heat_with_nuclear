# decay_heat_with_nuclear

It's a easy way to get nuclear fuel decay heat when it remove from reactor core.
Using 3 method `ASB9-2`, `ANS-1973` and `ANS-1979` to calculate it.

## Install this gem

```
gem install decay_heat_with_nuclear
```


## Yor need a HASH

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
                asb9_2:  { ts: array, P/P0: array },
              }

```
