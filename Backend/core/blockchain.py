# core/blockchain.py
from web3 import Web3
import os
from web3.middleware.proof_of_authority import ExtraDataToPOAMiddleware
from dotenv import load_dotenv
import base58
from fastapi import HTTPException

load_dotenv()

# 환경변수
ZETA_CHAIN_RPC_URL = os.getenv("ZETA_CHAIN_RPC_URL")
CROSS_CHAIN_SWAP_CONTRACT_ADDRESS = os.getenv("CROSS_CHAIN_SWAP_CONTRACT_ADDRESS")
REWARD_TOKEN_CONTRACT_ADDRESS = os.getenv("REWARD_TOKEN_CONTRACT_ADDRESS")
VOTING_CONTRACT_ADDRESS = os.getenv("VOTING_CONTRACT_ADDRESS")

w3 = Web3(Web3.HTTPProvider(ZETA_CHAIN_RPC_URL, request_kwargs={'timeout': 10}))
w3.middleware_onion.inject(ExtraDataToPOAMiddleware, layer=0)

if not w3.is_connected():
    raise RuntimeError("Cannot connect to ZetaChain RPC")

# ABI
SWAP_ABI = [
    {
        "constant": False,
        "inputs": [
            {"internalType": "uint256", "name": "amount", "type": "uint256"},
            {"internalType": "bytes", "name": "destinationAddress", "type": "bytes"}
        ],
        "name": "swap",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    }
]

REWARD_ABI = [
    {
        "constant": True,
        "inputs": [{"internalType": "address", "name": "owner", "type": "address"}],
        "name": "balanceOf",
        "outputs": [{"internalType": "uint256", "name": "", "type": "uint256"}],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "constant": True,
        "inputs": [],
        "name": "decimals",
        "outputs": [{"internalType": "uint8", "name": "", "type": "uint8"}],
        "stateMutability": "view",
        "type": "function"
    }
]

VOTING_ABI = [
    {
        "constant": True,
        "inputs": [],
        "name": "getCandidates",
        "outputs": [{"name": "", "type": "string[]"}],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "constant": True,
        "inputs": [{"name": "candidate", "type": "string"}],
        "name": "getVotes",
        "outputs": [{"name": "", "type": "uint256"}],
        "stateMutability": "view",
        "type": "function"
    }
]

# 보상 토큰 잔액 조회
def get_reward_token_balance(user_address: str):
    reward_contract = w3.eth.contract(address=REWARD_TOKEN_CONTRACT_ADDRESS, abi=REWARD_ABI)
    try:
        balance = reward_contract.functions.balanceOf(user_address).call()
        return balance
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Balance fetch failed: {str(e)}")

# 환전 트랜잭션 전송 (blocking 함수)
def submit_swap_transaction(user_address: str, private_key: str, amount: float, destination_address: str):
    if not w3.is_connected():
        return {"success": False, "error": "Failed to connect to ZetaChain"}

    swap_contract = w3.eth.contract(address=CROSS_CHAIN_SWAP_CONTRACT_ADDRESS, abi=SWAP_ABI)
    
    try:
        if not w3.is_address(destination_address):
            return {"success": False, "error": "Invalid destination address"}

        # destination address 변환
        destination_bytes = bytes.fromhex(destination_address[2:])  # "0x" 제거 후 bytes
        decimals = 18  # 혹은 reward_token_contract.functions.decimals().call()
        amount_wei = int(amount * (10 ** decimals))

        txn = swap_contract.functions.swap(amount_wei, destination_bytes).build_transaction({
            'from': user_address,
            'nonce': w3.eth.get_transaction_count(user_address),
            'gas': swap_contract.functions.swap(amount_wei, destination_bytes).estimate_gas({'from': user_address}),
            'gasPrice': w3.eth.gas_price
        })

        signed_txn = w3.eth.account.sign_transaction(txn, private_key)
        tx_hash = w3.eth.send_raw_transaction(signed_txn.rawTransaction)
        return {"success": True, "tx_hash": tx_hash.hex()}

    except Exception as e:
        return {"success": False, "error": str(e)}


# 투표 결과 조회
def get_voting_results():
    try:
        voting_contract = w3.eth.contract(address=VOTING_CONTRACT_ADDRESS, abi=VOTING_ABI)
        candidates = voting_contract.functions.getCandidates().call()
        results = {}
        for candidate in candidates:
            votes = voting_contract.functions.getVotes(candidate).call()
            results[candidate] = votes
        return results
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Voting fetch failed: {str(e)}")
