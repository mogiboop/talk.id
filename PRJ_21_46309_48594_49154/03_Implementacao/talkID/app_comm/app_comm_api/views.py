from django.shortcuts import redirect, get_object_or_404, render
from rest_framework import status
from django.http import  JsonResponse
from django.urls import reverse
from app_comm_api.models import Message, MessageCoord, MessageType, PushSubscription, MessageState, MessageSolution
from django.views import generic
from django.utils import timezone
from django.utils.dateparse import parse_datetime
from rest_framework.response import Response
from rest_framework.decorators import api_view, authentication_classes
from channels.layers import get_channel_layer
from asgiref.sync import async_to_sync
from app_comm_api.serializers import MessageSerializer, MessageShortSerializer, MessageCoordSerializer, MessageSolutionSerializer, UserSolutionSerializer
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.decorators import login_required
from django.contrib.auth.mixins import LoginRequiredMixin
from django.contrib import messages
from django.contrib.auth.models import Group, User
from rest_framework.authentication import SessionAuthentication, TokenAuthentication
from django.db.models import F, Q, Prefetch
from app_comm_api.forms import CustomUserCreationForm
import json
from decouple import config
from pywebpush import webpush, WebPushException
from django.views.generic.base import TemplateView

#Notify all users
def send_notification_to_users(title, message):
    payload = {'head': title, 'body': message, 'icon': '/static/images/logo_website.png', 'url': '/'}
    payload_json = json.dumps(payload)
    subs = PushSubscription.objects.all()
    for sub in subs:
        if sub.user.is_authenticated:
            subscription_info = {
                'endpoint': sub.endpoint,
                'keys': {
                    'p256dh': sub.p256dh,
                    'auth': sub.auth,
                }
            }
            try:
                webpush(
                    subscription_info,
                    data=payload_json,
                    vapid_private_key=config('WEB_PUSH_VAPID_PRIV_KEY'),
                    vapid_claims={"sub": 'mailto:' + config('WEB_PUSH_VAPID_ADMIN_EMAIL')}
                )
            except WebPushException as ex:
                print(f"Error sending push notification to {sub.endpoint}: {ex}")
           
@login_required
def register_users(request):
    if request.method == 'POST':
        form = CustomUserCreationForm(request.POST)
        if form.is_valid():
            user_type = form.cleaned_data.get('user_type')
            if user_type == 'admin' and request.user.is_superuser:
                user = User.objects.create_superuser(
                    username=form.cleaned_data['username'],
                    email=form.cleaned_data['email'],
                    password=form.cleaned_data['password1'],
                    first_name=form.cleaned_data['first_name'],
                    last_name=form.cleaned_data['last_name'],
                )
            elif user_type == 'nurse' and request.user.is_superuser:
                user = form.save()
            elif user_type and 'patient':
                user = form.save()

            if user_type == 'patient':
                group = Group.objects.get(name='Patient')
            else: 
                group = Group.objects.get(name='Nurse')
            
            user.groups.add(group)
            messages.success(request, (f"Registration of user {user.username} as {group.name} successful!"))
            #return render(request, 'register_patient.html')
            return redirect(reverse('app_comm_api:register_users'))
        else:
            for field in form:
                for error in field.errors:
                    messages.error(request, f"{field.label}: {error}")
            for error in form.non_field_errors():
                messages.error(request, error)
            #return render(request, 'register_patient.html')
            return redirect(reverse('app_comm_api:register_users'))
    else:
        form = CustomUserCreationForm()
    
    return render(request, 'register_users.html', {'form': form})

