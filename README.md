# PSHammy -> WSJT-X Contact Relay to Discord
PSHammy is a module that interprets WSJT-X's log file, and posts contacts to a Discord channel via webhooks.

## Getting Started

### Requirements
- You will need [PowerShell Core](https://github.com/PowerShell/PowerShell), it is cross-platform, open-source, and the future of PowerShell.

- In order to send webhooks to Discord, you'll need to install the module [PSDsHook](https://github.com/gngrninja/PSDsHook).

- For map imaging this module uses the Azure Maps API. You'll need to get yourself an [Azure Maps API key](https://azure.microsoft.com/en-us/pricing/details/azure-maps/). 

- You can use call sign lookup services that are free with this module, but it works best if you have a subscription to QRZ's API. You can find that, [here](https://ssl.qrz.com/products/index.html). Most free call lookup APIs do not work so well with international call signs.

### Setting up the webhook
- Install PSDSHook if you have not already. You can install it via the PowerShell Gallery. Check out the instructions, [here](https://github.com/gngrninja/PSDsHook).
- Please follow the instructions under "Getting Started", here: https://www.gngrninja.com/script-ninja/2018/3/10/using-discord-webhooks-with-powershell to obtain the webhook URL.
- You can stop after step 4, and do keep the hook URL handy
- Create your PSDSHook configuration, as such (passing in your actual webhook dll):
```powershell
Invoke-PsDsHook -CreateConfig 'https://discordapp.com/api/webhooks/4221456689714954341337/thisisfakeandwillnotwork' -Verbose
```
- Test the webhook by trying:
```
Invoke-PSDsHook "test"
```
- You should see the text "test" in the channel you sent the hook to.

