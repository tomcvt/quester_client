importScripts("https://www.gstatic.com/firebasejs/10.0.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.0.0/firebase-messaging-compat.js");

firebase.initializeApp({
    apiKey: 'AIzaSyAPuxnsZPEeFZ6oldGSTvO19RY13qEQJ_U',
    appId: '1:603873913094:web:d330e60bbd4fe456301687',
    messagingSenderId: '603873913094',
    projectId: 'quester-4db02',
    authDomain: 'quester-4db02.firebaseapp.com',
    storageBucket: 'quester-4db02.firebasestorage.app',
    measurementId: 'G-49JQ852WVF',
});

const messaging = firebase.messaging();