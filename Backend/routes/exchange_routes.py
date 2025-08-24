# routes/exchange_routes.py
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
import os
import asyncio
from core.blockchain import get_reward_token_balance, submit_swap_transaction

router = APIRouter()

USER_ADDRESS = os.getenv("USER_ADDRESS")
PRIVATE_KEY = os.getenv("USER_PRIVATE_KEY")

class SwapRequest(BaseModel):
    amount: float
    destination_address: str
    private_key : str

class SwapResponse(BaseModel):
    tx_hash: str
    message: str

# 잔액 조회
@router.get("/balance/{address}")
async def get_balance_endpoint(address: str):
    balance = get_reward_token_balance(address)
    return {"balance": balance}

# 환전
@router.post("/swap/{symbol}")
async def perform_swap(symbol: str, request: SwapRequest):
    print("Received symbol:", symbol)
    print("Received request dict:", request.dict())
    try:
        amount = request.amount 
    except ValueError:
        return {"success": False, "error": "Amount must be a number."}
    
    if not USER_ADDRESS or not PRIVATE_KEY:
        return {"success": False, "error": "User wallet info not configured."}

    tx_result = submit_swap_transaction(
        amount=request.amount,
        destination_address=request.destination_address,
        private_key=PRIVATE_KEY,
    )
    
    if not tx_result.get("success", False):
        # 실패 시에도 JSON으로 반환
        return {
            "success": False,
            "error": tx_result.get("error", "Unknown error")
        }
        
    return {
        "success": True,
        "tx_hash": tx_result["tx_hash"],
        "message": f"{symbol} 환전 요청이 블록체인에 전송되었습니다."
    }

