try:
    import bcrypt as _bcrypt
except Exception:
    _bcrypt = None


def _require_bcrypt():
    if _bcrypt is None:
        raise RuntimeError(
            "bcrypt non installe. Ajoutez 'bcrypt' a backend/requirements.txt et installez les dependances avant d'appeler hash/verify."
        )


def hash_password(password: str) -> str:
    _require_bcrypt()
    if not isinstance(password, str) or password == "":
        raise ValueError("password required")
    hashed = _bcrypt.hashpw(password.encode("utf-8"), _bcrypt.gensalt(rounds=12))
    return hashed.decode("utf-8")


def verify_password(password: str, password_hash: str) -> bool:
    _require_bcrypt()
    if not password_hash:
        return False
    try:
        return _bcrypt.checkpw(password.encode("utf-8"), password_hash.encode("utf-8"))
    except Exception:
        return False
