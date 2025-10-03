from django import forms
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth.models import User

class CustomUserCreationForm(UserCreationForm):
    user_type = forms.CharField(widget=forms.HiddenInput(), required=False)
    username = forms.CharField(
        min_length=3,
        max_length=16, 
        required=True, 
        help_text='Required. 3 to 16 characters long. Letters and digits only.', 
        widget=forms.TextInput(attrs={
            'class': 'form-control',
            'placeholder': 'Username',
            'pattern': '^[A-Za-z0-9]{3,16}$',
            'title': 'Letters and digits only.'
        })
    )
    first_name = forms.CharField(
        max_length=30, 
        required=True, 
        help_text='Required. 30 characters or fewer.', 
        widget=forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'First name'})
    )
    last_name = forms.CharField(
        max_length=30,
        required=True,
        help_text='Required. 30 characters or fewer.', 
        widget=forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'Last name'})
    )
    email = forms.EmailField(
        max_length=254, 
        required=True,
        help_text='Required. Inform a valid email address.', 
        widget=forms.EmailInput(attrs={
            'class': 'form-control',
            'placeholder': 'Email',
            'pattern': '^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}$',
            'title': 'Inform a valid email address.'
        })
    )
    password1 = forms.CharField(
        min_length=8,
        max_length=254,
        required=True,
        label="Password",
        help_text='<ul>' + 
        '<li>Your password must contain at least 8 characters.</li>' +
        '<li>Your password can\'t be too similar to the other fields.</li>' +
        '<li>Your password can\'t be a commonly used password.</li>' +
        '<li>Your password needs to contain numbers and characters.</li>' +
        '<li>Your password needs to contain at least 1 digit.</li>' +
        '<li>Your password needs to contain at least 1 letter.</li>' +
        '<li>Your password needs to contain at least 1 symbol.</li>' +
        '</ul>',
        widget=forms.PasswordInput(attrs={
            'class': 'form-control',
            'placeholder': 'Password',
            'pattern': '^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,254}$',
            'title': 'Your password must contain at least 8 characters.\n' + 
                     'Your password needs to contain numbers and characters.\n' +
                     'Your password needs to contain at least 1 digit.\n' +
                     'Your password needs to contain at least 1 letter.\n' +
                     'Your password needs to contain at least 1 symbol.'
        })
    )
    password2 = forms.CharField(
        min_length=8,
        max_length=254,
        required=True,
        label="Password confirmation",
        help_text='Enter the same password as before, for verification.', 
        widget=forms.PasswordInput(attrs={
            'class': 'form-control',
            'placeholder': 'Password',
            'minlength': '8',
            'maxlength': '254'
        })
    )

    class Meta:
        model = User
        fields = ('username', 'email', 'first_name', 'last_name', 'password1', 'password2')