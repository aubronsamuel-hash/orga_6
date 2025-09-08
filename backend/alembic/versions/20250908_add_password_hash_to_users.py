"""
Add password_hash to users

Revision ID: 20250908_add_pwdhash
Revises: 20250908_01_init
Create Date: 2025-09-08 14:00:00
"""
from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = "20250908_add_pwdhash"
down_revision = "20250908_01_init"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("users", sa.Column("password_hash", sa.String(length=255), nullable=False, server_default=""))
    # optional: drop server_default after backfilling
    op.alter_column("users", "password_hash", server_default=None)


def downgrade() -> None:
    op.drop_column("users", "password_hash")

