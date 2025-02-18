# How to get latest Supply info using a Zebra node

## Install RUST

On Linux and macOS systems, this is done as follows:

`curl https://sh.rustup.rs -sSf | sh`

It will download a script, and start the installation. If everything goes well, you’ll see this appear:

`Rust is installed now. Great!`

On Windows, download and run [rustup-init.exe](https://win.rustup.rs/). It will start the installation in a console and present the above message on success.

## Download and compile Zebrad

`cargo install --git https://github.com/ZcashFoundation/zebra --tag v2.1.0 zebrad`



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
* [toCurl](https://github.com/dismad/zebraUtilities/blob/main/dev/toCurl.sh)
* [extractSupplyInfoZebraDEV](extractSupplyInfoZebraDEV.sh)
  
Allow them to execute:

`chmod +x toCurl.sh extractSupplyInfoZebraDEV.sh`



## Use


`./extractSupplyInfoZebraDEV.sh`

![Screenshot_2024-12-03_22-35-42](https://github.com/user-attachments/assets/bac68437-fd1b-4744-b30e-674f7e46cbd4)

## Video example

https://www.youtube.com/watch?v=Ok9Wa8FNbMA

