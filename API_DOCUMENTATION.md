# API Documentation

This document provides detailed information about the Evolution API endpoints, parameters, and response formats.

## Authentication

All API requests require an API key to be included in the request header:

```
apikey: your_api_key_here
```

The default API key is `c4b46XpQs2Lw7tF9hM5jN8aD3` but can be changed in the environment configuration.

## Base URL

```
http://localhost:2559
```

## Instance Management

### Check API Status

```
GET /
```

**Response:**
```json
{
  "status": 200,
  "message": "Welcome to Evolution API",
  "version": "2.2.3"
}
```

### List All Instances

```
GET /instance/fetchInstances
```

**Response:**
```json
{
  "instances": [
    {
      "instance": "instance-name",
      "status": "connected",
      "owner": "owner-name",
      "numbers": ["123456789"]
    }
  ]
}
```

### Create a New Instance

```
POST /instance/create
```

**Request Body:**
```json
{
  "instanceName": "my-instance"
}
```

**Response:**
```json
{
  "status": "created",
  "instance": {
    "instanceName": "my-instance",
    "status": "created"
  }
}
```

### Connect an Instance

```
POST /instance/connect/my-instance
```

**Response:**
```json
{
  "status": "connecting",
  "qrcode": "data:image/png;base64,..."
}
```

### Get QR Code

```
GET /instance/qrcode/my-instance
```

**Response:**
```json
{
  "status": "success",
  "qrcode": "data:image/png;base64,..."
}
```

### Logout Instance

```
POST /instance/logout/my-instance
```

**Response:**
```json
{
  "status": "success",
  "message": "Logged out successfully"
}
```

### Delete Instance

```
DELETE /instance/delete/my-instance
```

**Response:**
```json
{
  "status": "success",
  "message": "Instance deleted successfully"
}
```

## Messaging

### Send Text Message

```
POST /message/sendText/my-instance
```

**Request Body:**
```json
{
  "number": "123456789",
  "textMessage": {
    "text": "Hello, this is a test message"
  }
}
```

**Response:**
```json
{
  "status": "success",
  "message": {
    "id": "message-id",
    "from": "sender",
    "to": "recipient",
    "content": "Hello, this is a test message",
    "timestamp": 1621345678
  }
}
```

### Send Media Message

```
POST /message/sendMedia/my-instance
```

**Request Body:**
```json
{
  "number": "123456789",
  "mediaMessage": {
    "mediatype": "image",
    "media": "https://example.com/image.jpg",
    "caption": "Image caption"
  }
}
```

Supported mediatypes: `image`, `video`, `audio`, `document`

**Response:**
```json
{
  "status": "success",
  "message": {
    "id": "message-id",
    "from": "sender",
    "to": "recipient",
    "mediaUrl": "https://example.com/image.jpg",
    "caption": "Image caption",
    "timestamp": 1621345678
  }
}
```

### Send Button Message

```
POST /message/sendButton/my-instance
```

**Request Body:**
```json
{
  "number": "123456789",
  "buttonMessage": {
    "title": "Button Title",
    "description": "Button Description",
    "footerText": "Footer text",
    "buttons": [
      {
        "buttonId": "btn1",
        "buttonText": "Button 1"
      },
      {
        "buttonId": "btn2",
        "buttonText": "Button 2"
      }
    ]
  }
}
```

**Response:**
```json
{
  "status": "success",
  "message": {
    "id": "message-id",
    "from": "sender",
    "to": "recipient",
    "timestamp": 1621345678
  }
}
```

## Group Management

### Create Group

```
POST /group/create/my-instance
```

**Request Body:**
```json
{
  "groupName": "My Group",
  "participants": ["123456789", "987654321"]
}
```

**Response:**
```json
{
  "status": "success",
  "group": {
    "id": "group-id@g.us",
    "name": "My Group",
    "participants": ["123456789", "987654321"]
  }
}
```

### Add Participant

```
POST /group/addParticipant/my-instance
```

**Request Body:**
```json
{
  "groupId": "group-id@g.us",
  "participants": ["123456789"]
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Participant added successfully"
}
```

### Remove Participant

```
POST /group/removeParticipant/my-instance
```

**Request Body:**
```json
{
  "groupId": "group-id@g.us",
  "participants": ["123456789"]
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Participant removed successfully"
}
```

## Contacts

### Get All Contacts

```
GET /contact/getAll/my-instance
```

**Response:**
```json
{
  "status": "success",
  "contacts": [
    {
      "id": "contact-id",
      "name": "Contact Name",
      "number": "123456789",
      "avatar": "data:image/png;base64,..."
    }
  ]
}
```

### Get Contact Information

```
GET /contact/get/my-instance?number=123456789
```

**Response:**
```json
{
  "status": "success",
  "contact": {
    "id": "contact-id",
    "name": "Contact Name",
    "number": "123456789",
    "avatar": "data:image/png;base64,..."
  }
}
```

## Webhooks

### Set Webhook for All Events

```
POST /webhook/set/my-instance
```

**Request Body:**
```json
{
  "url": "https://your-webhook-url.com/webhook",
  "events": ["all"]
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Webhook set successfully"
}
```

### Set Webhook for Specific Events

```
POST /webhook/set/my-instance
```

**Request Body:**
```json
{
  "url": "https://your-webhook-url.com/webhook",
  "events": ["message", "connection", "status"]
}
```

Available events: `message`, `connection`, `status`, `group`, `presence`

**Response:**
```json
{
  "status": "success",
  "message": "Webhook set successfully"
}
```

## Error Responses

When an error occurs, the API will return a JSON response with details about the error:

```json
{
  "error": true,
  "message": "Error description"
}
```

Common error messages include:

- "Unauthorized" - Invalid or missing API key
- "Instance not found" - The specified instance does not exist
- "Not connected" - The instance is not connected to WhatsApp
- "Invalid number" - The provided phone number is invalid
- "Group not found" - The specified group does not exist

## Rate Limiting

The API has rate limiting to prevent abuse. If you exceed the rate limits, you'll receive a 429 status code with the following response:

```json
{
  "error": true,
  "message": "Too many requests, please try again later"
}
```

## WebSocket

For real-time communication, connect to the WebSocket endpoint:

```
ws://localhost:2559
```

Events are sent in JSON format:

```json
{
  "event": "message",
  "instance": "my-instance",
  "data": {
    // Event-specific data
  }
}
```

## Further Documentation

For more detailed information, please refer to the [Evolution API GitHub repository](https://github.com/evolution-api/evolution-api).
