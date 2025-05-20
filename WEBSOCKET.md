# WebSocket Implementation

This document describes how to use the WebSocket features of the Evolution API for real-time communication.

## Overview

The Evolution API provides WebSocket support for real-time updates and events. This allows your application to receive immediate notifications about messages, connection status changes, and other events without polling the API.

## Connection Details

### WebSocket URL

```
ws://localhost:2559
```

For production environments with SSL:

```
wss://yourdomain.com/
```

### Authentication

Authentication is performed using the API key in the connection request:

```javascript
const socket = new WebSocket('ws://localhost:2559?apikey=your_api_key_here');
```

## Event Types

The WebSocket connection provides real-time events for:

1. **Messages** - New messages, message updates, and deletions
2. **Connections** - Connection status changes
3. **Status** - Status updates from contacts
4. **Groups** - Group creation, updates, and participant changes
5. **Presence** - Online/offline status and typing indicators
6. **Calls** - Incoming and outgoing calls

## Event Format

Events are sent as JSON objects with the following structure:

```json
{
  "event": "message",
  "instance": "instance-name",
  "data": {
    // Event-specific data
  }
}
```

### Message Events

```json
{
  "event": "message",
  "instance": "my-instance",
  "data": {
    "id": "message-id",
    "from": "sender-id",
    "to": "recipient-id",
    "type": "text",
    "content": "Message content",
    "timestamp": 1621345678
  }
}
```

### Connection Events

```json
{
  "event": "connection",
  "instance": "my-instance",
  "data": {
    "state": "connected",
    "info": {
      "me": {
        "id": "user-id",
        "name": "User Name"
      }
    }
  }
}
```

Connection states: `connecting`, `connected`, `disconnected`, `qrcode`

### Status Events

```json
{
  "event": "status",
  "instance": "my-instance",
  "data": {
    "from": "user-id",
    "status": "Hello, I'm using WhatsApp!"
  }
}
```

### Group Events

```json
{
  "event": "group",
  "instance": "my-instance",
  "data": {
    "id": "group-id@g.us",
    "action": "create",
    "metadata": {
      "name": "Group Name",
      "participants": [
        "participant1-id",
        "participant2-id"
      ],
      "owner": "owner-id"
    }
  }
}
```

Group actions: `create`, `update`, `delete`, `participant_add`, `participant_remove`

### Presence Events

```json
{
  "event": "presence",
  "instance": "my-instance",
  "data": {
    "id": "user-id",
    "presence": "available",
    "lastSeen": 1621345678,
    "typing": true
  }
}
```

Presence states: `available`, `unavailable`, `composing` (typing)

### Call Events

```json
{
  "event": "call",
  "instance": "my-instance",
  "data": {
    "id": "call-id",
    "from": "caller-id",
    "status": "offer",
    "isVideo": true,
    "timestamp": 1621345678
  }
}
```

Call statuses: `offer`, `accept`, `reject`, `end`

## Example Implementations

### JavaScript

```javascript
const socket = new WebSocket('ws://localhost:2559?apikey=your_api_key_here');

socket.onopen = function(event) {
  console.log('Connected to WebSocket');
};

socket.onmessage = function(event) {
  const data = JSON.parse(event.data);
  
  switch(data.event) {
    case 'message':
      console.log('New message:', data.data.content);
      break;
    case 'connection':
      console.log('Connection state:', data.data.state);
      break;
    case 'status':
      console.log('Status update:', data.data.status);
      break;
    case 'group':
      console.log('Group action:', data.data.action);
      break;
    case 'presence':
      console.log('Presence update:', data.data.presence);
      break;
    case 'call':
      console.log('Call status:', data.data.status);
      break;
  }
};

socket.onerror = function(error) {
  console.error('WebSocket error:', error);
};

socket.onclose = function(event) {
  console.log('WebSocket connection closed:', event.code, event.reason);
};
```

### Python

```python
import websocket
import json
import _thread
import time

def on_message(ws, message):
    data = json.loads(message)
    event_type = data['event']
    instance = data['instance']
    event_data = data['data']
    
    print(f"Received {event_type} event from {instance}")
    
    if event_type == 'message':
        print(f"Message content: {event_data.get('content')}")

def on_error(ws, error):
    print(f"Error: {error}")

def on_close(ws, close_status_code, close_msg):
    print(f"Connection closed: {close_status_code} - {close_msg}")

def on_open(ws):
    print("Connection opened")

if __name__ == "__main__":
    websocket.enableTrace(True)
    ws = websocket.WebSocketApp("ws://localhost:2559?apikey=your_api_key_here",
                              on_open=on_open,
                              on_message=on_message,
                              on_error=on_error,
                              on_close=on_close)

    ws.run_forever()
```

## Connection Management

### Connection Status

The WebSocket will send a `connection` event when the connection status changes. This includes when a new QR code is generated, allowing you to update your UI accordingly.

### Reconnection Strategy

WebSocket connections may close due to network issues or server restarts. Implement a reconnection strategy:

```javascript
function connect() {
    const socket = new WebSocket('ws://localhost:2559?apikey=your_api_key_here');
    
    socket.onclose = function(event) {
        console.log('Socket closed, reconnecting in 5 seconds...');
        setTimeout(connect, 5000);
    };
    
    // Other event handlers
}

connect();
```

### Ping/Pong

The WebSocket server implements ping/pong to keep connections alive. Most WebSocket clients handle this automatically.

## Security Considerations

1. **Use SSL/TLS**: In production, always use WSS (WebSocket Secure) instead of WS
2. **API Key Security**: Protect your API key and consider using a proxy for WebSocket connections
3. **Validate Messages**: Always validate and sanitize received messages before processing

## Limitations

1. **Connection Limit**: There is a limit to the number of simultaneous WebSocket connections
2. **Message Size**: Large messages may be fragmented or rejected
3. **Reconnection**: You must implement your own reconnection logic
4. **Rate Limiting**: Excessive connection attempts may be rate-limited

## Troubleshooting

1. **Connection Refused**: Check that the API is running and the port is accessible
2. **Authentication Failed**: Verify that the API key is correct
3. **Unexpected Disconnections**: Implement logging to track connection lifecycle events
4. **High Latency**: Reduce the number of active connections or optimize server resources
