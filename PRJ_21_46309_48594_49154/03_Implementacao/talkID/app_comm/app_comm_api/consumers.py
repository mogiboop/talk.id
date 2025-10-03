import json
from channels.generic.websocket import AsyncWebsocketConsumer

class UpdateConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        await self.channel_layer.group_add("updates", self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        await self.channel_layer.group_discard("updates", self.channel_name)

    async def receive(self, text_data):
        pass 

    async def send_update(self, event):
        # Handles 'send_update' events
        await self.send(text_data=json.dumps({
            "type": event["type"],
            "id": event["id"],
            "first_name": event["first_name"],
            "last_name": event["last_name"],
            "msg_type_id": event["msg_type_id"],
            "msg_type_name": event["msg_type_name"],
            "msg_info": event["msg_info"],
            "msg_date_time": event["msg_date_time"],
            "level": event["level"],
        }))
        
    async def message_viewed(self, event):
        # Handles 'message_viewed' events
        await self.send(text_data=json.dumps({
            "type": event["type"],
            "id": event["id"],
        }))

    async def message_state(self, event):
        # Handles 'message_viewed' events
        await self.send(text_data=json.dumps({
            "type": event["type"],
            "id": event["id"],
        }))