def login_user(request):
    if request.method == "POST":
        username = request.POST['username']
        password = request.POST['password']
        
        if request.user.is_authenticated:
            logout(request)
        user = authenticate(request, username=username, password=password)
        if user:
            if user.groups.filter(name='Nurse').exists():
                if user is not None:
                    if user.is_active:
                        messages.success(request, (f'Logged in as <b>{user.username}</b>!'))
                        login(request, user)
                        #return render(request, 'index.html')
                        return redirect(reverse('app_comm_api:index'))
                    else:
                        messages.warning(request, ('This user is not valid.'))
                        #return render(request, 'login.html')
                        return redirect(reverse("app_comm_api:login_user"))
                else:
                    messages.warning(request, ('There was an error logging in, try again.'))
                    #return render(request, 'login.html')
                    return redirect(reverse("app_comm_api:login_user"))
            else:
                logout(request)
                messages.warning(request, ('Only nurses can use this website.'))
                #return render(request, 'login.html')
                return redirect(reverse("app_comm_api:login_user"))
        else:
            messages.warning(request, ('Only nurses can use this website.'))
            #return render(request, 'login.html')
            return redirect(reverse("app_comm_api:login_user"))  
    else:
        #return redirect(reverse("app_comm_api:login")) 
        return render(request, 'login.html')

@login_required
def logout_user(request):
    logout(request)
    messages.success(request, "You were logged out!")
    return redirect('app_comm_api:login_user')
    


class IndexView(LoginRequiredMixin, generic.ListView):
    login_url = '/login_user/'
    redirect_field_name = '/login_user/'
    model = Message
    template_name = "index.html"
    context_object_name = "latest_message_list"
    
    
    def get_queryset(self):
        limit = 11
        queryset = Message.objects.filter(
            date_time__lte=timezone.now(), message_state_id=1
        ).order_by("-date_time").select_related('user').select_related('message_type').select_related('message_state')[:limit]
        
        queryset = queryset.annotate(message_state_name=F('message_state__message_state_name'))
        
        queryset = queryset.annotate(
            first_name=F('user__first_name'),
            last_name=F('user__last_name')
        )
        
        queryset = queryset.annotate(message_type_name=F('message_type__message_type_name'))
        
        return queryset
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        msg_types = MessageType.objects.all()
        context['msg_types'] = msg_types
        context['offset'] = 10
        return context

class ManageAccountsView(LoginRequiredMixin, TemplateView):
    login_url = '/login_user/'
    redirect_field_name = '/login_user/'
    template_name = 'manage_accounts.html'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        limit = 11
        current_user = self.request.user
        
        if current_user.is_superuser:
            users = User.objects.filter(~Q(is_superuser=True)).prefetch_related(
                Prefetch('groups', queryset=Group.objects.all(), to_attr='user_groups')
            )[:limit]
        else:
            try:
                patient_group = Group.objects.get(name='Patient')
                users = User.objects.filter(groups=patient_group).prefetch_related(
                    Prefetch('groups', queryset=Group.objects.all(), to_attr='user_groups')
                )
            except Group.DoesNotExist:
                users = User.objects.none()
        
        user_data = []
        for user in users:
            full_name = " ".join([user.first_name, user.last_name]).strip()
            group_name = user.user_groups[0].name if user.user_groups else 'No Group'
            user_data.append({
                'id': user.id,
                'username': user.username,
                'full_name': full_name,
                'email': user.email,
                'group': group_name
            })
        
        context['users'] = user_data
        context['groups'] = Group.objects.all()
        context['offset'] = 10
        return context
        

class ReportsView(LoginRequiredMixin, TemplateView):
    login_url = '/login_user/'
    redirect_field_name = '/login_user/'
    template_name = 'user_solutions.html'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        
        patient_group = Group.objects.get(name='Patient')
        users_list = User.objects.filter(groups=patient_group).prefetch_related(
            Prefetch('groups', queryset=Group.objects.all(), to_attr='user_groups')
        )
        users_list_data = []
        for user in users_list:
            users_list_data.append({
                'id': user.id,
                'username': user.username,
            })
        context['users_list'] = users_list_data
        return context
        
#API Methods
@authentication_classes([SessionAuthentication, TokenAuthentication])
@api_view(['POST'])
def subscribe_user(request):
    data = request.data
    if 'subscription' in data:
        subscription = data.get('subscription')
        sub, created = PushSubscription.objects.get_or_create(
            user=request.user,
            endpoint=subscription['endpoint'],
            p256dh=subscription['keys']['p256dh'],
            auth=subscription['keys']['auth'],
        )
        return JsonResponse({'success': True}, status=201)
    else:
        return JsonResponse({'success': False})
    
