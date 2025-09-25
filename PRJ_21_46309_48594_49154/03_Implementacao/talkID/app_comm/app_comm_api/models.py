from django.db import models
from django.contrib.auth.models import User
from django.core.validators import MinValueValidator, MaxValueValidator

class PushSubscription(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    endpoint = models.URLField(max_length=512)
    p256dh = models.CharField(max_length=255)
    auth = models.CharField(max_length=255)
    
class MessageType(models.Model):
    message_type_name = models.CharField(max_length=40)

    def __str__(self):
        return self.message_type_name

class MessageState(models.Model):
    message_state_name=models.CharField(max_length=25)
    
class Message(models.Model):
    message_type = models.ForeignKey(MessageType, on_delete=models.CASCADE)
    message_state = models.ForeignKey(MessageState, on_delete=models.CASCADE)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    message_info = models.CharField(max_length=100)
    date_time = models.DateTimeField(auto_now_add=True)
    viewed = models.BooleanField(default=False)
    level = models.IntegerField(null=True, blank=True, validators=[MinValueValidator(1), MaxValueValidator(10)], 
                                verbose_name="level indicator")

    def __str__(self):
        return f'{self.message_type.message_type_name}: {self.message_info}'
    
class MessageCoord(models.Model):
    message = models.ForeignKey(Message, on_delete=models.CASCADE)
    x = models.DecimalField(max_digits=10, decimal_places=6)
    y = models.DecimalField(max_digits=10, decimal_places=6)
    imageWidth = models.DecimalField(max_digits=10, decimal_places=6)
    imageHeight = models.DecimalField(max_digits=10, decimal_places=6)
    radius = models.FloatField()
    color = models.CharField(max_length=10)
    
    def __str__(self):
        return f'({self.x}, {self.y})'
    
class MessageSolution(models.Model):
    message = models.ForeignKey(Message, on_delete=models.CASCADE)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    message_solution = models.CharField(max_length=255)