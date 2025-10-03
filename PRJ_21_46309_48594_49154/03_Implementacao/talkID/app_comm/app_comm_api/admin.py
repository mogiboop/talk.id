from django.contrib import admin
from app_comm_api.models import Message, MessageType, MessageState, MessageCoord, MessageSolution, PushSubscription

# Register your models here.
admin.site.register(Message)
admin.site.register(MessageType)
admin.site.register(MessageState)
admin.site.register(MessageCoord)
admin.site.register(MessageSolution)
admin.site.register(PushSubscription)