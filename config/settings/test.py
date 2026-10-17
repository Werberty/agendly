from .base import *  # noqa: F403


PASSWORD_HASHERS = ["django.contrib.auth.hashers.MD5PasswordHasher"]  # só em teste

EMAIL_BACKEND = "django.core.mail.backends.locmem.EmailBackend"

CELERY_TASK_ALWAYS_EAGER = True

CACHES = {
    "default": {
        "BACKEND": "django.core.cache.backends.locmem.LocMemCache"
    }
}
