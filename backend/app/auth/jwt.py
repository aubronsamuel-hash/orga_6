import time
import jwt
from typing import Dict, Any

ALGO = "HS256"


class JWTError(Exception):
    pass


def create_access_token(claims: Dict[str, Any], secret: str, expire_minutes: int) -> str:
    now = int(time.time())
    exp = now + (expire_minutes * 60)
    payload = {**claims, "iat": now, "exp": exp}
    token = jwt.encode(payload, secret, algorithm=ALGO)
    return token


def decode_access_token(token: str, secret: str) -> Dict[str, Any]:
    try:
        payload = jwt.decode(token, secret, algorithms=[ALGO])
        return payload
    except jwt.PyJWTError as e:
        raise JWTError(str(e))
