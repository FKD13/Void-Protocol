import asyncio
import websockets

from websockets import serve

# Dictionaries to manage client connections
clients = set()  # Clients of type A
game_servers = set()  # Clients of type B

async def handler(websocket):
    # Assume the client is of type A initially
    a_clients.add(websocket)
    try:
        async for message in websocket:
            print(f"Got message: {message}")
            # Check if client announces itself as type B
            if message == "TYPE_B":
                print("Server connected")
                # Move client to B list
                clients.remove(websocket)
                game_servers.add(websocket)
                await websocket.send("You are now type B")
            else:
                # Broadcast messages from type A clients to type B clients
                if websocket in clients:  # Ensure sender is of type A
                    await asyncio.gather(
                        *[b.send(message) for game_server in game_servers]
                    )
                if websocket in game_servers:
                    pass
                    # TODO Francis: game_servers can send targetted messages
    except Exception as e:
        print(f"Error: {e}")
    finally:
        # Remove websocket from both sets when connection closes
        clients.discard(websocket)
        game_servers.discard(websocket)

async def main():
    async with serve(handler, "127.0.0.1", 7000) as server:
        print("WebSocket server started on ws://localhost:7000")
        await server.wait_closed()

if __name__ == "__main__":
    asyncio.run(main())
