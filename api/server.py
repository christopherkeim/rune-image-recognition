"""
Server for inference.
"""

from pydantic import BaseModel
from fastapi import FastAPI
import uvicorn


class PredictionResult(BaseModel):
    """
    Pydantic model for endpoint response.
    """

    model: str
    prediction: float


class ValidatedBodyData(BaseModel):
    """
    Pydantic will validate your model properties exist as keys,
    validate their data types, and filter out data that doesn't
    match your model properties.
    """

    x: float
    y: float


app: FastAPI = FastAPI(title="python-ml-template")


@app.get("/")
async def home() -> str:
    return "Hello 🐍 🚀 ✨"


@app.post("/api/predict")
async def predict(
    request: ValidatedBodyData,
    model_name: str = "cnn",
) -> PredictionResult:
    # FastAPI will handle converting this to JSON via Pydantic
    return PredictionResult(
        model=model_name,
        prediction=request.y * request.x,
    )


if __name__ == "__main__":
    uvicorn.run(
        "api.server:app",
        workers=1,
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info",
    )
