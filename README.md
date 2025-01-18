This is a basic Flutter project using an ESP32 microcontroller and SR501 PIR sensor to create a motion detector. It employs a spare phone which is on standby and streams video if motion is detected to a client device.
There are 3 parts in the code-
  1) ESP module code- This uses a basic websocket server to send a API message of motion detected. It can also show the messages send back from the api.
  2) Device code- This recieves the message and starts a basic IPWebcam over HTTP(future may use HLS).
  3) Client code- This can be used to fetch the stream and view it on a web server and notifies the user is any motion is detected using a push notification.
