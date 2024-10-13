print('main load')
import asyncio
import random
import string

from worker.config.config import BaseConfig, TemporalConfig
from temporalio import activity
from temporalio.client import Client
from temporalio.worker import Worker

task_queue = "say-hello-task-queue"
workflow_name = "say-hello-workflow"
activity_name = "say-hello-activity"


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

    # Run activity worker
    # async with Worker(client, task_queue=task_queue, activities=[say_hello_activity]):
    #     # Run the Go workflow
    #     workflow_id = "".join(
    #         random.choices(string.ascii_uppercase + string.digits, k=30)
    #     )
    #     result = await client.execute_workflow(
    #         workflow_name, "Temporal", id=workflow_id, task_queue=task_queue
    #     )
    #     # Print out "Hello, Temporal!"
    #     print(result)


def main() -> None:
    print('Start main loop')
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    try:
        loop.run_until_complete(run_worker())
    finally:
        loop.run_until_complete(loop.shutdown_asyncgens())
        loop.close()


if __name__ == "__main__":
    print('entry')
    main()
