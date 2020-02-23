# Chopperbot

Your cute Slack & LINE bot assistant.

You can play with Chopperbot in LINE by scanning QR code below.

<img width="253" alt="image" src="https://user-images.githubusercontent.com/761819/71999646-60cf1280-3274-11ea-86b1-13be27537bca.png">


## Usage 1: Split the bill

You can get the help from chopper to calculate your bill with this syntax.    
(For LINE, don't use slash, start with just `split`)
```
/split NAME AMOUNT NAME AMOUNT ... [+v | +s]
```

<img width="680" alt="Frame 1" src="https://user-images.githubusercontent.com/761819/72602332-ac0ab480-3949-11ea-96b8-5c61443cc4aa.png">


The option can use to apply multiplication to all orders.   
Note that the order of options matter in the calculation.
```
+v means add vat 7%
+s means add service charge 10%
```

Ex. Add a service charge
```
/split turbo 100 turbo 200 kendo 300 neo 400 +s

Chopper:
turbo 330
kendo 330
neo 440
---
total 1100
```

Ex. Add a share dish ("share" is for sharing dish)
```
/split turbo 100 turbo 200 kendo 300 neo 400 share 300

Chopper:
turbo 400
kendo 400
neo 500
---
total 1300
```

Ex. Add a discount (utilizing "share" for split discount)
```
/split turbo 100 kendo 200 kendo -1 share -100

Chopper:
kendo: 149.00 THB
turbo: 50.00 THB
---
total: 199.00 THB
```


## Development

### For Slack

Run the cowboy server
```sh
iex -S mix
```

Test by posting json data to the endpoint
`POST localhost:4000/split`

```json
{
	"text": "turbo 100 turbo 200 kendo 300 neo 400"
}
```

### For LINE

Run the cowboy server with the channel access token
```sh
LINE_CHANNEL_ACCESS_TOKEN=xxxxx iex -S mix
```

Test by posting json data to the endpoint
`POST localhost:4000/line`

```json
{
	"events": [{
		"message": { "text": "turbo 100 turbo 200 kendo 300 neo 400"},
		"replyToken": "anything"
	}]
}
```


## Deployment

For the first time, add the remote to Gigalixir.  
`GIGALIXIR_REMOTE_URL` can be found in the setup instruction.  
```sh
git remote add gigalixir GIGALIXIR_REMOTE_URL
```

Configure the required variables.
```sh
gigalixir config:set APP_URL=XXX
gigalixir config:set LINE_CHANNEL_ACCESS_TOKEN=YYY
gigalixir config:set APPSIGNAL_API_KEY=ZZZ
```

Once you have the gigalixir remote, just push to build.
```sh
git push gigalixir master
```

The application will be avilable on    
https://APP_NAME.gigalixirapp.com/


## Reference

For the detail on setting up Slack application, please check    
https://www.monterail.com/blog/building-slackbot-with-elixir-phoenix
