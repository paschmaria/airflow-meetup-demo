import os
from datetime import timedelta
from pathlib import (
    Path,
)

from airflow.decorators import (
    dag,
)
from cosmos import (
    DbtTaskGroup,
    ProfileConfig,
    ProjectConfig,
    RenderConfig,
)

ENV = "dev"
STAGE_SCHEMA = "staging"
PROD_SCHEMA = "analytics"
DEFAULT_ARGS = {
    "owner": "airflow",
    "start_date": "2025-02-28",
    "retries": 2,
    "retry_delay": timedelta(minutes=3),
}
DBT_PATH = Path(os.getcwd()) / "dbt" / "jaffle_shop"


@dag(
    dag_id=f"{ENV}-dbt-models-v1.0",
    description="run dbt jobs",
    default_args=DEFAULT_ARGS,
    schedule="*/30 * * * *",
    catchup=False,
    max_active_runs=1,
    tags=[
        "dbt",
    ],
)
def load_dbt_models():
    run_customer_models = DbtTaskGroup(
        group_id="run_customer_models",
        project_config=ProjectConfig(
            dbt_project_path=DBT_PATH,
            env_vars={
                "STAGE_SCHEMA": STAGE_SCHEMA,
                "PROD_SCHEMA": PROD_SCHEMA,
            },
        ),
        profile_config=ProfileConfig(
            profile_name="jaffle_shop",
            target_name=ENV,
            profiles_yml_filepath=DBT_PATH / "profiles.yml",
        ),
        render_config=RenderConfig(
            select=["+dim_customers"],
        ),
    )

    run_store_models = DbtTaskGroup(
        group_id="run_store_models",
        project_config=ProjectConfig(
            dbt_project_path=DBT_PATH,
            env_vars={
                "STAGE_SCHEMA": STAGE_SCHEMA,
                "PROD_SCHEMA": PROD_SCHEMA,
            },
        ),
        profile_config=ProfileConfig(
            profile_name="jaffle_shop",
            target_name=ENV,
            profiles_yml_filepath=DBT_PATH / "profiles.yml",
        ),
        render_config=RenderConfig(
            select=["+dim_stores"],
        ),
    )

    run_order_models = DbtTaskGroup(
        group_id="run_order_models",
        project_config=ProjectConfig(
            dbt_project_path=DBT_PATH,
            env_vars={
                "STAGE_SCHEMA": STAGE_SCHEMA,
                "PROD_SCHEMA": PROD_SCHEMA,
            },
        ),
        profile_config=ProfileConfig(
            profile_name="jaffle_shop",
            target_name=ENV,
            profiles_yml_filepath=DBT_PATH / "profiles.yml",
        ),
        render_config=RenderConfig(
            select=["fct_orders"],
        ),
    )

    run_customer_models >> run_store_models >> run_order_models


dag_obj = load_dbt_models()
