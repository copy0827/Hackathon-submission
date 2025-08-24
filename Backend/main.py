from fastapi import FastAPI
from dotenv import load_dotenv
from fastapi.middleware.cors import CORSMiddleware
import os
from routes import auth_routes
from routes import vote_routes
from routes import exchange_routes

load_dotenv()

app = FastAPI()

origins = [
    "*", 
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"], 
    allow_headers=["*"],  
)

app.include_router(auth_routes.router, prefix="/auth", tags=["auth"])
app.include_router(vote_routes.router, prefix="/vote", tags=["vote"])
app.include_router(exchange_routes.router, prefix="/exchange", tags=["exchange"])

@app.get("/")
def read_root():
    return {"message": "투표 서비스 백엔드"}
