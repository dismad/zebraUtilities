# How to get lastest Supply info using a Zebra node



## Download and compile Zebrad

`cargo install --git https://github.com/ZcashFoundation/zebra --tag v2.0.1 zebrad`



## Generate config and adjust as needed

`zebrad generate -o ~/.config/zebrad.toml`





## Download scripts 

`chmod +x toCurl.sh extractSupplyZebra.sh`



## Use


`./extractSupplyZebra.sh`
