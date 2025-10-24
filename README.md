# ZebraUtilities
Helper scripts for using zebra. Will need a running and synced zebra node installed. See here for more info:

https://zechub.wiki/zebra

## Prerequisites

***Make sure you are running the latest zebrad for the most up-to-date RPC's!***

`chmod + x` all .sh files and use as needed.

Can access Zebra RPC's using `toCurl.sh`or equivalent.
```
* blockFoundSummaryZebra.sh                  // Display blocks and tx's as they are mined
* extractSupplyInfoZebra.sh                  // Extract ZEC supply information
* getBlockCount.sh                           // Get current amount of mined blocks (Height)
* getDateFromBlock.sh                        // Get the date/time a given block was mined
* getDateFromTX.sh                           // Get the date/time a given transaction was mined
* getTXfeeII.sh                              // Get the transaction fee of a given txid (updated)
* getType.sh                                 // Get the type of transaction given a txid (old)
* tx_type.sh                                 // Get tye type of transaction given a txid (new)
* listBestBlockTXs.sh                        // List the transactions of the top block
* listBlockTXs.sh                            // List the transactions of a given block
* listTXs.sh                                 // List all Tx's in any block interval
* txDetails.sh                               // Display detailed info about any txid
* visualizeMempool.sh                        // View amount/types of txid's in the mempool
* zebraPeers.sh                              // Display connected peers to your node
* viewTurnstileBlock.sh                      // View turnstile data given a block
* viewTurnstileTaddr.sh                      // View turnstile data given a T address
* viewTurnstileTXID.sh                       // View turnstile data given a txid
```

## DEV version

For the latest updates, check out the dev folder. *They are changed often*

## Extract Supply Info
![Screenshot_2024-12-07_12-19-54](https://github.com/user-attachments/assets/be631f5e-ad06-4f40-be81-b339be9bb917)


## TX Details
Input a tx:


![Screenshot_2025-04-21_17-03-30](https://github.com/user-attachments/assets/8f036760-0022-4a0b-aba0-bdb347ded14d)


## Zebra Peers
`./zebraPeers.sh`

![Screenshot_2024-08-31_18-58-02](https://github.com/user-attachments/assets/517e0515-f137-4505-9482-d47e61e6a4ec)

## Visualize Mempool
You need the following scripts in a folder:
```
toCurl.sh
getType.sh
txDetails.sh
getTXfee.sh
inMempool.sh
visualizeMempool.sh
```

Then run `./visualizeMempool.sh`


![Screenshot_2025-04-21_10-37-54](https://github.com/user-attachments/assets/ca33eb99-ba86-4c63-b7c2-458eee230a61)


## Block Found Summary

You need the following scripts in a folder:
```
toCurl.sh
listBlockTXs.sh
txDetails.sh
tx_type.sh
getTXfeeII.sh
drawBlock.sh
blockFoundSummary.sh
```
Then run `./blockFoundSummary.sh`

<img width="2742" height="598" alt="Screenshot_2025-10-23_21-22-45" src="https://github.com/user-attachments/assets/8ea77d14-dbba-4994-a102-47f72f3374a3" />




## ListTXs with tx_type / getType

![Screenshot_2025-04-21_16-59-38](https://github.com/user-attachments/assets/370e1585-f9ce-4288-9275-f7cd1e46542d)


## GetDateFromTX

![Screenshot_2024-10-03_11-28-25](https://github.com/user-attachments/assets/bce305b0-a374-424c-8e31-45c0298f5095)

### Example1

`seq 2742068 2743220 | xargs -n1 ./toCurl.sh getblock | jq .difficulty | tee -a myDifficulty.md`

![Screenshot_2024-12-07_19-32-56](https://github.com/user-attachments/assets/d76e5a20-5687-4c8f-a326-8983b021d712)


![myDiff](https://github.com/user-attachments/assets/f0552524-9020-4750-949e-ace9e81f934a)

### Example2

`./toCurl.sh getblockchaininfo | jq .upgrades | jq 'to_entries[]' | jq .value.activationheight | xargs -n1 ./getDateFromBlock.sh`


![Screenshot_2025-02-13_05-45-08](https://github.com/user-attachments/assets/6739094b-c46b-46a1-aa7e-23d47641ddab)

## ViewTurnstileBlock

### Example 1
`./viewTurnstileBlock.sh 3078839`

<img width="330" height="482" alt="Screenshot_2025-09-26_15-26-55" src="https://github.com/user-attachments/assets/e1f16485-7cb8-4c2e-baba-5e9b50f1fd66" />

### Example 2

`./viewTurnstileBlock.sh 3078839 true`

<img width="1594" height="1078" alt="Screenshot_2025-09-26_15-27-12" src="https://github.com/user-attachments/assets/2b252868-3291-4fd7-bab6-f6a1e3b34632" />






