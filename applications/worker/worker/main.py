import asyncio
from concurrent.futures import ThreadPoolExecutor
from datetime import timedelta
import multiprocessing

from worker.config.config import TemporalConfig
from temporalio import activity, workflow
from temporalio.client import Client
from temporalio.worker import Worker, SharedStateManager

task_queue = "say-hello-task-queue"
workflow_name = "say-hello-workflow"
activity_name = "say-hello-activity"


@workflow.defn(name=workflow_name)
class SayHelloWorkflow:

    @workflow.run
    async def run(self) -> None:
        await workflow.execute_activity(
            say_hello_activity,
            "Blah",
            start_to_close_timeout=timedelta(minutes=3)
        )


@activity.defn(name=activity_name)
async def say_hello_activity(name: str) -> str:
    return f"Hello, {name}!"


async def run_worker():
    print('start worker')

    temporal_config = TemporalConfig()
    temporal_url = f"{temporal_config.get_server_host()}:{temporal_config.get_server_port()}"
    print(f"Connecting to {temporal_url} ...")

    client = await Client.connect(temporal_url)
    print('connected')

    worker = Worker(
        client,
        task_queue=task_queue,
        workflows=[SayHelloWorkflow],
        activities=[say_hello_activity],
        activity_executor=ThreadPoolExecutor(10),
        shared_state_manager=SharedStateManager.create_from_multiprocessing(multiprocessing.Manager()),
        max_concurrent_activities=5,
        max_concurrent_workflow_tasks=5
    )
    await worker.run()


def main() -> None:
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    try:
        loop.run_until_complete(run_worker())
    finally:
        loop.run_until_complete(loop.shutdown_asyncgens())
        loop.close()


if __name__ == "__main__":
    main()
