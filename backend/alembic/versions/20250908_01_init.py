"""initial schema: users, missions, assignments"""

from alembic import op
import sqlalchemy as sa

revision = "20250908_01_init"
down_revision = None
branch_labels = None
depends_on = None

def upgrade():
    op.create_table(
        "users",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("email", sa.String(length=255), nullable=False),
        sa.Column("full_name", sa.String(length=255), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
    )
    op.create_index("ix_users_id", "users", ["id"])
    op.create_index("ix_users_email", "users", ["email"], unique=True)

    op.create_table(
        "missions",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("title", sa.String(length=255), nullable=False),
        sa.Column("location", sa.String(length=255)),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
    )
    op.create_index("ix_missions_id", "missions", ["id"])
    op.create_index("ix_missions_title", "missions", ["title"])

    op.create_table(
        "assignments",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("user_id", sa.Integer(), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("mission_id", sa.Integer(), sa.ForeignKey("missions.id", ondelete="CASCADE"), nullable=False),
        sa.Column("role", sa.String(length=80), nullable=False),
        sa.Column("start_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("end_at", sa.DateTime(timezone=True), nullable=False),
    )
    op.create_index("ix_assignments_id", "assignments", ["id"])
    op.create_index("ix_assignments_user", "assignments", ["user_id"])
    op.create_index("ix_assignments_mission", "assignments", ["mission_id"])
    op.create_unique_constraint("uq_assignment_slot", "assignments", ["user_id", "mission_id", "start_at", "end_at"])


def downgrade():
    op.drop_constraint("uq_assignment_slot", "assignments", type_="unique")
    op.drop_index("ix_assignments_mission", table_name="assignments")
    op.drop_index("ix_assignments_user", table_name="assignments")
    op.drop_index("ix_assignments_id", table_name="assignments")
    op.drop_table("assignments")

    op.drop_index("ix_missions_title", table_name="missions")
    op.drop_index("ix_missions_id", table_name="missions")
    op.drop_table("missions")

    op.drop_index("ix_users_email", table_name="users")
    op.drop_index("ix_users_id", table_name="users")
    op.drop_table("users")
