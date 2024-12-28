import asyncio
import json
import uuid
from json import JSONDecodeError

import websockets
from websockets import serve

# Dictionaries to manage client connections
clients = dict()  # Clients of type A
game_servers = set()  # Clients of type B


async def handler(websocket):
    print("New connection received")
    print(f"> {websocket}")


    # Assume the client is of type A initially
    clients[websocket] = None

    try:
        async for message in websocket:
            print(f"Got message: {message}")
            # Check if client announces itself as type B
            if message == "TYPE_B":
                print("Server connected")
                # Move client to B list
                del clients[websocket]
                game_servers.add(websocket)
                await websocket.send(
                    json.dumps({"type": "notice", "value": "You are the gameserver"})
                )
            else:
                try:
                    obj = json.loads(message)
                    if "type" not in obj:
                        # Invalid message. Every message should have a type
                        continue

                    if obj["type"] == "registration":
                        # client_id = obj["value"]
                        del obj["value"]
                        client_id = str(uuid.uuid4())
                        await websocket.send(
                            json.dumps({"type": "registration_ack", "value": client_id})
                        )

                        if client_id in clients.values():
                            print(
                                "Received registration for already registered id. Ignoring..."
                            )
                            continue

                        clients[websocket] = client_id

                    # Broadcast messages from clients to the game servers
                    if websocket in clients:

                        if clients[websocket] is None:
                            print(
                                "Got a client action before registration. Ignoring..."
                            )
                            continue

                        obj["client_id"] = clients[websocket]
                        new_msg = json.dumps(obj)
                        print("Sending msg to gameserver: " + new_msg)
                        await asyncio.gather(
                            *[game_server.send(new_msg) for game_server in game_servers]
                        )
                    if websocket in game_servers:
                        pass
                        # TODO Francis: game_servers can send targetted messages

                except JSONDecodeError as e:
                    # Invalid json message
                    pass

    except Exception as e:
        print(f"Error: {e}")
    finally:
        # Remove websocket from both sets when connection closes
        if websocket in clients:
            del clients[websocket]
        # del clients[websocket]
        game_servers.discard(websocket)


async def main():
    async with serve(handler, "0.0.0.0", 7000) as server:
        print("WebSocket server started on ws://0.0.0.0:7000")
        await server.wait_closed()


if __name__ == "__main__":
    asyncio.run(main())
