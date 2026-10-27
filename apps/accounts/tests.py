import pytest

from apps.accounts.models import User

pytestmark = pytest.mark.django_db


def test_create_user():
    user = User.objects.create_user(email="user@example.com", password="12345678")
    user_db = User.objects.filter(id=user.id)

    assert user_db.exists()
    assert user.is_active
    assert not user.is_staff
    assert not user.is_superuser


def test_create_superuser():
    user = User.objects.create_superuser(email="user@example.com", password="12345678")
    user_db = User.objects.filter(id=user.id)

    assert user_db.exists()
    assert user.is_active
    assert user.is_staff
    assert user.is_superuser


def test_create_user_with_null_email_is_invalid():
    with pytest.raises(ValueError):
        User.objects.create_user(email="", password="12345678")
