//
//  Globals.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 7/19/17.
//  Copyright © 2017 Dimitar Grudev. All rights reserved.
//

import Foundation

struct Globals {
    
    struct InfuraAPI {
        
        static let Token = "htzJFzsvEl5dp4xdfjCy"
        static let IPFSGateway = "https://ipfs.infura.io"
        static let IPFS_RPC = "https://ipfs.infura.io:5001"
        
        struct Methods {
            
            struct Web3 {
                static let ClientVersion = "web3_clientVersion"
            }
            
            struct Net {
                static let Version = "net_version"
                static let Listening = "net_listening"
                static let PeerCount = "net_peerCount"
            }
            
            struct Eth {
                static let ProtocolVersion = "eth_protocolVersion"
                static let Syncing = "eth_syncing"
                static let Mining = "eth_mining"
                static let Hashrate = "eth_hashrate"
                static let GasPrice = "eth_gasPrice"
                static let Accounts = "eth_accounts"
                static let BlockNumber = "eth_blockNumber"
                static let GetBalance = "eth_getBalance"
                static let GetStorageAt = "eth_getStorageAt"
                static let GetTransactionCount = "eth_getTransactionCount"
                static let GetBlockTransactionCountByHash = "eth_getBlockTransactionCountByHash"
                static let GetBlockTransactionCountByNumber = "eth_getBlockTransactionCountByNumber"
                static let GetUncleCountByBlockHash = "eth_getUncleCountByBlockHash"
                static let GetUncleCountByBlockNumber = "eth_getUncleCountByBlockNumber"
                static let GetCode = "eth_getCode"
                static let Call = "eth_call"
                static let GetBlockByHash = "eth_getBlockByHash"
                static let GetBlockByNumber = "eth_getBlockByNumber"
                static let GetTransactionByHash = "eth_getTransactionByHash"
                static let GetTransactionByBlockHashAndIndex = "eth_getTransactionByBlockHashAndIndex"
                static let GetTransactionByBlockNumberAndIndex = "eth_getTransactionByBlockNumberAndIndex"
                static let GetTransactionReceipt = "eth_getTransactionReceipt"
                static let GetUncleByBlockHashAndIndex = "eth_getUncleByBlockHashAndIndex"
                static let GetUncleByBlockNumberAndIndex = "eth_getUncleByBlockNumberAndIndex"
                static let GetCompilers = "eth_getCompilers"
                static let GetLogs = "eth_getLogs"
                static let GetWork = "eth_getWork"
            }
            
        }
        
        struct Network {
            static let MainNet = "https://mainnet.infura.io/" + Globals.InfuraAPI.Token
            static let Ropsten = "https://ropsten.infura.io/" + Globals.InfuraAPI.Token
            static let Kovan = "https://kovan.infura.io/" + Globals.InfuraAPI.Token
            static let Rinkeby = "https://rinkeby.infura.io/" + Globals.InfuraAPI.Token
            static let InfuraNet = "https://infuranet.infura.io/" + Globals.InfuraAPI.Token
        }
        
        struct Symbol {
            static let ETH_BTC = "ethbtc"
            static let ETH_USD = "ethusd"
            static let ETH_EUR = "etheur"
            static let ETH_LTC = "ethltc"
            static let ETH_RUR = "ethrur"
        }
        
    }
    
}
