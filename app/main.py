from fastapi import FastAPI
from app.middleware.logging import request_logger

app = FastAPI()
app.middleware("http")(request_logger)

@app.get("/")
def read_root():
    return {"message": "Hello from EMC-Sriram!!"}

# For local testing without uvicorn runner
if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=False)