# Chopperbot

Your cute slack bot assistant

## Usage 1: Split the bill

You can get the help from chopper to calculate your bill with this syntax.
```
/split NAME AMOUNT NAME AMOUNT ... [+v | +s]
```
![image](https://user-images.githubusercontent.com/761819/70823863-7850e200-1e13-11ea-8884-29789549ff32.png)

The option can use to apply multiplication to all orders.   
Note that the order of options matter in the calculation.
```
+v means add vat 7%
+s means add service charge 10%
```

Ex. Add service charge
```
/split turbo 100 turbo 200 kendo 300 neo 400 +s
Chopper:
turbo 330
kendo 330
neo 440
total 1100
```

Ex. Add share dish ("share" is for sharing dish)
```
/split turbo 100 turbo 200 kendo 300 neo 400 share 300
Chopper:
turbo 400
kendo 400
neo 500
total 1300
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
```
git remote add gigalixir GIGALIXIR_REMOTE_URL
```

Once you have the gigalixir remote, just push to build.
```
git push gigalixir master
```

The application will be avilable on    
https://APP_NAME.gigalixirapp.com/


## Reference

For the detail on setting up Slack application, please check    
https://www.monterail.com/blog/building-slackbot-with-elixir-phoenix
