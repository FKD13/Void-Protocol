import asyncio
import websockets
import json

from random import random, seed, choice

seed(1234)

actions = [
    {"type": "gun_turn_right", "value": lambda: random()},
    {"type": "gun_turn_left", "value": lambda: random()},
    {"type": "gun_shoot", "value": lambda: ""},
    {"type": "turn_right", "value": lambda: random()},
    {"type": "turn_left", "value": lambda: random()},
    {"type": "thrust_forward", "value": lambda: random()},
]
import time


async def consumer(message):
    print(f"Received: {message}")


async def producer():
    await asyncio.sleep(1)
    action = choice(actions)

    return json.dumps({"type": action["type"], "value": action["value"]()})


async def consumer_handler(websocket):
    async for message in websocket:
        print("Got message: " + str(message))
        await consumer(message)


async def producer_handler(websocket):
    while True:
        message = await producer()
        print("Sending message: " + message)
        await websocket.send(message)


async def handler(websocket):
    consumer_task = asyncio.create_task(consumer_handler(websocket))
    producer_task = asyncio.create_task(producer_handler(websocket))
    done, pending = await asyncio.wait(
        [consumer_task, producer_task],
        return_when=asyncio.FIRST_COMPLETED,
    )
    for task in pending:
        task.cancel()


async def websocket_client():
    uri = "ws://localhost:7000"

    try:
        # Connect to the WebSocket server
        async with websockets.connect(uri) as websocket:
            # Create registration packet with random UUID
            registration_packet = {"type": "registration", "value": ""}

            # Send registration packet
            await websocket.send(json.dumps(registration_packet))
            print(f"Sent: {registration_packet}")

            await handler(websocket)

    except Exception as e:
        print(f"Error: {e}")


asyncio.run(websocket_client())
