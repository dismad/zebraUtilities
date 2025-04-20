# ZebraUtilities
Helper scripts for using zebra. Will need a running and synced zebra node installed. See here for more info:

https://zechub.wiki/zebra

## Prerequisites

`chmod + x` all .sh files and use as needed.

Can access Zebra RPC's using `toCurl.sh`or equivalent.
```
* extractSupplyInfoZebra.sh                  // Extract ZEC supply information
* txDetails.sh                               // Display info about any tx via Zebra
* zebraPeers.sh                              // Display connected peers to your node
* blockFoundSummaryZebra.sh                  // Display blocks and tx's as they are mined
* listTXs.sh                                 // List all Tx's in any block interval
* getDateFromTX.sh                           // Display Date of inputed TX
```

## DEV version

For the latest updates, check out the dev folder. *They are changed often*

## Extract Supply Info
![Screenshot_2024-12-07_12-19-54](https://github.com/user-attachments/assets/be631f5e-ad06-4f40-be81-b339be9bb917)




## TX Details
Input a tx:

![Screenshot_2024-12-07_12-19-13](https://github.com/user-attachments/assets/a5f32a28-b704-4610-b998-26f264dbdc8e)



## Zebra Peers
`./zebraPeers.sh`

![Screenshot_2024-08-31_18-58-02](https://github.com/user-attachments/assets/517e0515-f137-4505-9482-d47e61e6a4ec)

## Block Found Summary

![Screenshot_2024-10-01_23-46-50](https://github.com/user-attachments/assets/a8b96a1a-2448-48e6-aff5-02bb602970ad)


## ListTXs

![Screenshot_2024-09-16_15-19-12](https://github.com/user-attachments/assets/b488d501-c6da-4bd9-ab25-63d2789e2aaa)

## GetDateFromTX

![Screenshot_2024-10-03_11-28-25](https://github.com/user-attachments/assets/bce305b0-a374-424c-8e31-45c0298f5095)

## Example1

`./listTXs.sh 2742068 2743220 | xargs -n1 ./txDetailsZebra.sh | jq .difficulty | tee -a myDifficulty.md`

![Screenshot_2024-12-07_19-32-56](https://github.com/user-attachments/assets/d76e5a20-5687-4c8f-a326-8983b021d712)


![myDiff](https://github.com/user-attachments/assets/f0552524-9020-4750-949e-ace9e81f934a)

## Example2

`./toCurl.sh getblockchaininfo | jq .upgrades | jq 'to_entries[]' | jq .value.activationheight | xargs -n1 ./getDateFromBlock.sh`


![Screenshot_2025-02-13_05-45-08](https://github.com/user-attachments/assets/6739094b-c46b-46a1-aa7e-23d47641ddab)




