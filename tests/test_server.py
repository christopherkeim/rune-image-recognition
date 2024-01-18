from fastapi.testclient import TestClient
from httpx import Response

from api.server import app


client = TestClient(app)


def test_predict() -> None:
    URL: str = "http://0.0.0.0:8000/api/predict"
    QUERY_PARAM: str = "?model_name=random_model"
    HEADERS: dict[str, str] = {
        "Content-Type": "application/json",
    }
    DATA: dict[str, str] = {
        "x": "4.0",
        "y": "2.0",
    }

    response: Response = client.post(
        url=URL + QUERY_PARAM,
        json=DATA,
        headers=HEADERS,
    )

    assert response.status_code == 200
    assert response.json() == {
        "model": "random_model",
        "prediction": 8.0,
    }


def test_predict_bad_data() -> None:
    URL: str = "http://0.0.0.0:8000/api/predict"
    QUERY_PARAM: str = "?model_name=random_model"
    HEADERS: dict[str, str] = {
        "Content-Type": "application/json",
    }
    DATA: dict[str, str] = {
        "x": "4.0",
        "y": "hello",
    }

    response: Response = client.post(
        url=URL + QUERY_PARAM,
        json=DATA,
        headers=HEADERS,
    )

    assert response.status_code == 422
