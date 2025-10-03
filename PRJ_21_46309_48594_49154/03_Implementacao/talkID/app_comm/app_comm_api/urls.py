from django.urls import path
from rest_framework.authtoken.views import obtain_auth_token

from . import views

app_name='app_comm_api'
urlpatterns = [
    path("", views.IndexView.as_view(), name="index"), 
    path("manage_accounts/", views.ManageAccountsView.as_view(), name="manage_accounts"), 
    path("user_reports/", views.ReportsView.as_view(), name="user_reports"), 
    path("login_user/", views.login_user, name="login_user"),  
    path("register_users/", views.register_users, name="register_users"), 
    path("logout_user/", views.logout_user, name="logout_user"), 
    path('subscribe/', views.subscribe_user, name='subscribe_user'), 
    path('unsubscribe/', views.unsubscribe_user, name='unsubscribe_user'), 
    path(f"{app_name}/loadMoreUsers/", views.loadMoreUsers, name='load_more_users'), 
    path(f"{app_name}/loadMoreMsgs/", views.loadMoreMsgs, name='load_more_messages'), 
    path(f"{app_name}/getMsgsFilter/", views.getMsgsFilter, name="get_messages_filter"), 
    path(f"{app_name}/getMsgsCoord/<int:msg_id>/", views.getMsgsCoord, name="get_messages_coord"), 
    path(f"{app_name}/getMsgsSol/<int:msg_id>/", views.getMsgsSolutions, name="get_messages_solutions"), 
    path(f"{app_name}/getUserSolutions/<int:user_id>/", views.getUserSolutions, name="get_user_solutions"), 
    path(f"{app_name}/addMsgs/", views.addMsgs, name="add_message"), 
    path(f"{app_name}/addMsgsCoord/", views.addMsgsCoord, name="add_message_coord"), 
    path(f"{app_name}/updateMsgViewed/<int:pk>/", views.updateMsgViewed, name="update_message_viewed"), 
    path(f"{app_name}/updateMsgState/<int:pk>/", views.updateMsgState, name="update_message_state"), 
    path(f"{app_name}-token-auth/", obtain_auth_token),
    path(f"{app_name}/delete_user/<int:user_id>/", views.delete_user, name="delete_user"),
]