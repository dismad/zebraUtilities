# How to get lastest Supply info using a Zebra node



## Download and compile Zebrad

`cargo install --git https://github.com/ZcashFoundation/zebra --tag v2.0.1 zebrad`



## Generate config and adjust as needed

`zebrad generate -o ~/.config/zebrad.toml`





## Download scripts 

Allow them to execute:

`chmod +x toCurl.sh extractSupplyInfoZebraDEV.sh`



## Use


`./extractSupplyInfoZebraDEV.sh`
