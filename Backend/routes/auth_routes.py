from fastapi import APIRouter, HTTPException, status
from google.oauth2 import id_token
from google.auth.transport.requests import Request as GoogleAuthRequest
import os
import uuid
import jwt
from pydantic import BaseModel
from datetime import datetime, timedelta, timezone
from core.data import guest_users

router = APIRouter()

GOOGLE_CLIENT_ID = os.getenv("GOOGLE_CLIENT_ID")
JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY")

class Token(BaseModel):
    id_token: str

class GuestLoginResponse(BaseModel):
    guest_token: str
    message: str

@router.post("/google")
async def auth_google(token: Token):
    try:
        id_info = id_token.verify_oauth2_token(
            token.id_token,
            GoogleAuthRequest(),
            GOOGLE_CLIENT_ID
        )

        user_email = id_info.get("email")
        if not user_email:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="No email found in token.")

        user_name = id_info.get("name")

        guest_users[user_email] = {
            "name" : user_name,
            "login_type" : "google",
            "last_login" : datetime.now(timezone.utc)
        }

        return {
            "message": "구글 로그인 성공!",
            "user_email": user_email,
            "user_name": user_name
        }
    
    except ValueError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token.")
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))
    
@router.post("/guest", response_model=GuestLoginResponse)
async def guest_login():
    guest_id = str(uuid.uuid4())
    
    payload = {
        "sub": guest_id, 
        "exp": datetime.now(timezone.utc) + timedelta(days=1), #토큰 만료 시간(1알)
        "iat": datetime.now(timezone.utc), #토큰 발행 시간
        "is_guest": True
    }

    guest_token = jwt.encode(payload, JWT_SECRET_KEY, algorithm="HS256")

    guest_users[guest_id] = {
        "guest_token": guest_token,
        "created_at": datetime.now(timezone.utc),
        "login_type" : "guest"
    }
    
    return {
        "guest_token": guest_token,
        "message": "게스트 로그인 성공!"
    }