@authentication_classes([SessionAuthentication, TokenAuthentication])
@api_view(['POST'])
def unsubscribe_user(request):
    data = request.data
    subscription = data.get('subscription')
    subs = PushSubscription.objects.filter(endpoint=subscription['endpoint'], user=request.user)
    if subs: 
        subs.delete()
    return JsonResponse({'success': True}, status=202)

@authentication_classes([SessionAuthentication, TokenAuthentication])
@api_view(['GET'])
def loadMoreMsgs(request):
    user = request.GET.get('user', '')
    begin_datetime = request.GET.get('begin_datetime', '')
    end_datetime = request.GET.get('end_datetime', '')
    message_type = request.GET.get('message_type', '')
    order = request.GET.get('order', 'desc')
    state = request.GET.get('state', 1)
    offset = int(request.GET.get('offset', 0))
    limit = 11
    
    messages = Message.objects.all()
    
    if user:
        messages = messages.select_related('user')
        messages = messages.annotate(username=F('user__username'), first_name=F('user__first_name'), last_name=F('user__last_name'))
        messages = messages.filter(user__username__icontains=user)
    
    if begin_datetime:
        parsed_begin_datetime = parse_datetime(begin_datetime)
        if parsed_begin_datetime:
            messages = messages.filter(date_time__gte=parsed_begin_datetime)
            
    if end_datetime:
        parsed_end_datetime = parse_datetime(end_datetime)
        if parsed_end_datetime:
            messages = messages.filter(date_time__lte=parsed_end_datetime)
    
    if message_type:
        messages = messages.select_related('message_type')
        messages = messages.annotate(message_type_name=F('message_type__message_type_name'))
        messages = messages.filter(message_type_id=message_type)
        
    if order == 'asc':
        messages = messages.order_by('date_time')
    else:
        messages = messages.order_by('-date_time')
        
    if state:
        messages = messages.select_related('message_state')
        messages = messages.annotate(message_state_name=F('message_state__message_state_name'))
        messages = messages.filter(message_state_id=state)
    
    messages = messages[offset:offset+limit]
    serializer = MessageSerializer(messages, many=True)
    return Response({'success': True, 'data': serializer.data})

@authentication_classes([SessionAuthentication, TokenAuthentication])
@api_view(['GET'])
def loadMoreUsers(request):
    user = request.GET.get('user', '')
    group = request.GET.get('group', '')
    offset = int(request.GET.get('offset', 0))
    limit = 11
    
    if group:
        group = Group.objects.get(id=group)
        if user:
            users = User.objects.filter(
            username__icontains=user,
            groups=group,
            is_superuser=False
            )
        else:
            users = group.user_set.filter(is_superuser=False)
    elif user:
        users = User.objects.filter(username__icontains=user, is_superuser=False)
    else:
        users = User.objects.filter(is_superuser=False)   
    
    users = users[offset:offset+limit]
    user_data = []
    for user in users:
        full_name = " ".join([user.first_name, user.last_name]).strip()
        group_name = user.groups.first().name if user.groups.exists() else 'No Group'
        user_data.append({
            'id': user.id,
            'username': user.username,
            'full_name': full_name,
            'email': user.email,
            'group': group_name
        })
    
    return Response({'success': True, 'data': user_data})

@authentication_classes([SessionAuthentication, TokenAuthentication])
@api_view(['GET'])
def getUserSolutions(request, user_id):
    bdt = request.GET.get('bdt', '')
    edt = request.GET.get('edt', '')
            
    if request.user.is_superuser:
        messages = Message.objects.filter(user_id=user_id, date_time__lte=timezone.now()).order_by("-date_time")
        if bdt:
            parsed_begin_datetime = parse_datetime(bdt)
            if parsed_begin_datetime:
                messages = messages.filter(date_time__gte=parsed_begin_datetime)
            
        if edt:
            parsed_end_datetime = parse_datetime(edt)
            if parsed_end_datetime:
                messages = messages.filter(date_time__lte=parsed_end_datetime)
                
        messages = messages.prefetch_related(
            Prefetch('messagesolution_set', queryset=MessageSolution.objects.select_related('user'), to_attr='message_solutions')
        )
        
        serializer = UserSolutionSerializer(messages, many=True)
        return Response({'success':True, 'data': serializer.data}, status=status.HTTP_200_OK)
    else:
        return Response({'detail': 'You cannot get this data.'}, status=status.HTTP_403_FORBIDDEN)

