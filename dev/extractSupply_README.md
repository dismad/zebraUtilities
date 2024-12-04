# How to get lastest Supply info using a Zebra node



## Download and compile Zebrad

`cargo install --git https://github.com/ZcashFoundation/zebra --tag v2.0.1 zebrad`



## Generate config and adjust as needed

`zebrad generate -o ~/.config/zebrad.toml`

Make sure the RPC section looks like this:

```
[rpc]
debug_force_finished_sync = false
# listen for RPC queries on localhost
listen_addr = "127.0.0.1:8232"
# automatically use multiple CPU threads
parallel_cpu_threads = 0
enable_cookie_auth = false
```

You can turn on cookie auth if you want, just add the username and pw in toCurl.sh


## Sync Zebra

`zebrad start`


## Download scripts 

Allow them to execute:

`chmod +x toCurl.sh extractSupplyInfoZebraDEV.sh`



## Use


`./extractSupplyInfoZebraDEV.sh`
