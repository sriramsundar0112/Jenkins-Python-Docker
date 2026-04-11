import json
import time
from fastapi import Request
from app.core.logger import get_logger

logger = get_logger()

async def request_logger(request: Request, call_next):
    start_time = time.time()

    response = await call_next(request)

    log_data = {
        "method": request.method,
        "path": request.url.path,
        "status_code": response.status_code,
        "client": request.client.host if request.client else None,
        "duration_ms": round((time.time() - start_time) * 1000, 2),
    }

    logger.info(json.dumps(log_data))
    return response