@authentication_classes([SessionAuthentication, TokenAuthentication])
@api_view(['GET'])
def getMsgsFilter(request):
    user = request.GET.get('user', '')
    begin_datetime = request.GET.get('begin_datetime', '')
    end_datetime = request.GET.get('end_datetime', '')
    message_type = request.GET.get('message_type', '')
    order = request.GET.get('order', 'desc')
    state = request.GET.get('state', 1)
    limit = 11
    messages = Message.objects.all()
    
    if user:
        messages = messages.select_related('user')
        messages = messages.annotate(username=F('user__username'), first_name=F('user__first_name'), last_name=F('user__last_name'))
        messages = messages.filter(user__username__icontains=user)
    
    if begin_datetime:
        parsed_begin_datetime = parse_datetime(begin_datetime)
        if parsed_begin_datetime:
            messages = messages.filter(date_time__gte=parsed_begin_datetime)
            
    if end_datetime:
        parsed_end_datetime = parse_datetime(end_datetime)
        if parsed_end_datetime:
            messages = messages.filter(date_time__lte=parsed_end_datetime)
    
    if message_type:
        messages = messages.select_related('message_type')
        messages = messages.annotate(message_type_name=F('message_type__message_type_name'))
        messages = messages.filter(message_type_id=message_type)
        
    if order == 'asc':
        messages = messages.order_by('date_time')
    else:
        messages = messages.order_by('-date_time')
    
    if state:
        messages = messages.select_related('message_state')
        messages = messages.annotate(message_state_name=F('message_state__message_state_name'))
        messages = messages.filter(message_state_id=state)
    
    messages = messages[:limit]
    serializer = MessageSerializer(messages, many=True)
    return Response({'success': True, 'data': serializer.data}) 
    
@authentication_classes([SessionAuthentication, TokenAuthentication])
@api_view(['GET'])
def getMsgsCoord(request, msg_id):
    msgs = MessageCoord.objects.filter(message_id=msg_id)
    serializer = MessageCoordSerializer(msgs, many=True)
    return Response({'success': True, 'data': serializer.data})

@authentication_classes([SessionAuthentication, TokenAuthentication])
@api_view(['GET'])
def getMsgsSolutions(request, msg_id):
    msgs = MessageSolution.objects.filter(message_id=msg_id)
    serializer = MessageSolutionSerializer(msgs, many=True)
    return Response({'success': True, 'data': serializer.data})

#@csrf_exempt
@authentication_classes([SessionAuthentication, TokenAuthentication])
@api_view(['POST'])
def addMsgs(request):
    user = request.user
    if user is not None:
        if user.is_authenticated:
            serializer = MessageShortSerializer(data=request.data)
            if serializer.is_valid():
                serializer.validated_data['user_id'] = user.id
                serializer.validated_data['message_state_id'] = 1
                message_instance = serializer.save()
                saved_message = Message.objects.select_related('user', 'message_type').get(pk=message_instance.pk)
                serialized_data = MessageSerializer(saved_message).data
                
                user_data = serialized_data.get('user')
                message_type_data = serialized_data.get('message_type')
                channel_layer = get_channel_layer()
                async_to_sync(channel_layer.group_send)(
                    "updates",
                    {
                        "type": "send_update",
                        "id": serialized_data.get('id'),
                        "first_name": user_data.get('first_name'),
                        "last_name": user_data.get('last_name'),
                        "msg_type_id": message_type_data.get('id'),
                        "msg_type_name": message_type_data.get('message_type_name'),
                        "msg_info": serialized_data.get('message_info'),
                        "msg_date_time": serialized_data.get('formatted_date_time'),
                        "level": serialized_data.get('level'),
                    }
                )
                if(message_type_data.get('id') == 1):
                    title = "Nova Mensagem de SOS"
                    message = "Atenção recebeu uma mensagem de SOS! "
                    send_notification_to_users(title, message) 
                    
                return Response({"done": "Message sent successfuly!", "msgID" : message_instance.id}, status=status.HTTP_201_CREATED)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        return Response({"error: User not authenticated"}, status=status.HTTP_400_BAD_REQUEST)
    return Response({"error: User not authenticated"}, status=status.HTTP_400_BAD_REQUEST)

