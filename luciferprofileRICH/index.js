var rpc = require("discord-rpc")
const client = new rpc.Client({ transport: 'ipc' })
client.on('ready', () => {
client.request('SET_ACTIVITY', {
pid: process.pid,
activity : {
details : "Playing LUCIFER op",
assets : {
large_image : "lucifer_logo",
large_text : "Playing LUCIFER op" // THIS WILL SHOW AS "Playing <Status>" from the outisde
},
buttons : [{label : "JOIN AURP" , url : "https://discord.gg/yn2Us3Y4Zc"}]
}
})
})
client.login({ clientId : "enter client id here" }).catch(console.error);