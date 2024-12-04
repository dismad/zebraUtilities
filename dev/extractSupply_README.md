# How to get lastest Supply info using a Zebra node

## Install RUST

On Linux and macOS systems, this is done as follows:

`curl https://sh.rustup.rs -sSf | sh`

It will download a script, and start the installation. If everything goes well, you’ll see this appear:

`Rust is installed now. Great!`

On Windows, download and run [rustup-init.exe](https://win.rustup.rs/). It will start the installation in a console and present the above message on success.

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


![Screenshot_2024-12-03_22-24-12](https://github.com/user-attachments/assets/a4f7eedf-bf61-4caf-a4ce-7e16b9bcbd73)