@authentication_classes([SessionAuthentication, TokenAuthentication])
@api_view(['POST'])
def addMsgsCoord(request):
    user = request.user
    if user is not None:
        if user.is_authenticated:
            try:
                data = request.data
                message_id = data.get('message_id')
                image_width = data.get('imageWidth')
                image_height = data.get('imageHeight')
                coordinates = data.get('coordinates')
                
                if not all([message_id, image_width, image_height, coordinates]):
                    return Response({"error": "Missing fields in request"}, status=status.HTTP_400_BAD_REQUEST)
                
                for coord in coordinates:
                    coord_data = {
                        'message': message_id,
                        'x': coord.get('x'),
                        'y': coord.get('y'),
                        'imageWidth': image_width,
                        'imageHeight': image_height,
                        'radius' : coord.get('radius'),
                        'color' : coord.get('color')
                    }

                    serializer = MessageCoordSerializer(data=coord_data)
                    
                    if serializer.is_valid():
                        serializer.save()
                    else:
                        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
                return Response({"done": "Message sent successfully!"}, status=status.HTTP_201_CREATED)
            
            except json.JSONDecodeError:
                return Response({"error": "Invalid JSON"}, status=status.HTTP_400_BAD_REQUEST)
        return Response({"error": "User not authenticated"}, status=status.HTTP_401_UNAUTHORIZED)
    return Response({"error": "User not authenticated"}, status=status.HTTP_401_UNAUTHORIZED)
            
@api_view(['PATCH'])
@authentication_classes([SessionAuthentication, TokenAuthentication])
def updateMsgState(request, pk):
    try:
        message = Message.objects.get(pk=pk)
        if(message.message_state.pk == 1):
            message.message_state = MessageState.objects.get(pk=2)
            msg = message.save()
            
            channel_layer = get_channel_layer()
            async_to_sync(channel_layer.group_send)(
                "updates",
                {
                    "type": "message_state",
                    "id": pk,
                }
            )
        solution = request.data.get('solution')
        if(solution.strip()!=""):
            MessageSolution.objects.get_or_create(user=request.user, message=message, message_solution=solution)
        return Response({'success': True, 'message': f'Message {pk} state updated'}, status=status.HTTP_200_OK)  
    except Message.DoesNotExist:
        return Response({'error': 'Message not found'}, status=status.HTTP_404_NOT_FOUND)
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['PATCH'])
@authentication_classes([SessionAuthentication, TokenAuthentication])
def updateMsgViewed(request, pk):
    try:
        message = Message.objects.get(pk=pk)
        if(message.viewed == False):
            message.viewed = True
            message.save()
            channel_layer = get_channel_layer()
            async_to_sync(channel_layer.group_send)(
                "updates",
                {
                    "type": "message_viewed",
                    "id": pk,
                }
            )
            return Response({'success': True, 'message': f'Message {pk} viewed'}, status=status.HTTP_200_OK)
        else:
            return Response({'success': True, 'message': f'Message {pk} already viewed'}, status=status.HTTP_200_OK)  
    except Message.DoesNotExist:
        return Response({'error': 'Message not found'}, status=status.HTTP_404_NOT_FOUND)
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
@api_view(['DELETE'])
@authentication_classes([SessionAuthentication, TokenAuthentication])
def delete_user(request, user_id):
    user_to_delete = get_object_or_404(User, id=user_id)
    if user_to_delete.groups.filter(name='Nurse').exists():
        if request.user.is_superuser:
            if user_to_delete.is_superuser:
                return Response({'detail': 'You cannot delete a superuser.'}, status=status.HTTP_403_FORBIDDEN)
            
            user_to_delete.delete()
            return Response(status=status.HTTP_204_NO_CONTENT)
        
        else:
            return Response({'detail': 'You cannot delete a nurse.'}, status=status.HTTP_403_FORBIDDEN)
        
    user_to_delete.delete()
    return Response(status=status.HTTP_204_NO_CONTENT)