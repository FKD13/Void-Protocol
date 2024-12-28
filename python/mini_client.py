import asyncio
import websockets
import json
import uuid

async def websocket_client():
    uri = "ws://localhost:7000"

    try:
        # Connect to the WebSocket server
        async with websockets.connect(uri) as websocket:
            # Create registration packet with random UUID
            registration_packet = {
                "type": "registration",
                "value": str(uuid.uuid4())
            }
            
            # Send registration packet
            await websocket.send(json.dumps(registration_packet))
            print(f"Sent: {registration_packet}")

            # Keep listening for incoming messages
            while True:
                message = await websocket.recv()
                print(f"Received: {message}")

    except Exception as e:
        print(f"Error: {e}")

asyncio.run(websocket_client())
