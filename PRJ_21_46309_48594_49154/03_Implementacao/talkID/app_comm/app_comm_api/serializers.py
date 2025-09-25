from rest_framework import serializers
from app_comm_api.models import Message, MessageCoord, MessageType, MessageState, MessageSolution
from django.contrib.auth.models import User
from django.utils import formats, timezone
import pytz

class MessageSolutionSerializer(serializers.ModelSerializer):
    username = serializers.SerializerMethodField()
    
    class Meta:
        model = MessageSolution
        fields = ['id', 'message_solution', 'username']

    def get_username(self, obj):
        return obj.user.username

class MessageSolutionSerializer2(serializers.ModelSerializer):
    username = serializers.CharField(source='user.username', read_only=True)
    first_name = serializers.CharField(source='user.first_name', read_only=True)
    last_name = serializers.CharField(source='user.last_name', read_only=True)

    class Meta:
        model = MessageSolution
        fields = ['id', 'message_solution', 'username', 'first_name', 'last_name']
        
class UserSolutionSerializer(serializers.ModelSerializer):
    message_solutions = MessageSolutionSerializer2(many=True, read_only=True)
    message_type_name = serializers.CharField(source='message_type.message_type_name', read_only=True)
    formatted_date_time = serializers.SerializerMethodField()
    
    class Meta:
        model = Message
        fields = [
            'id', 'message_info', 'date_time', 'formatted_date_time', 'level', 'message_type_name',
            'message_solutions'
        ]
        
    def get_formatted_date_time(self, obj):
        local_datetime = timezone.localtime(obj.date_time, timezone=pytz.timezone('Europe/Lisbon'))
        return formats.date_format(local_datetime, "DATETIME_FORMAT") 
               
class MessageTypeSerializer(serializers.ModelSerializer):
    class Meta:
        model = MessageType
        fields = ['id', 'message_type_name']
        
class MessageStateSerializer(serializers.ModelSerializer):
    class Meta:
        model = MessageState
        fields = ['id', 'message_state_name']

class UserCustomSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'first_name', 'last_name'] 

class MessageSerializer(serializers.ModelSerializer):
    level = serializers.IntegerField(min_value=1, max_value=10, required=False)
    user = UserCustomSerializer()
    message_type = MessageTypeSerializer()
    message_state = MessageStateSerializer
    formatted_date_time = serializers.SerializerMethodField()
    
    class Meta:
        model = Message
        fields = ['id', 'message_info', 'message_type', 'message_state', 'user', 'viewed', 'date_time', 'level', 'formatted_date_time']
        
    def get_formatted_date_time(self, obj):
        local_datetime = timezone.localtime(obj.date_time, timezone=pytz.timezone('Europe/Lisbon'))
        return formats.date_format(local_datetime, "DATETIME_FORMAT")

class MessageShortSerializer(serializers.ModelSerializer):
    level = serializers.IntegerField(min_value=1, max_value=10, required=False)
    
    class Meta:
        model = Message
        fields = ['message_info', 'message_type', 'level']

class MessageCoordSerializer(serializers.ModelSerializer):
    class Meta:
        model = MessageCoord
        fields = ['message','x', 'y', 'imageWidth', 'imageHeight', 'radius', 'color']

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['username', 'password', 'email', 'first_name', 'last_name']
        extra_kwargs = {
            'password': {'write_only': True},
        }
        
    def create(self, validated_data):
        user = User.objects.create_user(**validated_data)
        user.is_active = False  
        user.save()
        return user
    