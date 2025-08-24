from fastapi import APIRouter
from core.blockchain import get_voting_results
router = APIRouter()

@router.get("/results")
async def get_results():
    try:
        results = get_voting_results()
        return {"results": results}
    except Exception as e:
        return {"error": str(e)}
