"""
initial empty schema
"""
from alembic import op
import sqlalchemy as sa

revision = "0001_init"
down_revision = None
branch_labels = None
depends_on = None

def upgrade() -> None:
    # Example placeholder table to validate migrations
    op.create_table(
        "app_meta",
        sa.Column("key", sa.String(length=64), primary_key=True),
        sa.Column("value", sa.String(length=256), nullable=False),
    )

def downgrade() -> None:
    op.drop_table("app_meta")
